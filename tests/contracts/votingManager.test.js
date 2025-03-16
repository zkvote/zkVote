// This is a test file for the VotingManager contract.

// Import necessary libraries and contracts
const { expect } = require("chai");
const { ethers } = require("hardhat");
const snarkjs = require("snarkjs"); // Import snarkjs for zk-SNARKs related operations
const { execSync } = require("child_process"); // Import execSync for executing shell commands
const path = require("path"); // Import path for handling file paths
const circomlib = require("circomlibjs"); // Import circomlib for cryptographic operations
const ffjavascript = require("ffjavascript"); // Import ffjavascript for finite field operations

// Describe the VotingManager contract test suite
describe("VotingManager", function () {
  let VotingManager;
  let votingManager;
  let MockVerifier;
  let mockVerifier;
  let admin;
  let voter1;
  let voter2;
  let nonAdmin;

  // A mock proof data for testing purposes
  const mockProof = {
    a: [1, 2],
    b: [
      [3, 4],
      [5, 6],
    ],
    c: [7, 8],
    publicSignals: [9],
  };

  // A beforeEach hook
  beforeEach(async function () {
    // Deploy mock verifier contract
    MockVerifier = await ethers.getContractFactory("MockVerifier"); // Get the contract factory for MockVerifier
    mockVerifier = await MockVerifier.deploy(); // Deploy the contract
    await mockVerifier.waitForDeployment(); // Wait for the contract to be deployed

    // Deploy VotingManager contract
    VotingManager = await ethers.getContractFactory("VotingManager"); // Get the contract factory for VotingManager
    [admin, voter1, voter2, nonAdmin] = await ethers.getSigners(); // Get the signers
    votingManager = await VotingManager.deploy(mockVerifier.target); // Deploy the contract with the mock verifier address
    await votingManager.waitForDeployment(); // Wait for the contract to be deployed
  });

  describe("Initialization", function () {
    // Should set the right admin
    it("Should set the right admin", async function () {
      expect(await votingManager.admin()).to.equal(admin.address); // Check if the admin is set correctly
    });

    // Should set the right verifier
    it("Should set the right verifier", async function () {
      expect(await votingManager.verifier()).to.equal(mockVerifier.target); // Check if the verifier is set correctly
    });

    // Should initialize with zero voting sessions
    it("Should initialize with zero voting sessions", async function () {
      expect(await votingManager.votingSessionCount()).to.equal(0); // Check if the voting session count is zero
    });
  });

  // A describe block for testing the voting session creation
  describe("Creating Voting Sessios", function () {
    const sessionName = "Test Session"; // Define a session name
    const currentTime = Math.floor(Date.now() / 1000); // Get the current time in seconds
    const startTime = currentTime + 60; // Set the start time to 60 seconds in the future
    const endTime = startTime + 3600; // Set the end time to 1 hour after the start time
    const candidateCount = 3; // Define the number of candidates

    // Should allow admin to create a voting session
    it("Should allow admin to create a voting session", async function () {
      await expect(
        votingManager.createVotingSession(
          sessionName,
          startTime,
          endTime,
          candidateCount
        )
      )
        .to.emit(votingManager, "VotingSessionCreated")
        .withArgs(1, sessionName, startTime, endTime); // Check if the event is emitted

      expect(await votingManager.votingSessionCount()).to.equal(1); // Check if the voting session count is incremented
    });

    // Should not allow non-admin to create a voting session
    it("Should not allow non-admin to create a voting session", async function () {
      await expect(
        votingManager
          .connect(nonAdmin)
          .createVotingSession(sessionName, startTime, endTime, candidateCount)
      ).to.be.revertedWith("Only admin can call this function"); // Check if the transaction is reverted
    });

    // Should fail if start time is after end time
    it("Should fail if start time is after end time", async function () {
      await expect(
        votingManager.createVotingSession(
          sessionName,
          endTime,
          startTime,
          candidateCount
        )
      ).to.be.revertedWith("Start time must be before end time"); // Check if the transaction is reverted
    });

    // Should fail if candidate count is zero
    it("Should fail if candidate count is zero", async function () {
      await expect(
        votingManager.createVotingSession(sessionName, startTime, endTime, 0)
      ).to.be.revertedWith("Candidate count must be greater than 0"); // Check if the transaction is reverted
    });
  });

  // A describe block for testing the casting of votes
  describe("Casting Votes", function () {
    const sessionId = 1;
    const sessionName = "Test Session";
    let startTime, endTime;
    const candidateCount = 3;
    const candidateId = 1;
    const nullifier = 123456;

    // A beforeEach hook
    this.beforeEach(async function () {
      // Set up the mock verifier to return true for the proof
      await mockVerifier.setVerificationResult(true); // Set the verification result to true

      // Get current block timestamp
      const block = await ethers.provider.getBlock("latest"); // Get the latest block
      startTime = block.timestamp; // start time is the current block timestamp
      endTime = startTime + 3600; // end time is 1 hour after the start time

      // Create a voting session as admin
      await votingManager.createVotingSession(
        sessionName,
        startTime,
        endTime,
        candidateCount
      );
    });

    // Should allow casting a vote with valid proof
    it("Should allow casting a vote with valid proof", async function () {
      await expect(
        votingManager
          .connect(voter1)
          .castVote(
            sessionId,
            candidateId,
            nullifier,
            mockProof.a,
            mockProof.b,
            mockProof.c,
            mockProof.publicSignals
          )
      )
        .to.emit(votingManager, "VoteCast")
        .withArgs(sessionId, candidateId, nullifier); // Check if the event is emitted

      expect(await votingManager.getVoteCount(sessionId, candidateId)).to.equal(
        1
      ); // Check if the vote count is incremented
    });

    // Should not allow casting a vote with invalid proof
    it("Should not allow casting a vote with invalid proof", async function () {
      // Set the mock verifier to return false for the proof
      await mockVerifier.setVerificationResult(false); // Set the verification result to false

      await expect(
        votingManager
          .connect(voter1)
          .castVote(
            sessionId,
            candidateId,
            nullifier,
            mockProof.a,
            mockProof.b,
            mockProof.c,
            mockProof.publicSignals
          )
      ).to.be.revertedWith("Invalid proof"); // Check if given proof is invalid
    });

    // Should not allow double voting with the same nullifier
    it("Should not allow double voting with the same nullifier", async function () {
      // Cast the first vote with a nullifier
      await votingManager
        .connect(voter1)
        .castVote(
          sessionId,
          candidateId,
          nullifier,
          mockProof.a,
          mockProof.b,
          mockProof.c,
          mockProof.publicSignals
        );

      // Try to cast the same vote again with the same nullifier
      await expect(
        votingManager
          .connect(voter1)
          .castVote(
            sessionId,
            candidateId,
            nullifier,
            mockProof.a,
            mockProof.b,
            mockProof.c,
            mockProof.publicSignals
          )
      ).to.be.revertedWith("Vote already cast with this nullifier"); // Check for double voting
    });

    // Should not allow voting in a non-existent session
    it("Should not allow voting in a non-existent session", async function () {
      const invalidSessionId = 999; // Define an invalid session ID

      await expect(
        votingManager
          .connect(voter1)
          .castVote(
            invalidSessionId,
            candidateId,
            nullifier,
            mockProof.a,
            mockProof.b,
            mockProof.c,
            mockProof.publicSignals
          )
      ).to.be.revertedWith("Voting session is not active"); // Check for non-existent session
    });

    // Should allow multiple voters to cast valid votes
    it("Should allow multiple voters to cast valid votes", async function () {
      // First voter votes for candidate 1
      await votingManager
        .connect(voter1)
        .castVote(
          sessionId,
          1,
          nullifier,
          mockProof.a,
          mockProof.b,
          mockProof.c,
          mockProof.publicSignals
        );

      // Second voter votes for candidate 2
      await votingManager
        .connect(voter2)
        .castVote(
          sessionId,
          2,
          nullifier + 1,
          mockProof.a,
          mockProof.b,
          mockProof.c,
          mockProof.publicSignals
        );

      expect(await votingManager.getVoteCount(sessionId, 1)).to.equal(1);
      expect(await votingManager.getVoteCount(sessionId, 2)).to.equal(1);
    });
  });

  // A describe block for testing the time-based restrictions
  describe("Time-based Restrictions", function () {
    const sessionId = 1;
    const sessionName = "Test Session";
    const candidateCount = 3;
    const candidateId = 1;
    const nullifier = 123456;

    // Should not allow voting before the session starts
    it("Should not allow voting before the session starts", async function () {
      const currentBlock = await ethers.provider.getBlock("latest"); // Get the latest block
      const startTime = currentBlock.timestamp + 1000; // Set the start time to 1000 seconds in the future
      const endTime = startTime + 3600; // Set the end time to 1 hour after the start time

      // Create a voting session that starts in the future
      await votingManager.createVotingSession(
        sessionName,
        startTime,
        endTime,
        candidateCount
      );

      await expect(
        votingManager
          .connect(voter1)
          .castVote(
            sessionId,
            candidateId,
            nullifier,
            mockProof.a,
            mockProof.b,
            mockProof.c,
            mockProof.publicSignals
          )
      ).to.be.revertedWith("Voting session is not active"); // Check if voting is not allowed before the session starts
    });

    // Should not allow voting after the session ends
    it("Should not allow voting after the session ends", async function () {
      const currentBlock = await ethers.provider.getBlock("latest"); // Get the latest block
      const startTime = currentBlock.timestamp - 3600; // Set the start time to 1 hour in the past
      const endTime = startTime + 3600; // Set the end time to 1 hour after the start time

      // Create a voting session that has already ended
      await votingManager.createVotingSession(
        sessionName,
        startTime,
        endTime,
        candidateCount
      );

      await expect(
        votingManager
          .connect(voter1)
          .castVote(
            sessionId,
            candidateId,
            nullifier,
            mockProof.a,
            mockProof.b,
            mockProof.c,
            mockProof.publicSignals
          )
      ).to.be.revertedWith("Voting session is not active"); // Check if voting is not allowed after the session ends
    });
  });

  // A describe block for testing the closing of voting sessions
  describe("Closing Voting Sessions", function () {
    const sessionId = 1;
    const sessionName = "Test Session";
    const candidateCount = 3;

    this.beforeEach(async function () {
      const currentBlock = await ethers.provider.getBlock("latest"); // Get the latest block
      const startTime = currentBlock.timestamp; // Set the start time to the current block timestamp
      const endTime = startTime + 3600; // Set the end time to 1 hour after the start time

      // Create a voting session
      await votingManager.createVotingSession(
        sessionName,
        startTime,
        endTime,
        candidateCount
      );
    });

    // Should allow admin to close a voting session
    it("Should allow admin to close a voting session", async function () {
      await expect(votingManager.closeVotingSession(sessionId))
        .to.emit(votingManager, "VotingSessionEnded")
        .withArgs(sessionId); // Check if the event is emitted

      // Try to vote after the session is closed
      await expect(
        votingManager
          .connect(voter1)
          .castVote(
            sessionId,
            1,
            123456,
            mockProof.a,
            mockProof.b,
            mockProof.c,
            mockProof.publicSignals
          )
      ).to.be.revertedWith("Voting session is not active"); // Check if voting is not allowed after the session is closed
    });

    // Should not allow non-admin to close a voting session
    it("Should not allow non-admin to close a voting session", async function () {
      await expect(
        votingManager.connect(nonAdmin).closeVotingSession(sessionId)
      ).to.be.revertedWith("Only admin can call this function"); // Check if the transaction is reverted
    });

    // Should not allow closing a non-existent session
    it("Should not allow closing a non-existent session", async function () {
      const invalidSessionId = 999; // Define an invalid session ID

      await expect(
        votingManager.closeVotingSession(invalidSessionId)
      ).to.be.revertedWith("Voting session is not active"); // Check if the transaction is reverted
    });

    // Should not allow closing an already closed session
    it("Should not allow closing an already closed session", async function () {
      await votingManager.closeVotingSession(sessionId); // Close the session

      // Try to close the same session again
      await expect(
        votingManager.closeVotingSession(sessionId)
      ).to.be.revertedWith("Voting session is not active"); // Check if the transaction is reverted
    });
  });

  // A describe block for getting vote counts
  describe("Getting Vote Counts", function () {
    const sessionId = 1;
    const sessionName = "Test Session";
    const candidateCount = 3;

    beforeEach(async function () {
      const currentBlock = await ethers.provider.getBlock("latest"); // Get the latest block
      const startTime = currentBlock.timestamp; // Set the start time to the current block timestamp
      const endTime = startTime + 3600; // Set the end time to 1 hour after the start time

      await votingManager.createVotingSession(
        sessionName,
        startTime,
        endTime,
        candidateCount
      ); // Create a voting session

      // Set up the mock verifier to return true for the proof
      await mockVerifier.setVerificationResult(true); // Set the verification result to true

      // Cast some votes for testing
      await votingManager
        .connect(voter1)
        .castVote(
          sessionId,
          1,
          123456,
          mockProof.a,
          mockProof.b,
          mockProof.c,
          mockProof.publicSignals
        ); // Cast a vote for candidate 1
      await votingManager
        .connect(voter2)
        .castVote(
          sessionId,
          2,
          789012,
          mockProof.a,
          mockProof.b,
          mockProof.c,
          mockProof.publicSignals
        ); // Cast a vote for candidate 2
      await votingManager
        .connect(voter1)
        .castVote(
          sessionId,
          2,
          345678,
          mockProof.a,
          mockProof.b,
          mockProof.c,
          mockProof.publicSignals
        ); // Cast a vote for candidate 2
    });

    // Should return the correct vote count for the candidates
    it("Should return the correct vote count for the candidates", async function () {
      expect(await votingManager.getVoteCount(sessionId, 1)).to.equal(1); // Check the vote count for candidate 1
      expect(await votingManager.getVoteCount(sessionId, 2)).to.equal(2); // Check the vote count for candidate 2
      expect(await votingManager.getVoteCount(sessionId, 3)).to.equal(0); // Check the vote count for candidate 3
    });

    // Should fail when getting vote count for invalid candidate
    it("Should fail when getting vote count for invalid candidate", async function () {
      await expect(votingManager.getVoteCount(sessionId, 0)).to.be.revertedWith(
        "Invalid candidate index"
      ); // Check if the error is thrown for invalid candidate index
      await expect(
        votingManager.getVoteCount(sessionId, candidateCount + 1)
      ).to.be.revertedWith("Invalid candidate index"); // Check if the error is thrown for invalid candidate index
    });

    // Should return vote counts even after closing the session
    it("Should return vote counts even after closing the session", async function () {
      await votingManager.closeVotingSession(sessionId); // Close the session

      expect(await votingManager.getVoteCount(sessionId, 1)).to.equal(1); // Check the vote count for candidate 1
      expect(await votingManager.getVoteCount(sessionId, 2)).to.equal(2); // Check the vote count for candidate 2
      expect(await votingManager.getVoteCount(sessionId, 3)).to.equal(0); // Check the vote count for candidate 3
    });
  });
});

// Integration test for the entire voting process with the real verifier contract
describe("Integration Test with Real Verifier", function () {
  let VotingManager;
  let votingManager;
  let Groth16Verifier;
  let verifier;
  let admin;
  let voter1;
  let voter2;
  let nonAdmin;
  const sessionId = 1;
  const sessionName = "Test Session";
  const candidateCount = 3;
  const candidateId = 1;
  const nullifier = 123456;
  let realProof; // Variable to store the real proof
  let realPublicSignals; // Variable to store the real public signals

  // Paths to the necessary files
  const circuitPath = path.join(__dirname, "../../circuits/voting.circom"); // path to the voting.circom circuit
  const wasmPath = path.join(__dirname, "../../voting_js/voting.wasm"); // path to the wasm file
  const zkeyPath = path.join(__dirname, "../../keys/voting_0001.zkey"); // path to the zkey file

  before(async function () {
    // Deploy the real verifier contract
    Groth16Verifier = await ethers.getContractFactory("Groth16Verifier");
    verifier = await Groth16Verifier.deploy(); // Deploy the contract
    await verifier.waitForDeployment(); // Wait for the contract to be deployed

    // Deploy the VotingManager contract
    VotingManager = await ethers.getContractFactory("VotingManager");
    [admin, voter1, voter2, nonAdmin] = await ethers.getSigners(); // Get the signers
    votingManager = await VotingManager.deploy(verifier.target); // Deploy the contract with the verifier address
    await votingManager.waitForDeployment(); // Wait for the contract to be deployed

    // Compile the circuit
    console.log("Compiling the circuit...");
    execSync(`circom ${circuitPath} --r1cs --wasm --sym`, {
      stdio: "inherit",
    }); // Compile the circuit

    // Generate the valid proof
    console.log("Generating the proof...");
    const generatedVoteCommitment = await generateVoteCommitment(); // Generate the vote commitment
    const { proof, publicSignals } = await snarkjs.groth16.fullProve(
      {
        vote: 1,
        randomness: 123456789,
        voteCommitment: generatedVoteCommitment,
      },
      wasmPath,
      zkeyPath
    ); // Generate the proof using snarkjs

    realProof = {
      a: [proof.pi_a[0], proof.pi_a[1]],
      b: [
        [proof.pi_b[0][1], proof.pi_b[0][0]],
        [proof.pi_b[1][1], proof.pi_b[1][0]],
      ],
      c: [proof.pi_c[0], proof.pi_c[1]],
    };

    realPublicSignals = [publicSignals[0]]; // Store the public signals
  });

  // a beforeEach hook
  beforeEach(async function () {
    const currentBlock = await ethers.provider.getBlock("latest"); // Get the latest block
    const startTime = currentBlock.timestamp; // Set the start time to the current block timestamp
    const endTime = startTime + 3600; // Set the end time to 1 hour after the start time

    // Create a voting session
    await votingManager.createVotingSession(
      sessionName,
      startTime,
      endTime,
      candidateCount
    ); // Create a voting session
  });

  // Should allow casting a vote with valid proof using the real verifier
  it("Should allow casting a vote with valid proof using the real verifier", async function () {
    // Create own copy of the proof to avoid modifying the original proof
    const realProofCopy = {
      a: [...realProof.a],
      b: [...realProof.b.map((b) => [...b])],
      c: [...realProof.c],
    };
    const realPublicSignalsCopy = [...realPublicSignals];

    await expect(
      votingManager
        .connect(voter1)
        .castVote(
          sessionId,
          candidateId,
          nullifier,
          realProofCopy.a,
          realProofCopy.b,
          realProofCopy.c,
          realPublicSignalsCopy
        )
    )
      .to.emit(votingManager, "VoteCast")
      .withArgs(sessionId, candidateId, nullifier); // Check if the event is emitted

    expect(await votingManager.getVoteCount(sessionId, candidateId)).to.equal(
      1
    ); // Check if the vote count is incremented
  });

  // Should not allow casting a vote with invalid proof using the real verifier
  it("Should not allow casting a vote with invalid proof using the real verifier", async function () {
    // Create own copy of the proof to avoid modifying the original proof
    const realProofCopy = {
      a: [...realProof.a],
      b: [...realProof.b.map((b) => [...b])],
      c: [...realProof.c],
    };
    const realPublicSignalsCopy = [...realPublicSignals];

    // Modify the proof to make it invalid
    realProofCopy.a[0] = BigInt(realProofCopy.a[0]) + BigInt(1); // Change the first element of the proof

    await expect(
      votingManager
        .connect(voter1)
        .castVote(
          sessionId,
          candidateId,
          nullifier,
          realProofCopy.a,
          realProofCopy.b,
          realProofCopy.c,
          realPublicSignalsCopy
        )
    ).to.be.revertedWith("Invalid proof"); // Check if the voting is reverted
  });
});

async function generateVoteCommitment() {
  // Initializing the poseidon hash function
  const poseidon = await circomlib.buildPoseidon();
  const F = poseidon.F; // the finite field

  // Compute the hash using the inputs (vote, randomness) = (2, 123456789)
  const hash = poseidon([1, 123456789]);

  // Return the hash
  return F.toString(hash);
}
