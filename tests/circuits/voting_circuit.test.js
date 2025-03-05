/** This file is for testing the voting.circom circuit to ensure it is working. */

const { expect } = require("chai"); // importing the expect function from the chai library (for assertions)
const { execSync } = require("child_process"); // importing the execSync function from the child_process module (for running shell commands)
const fs = require("fs"); // importing the fs module (for interacting with the file system)
const path = require("path"); // importing the path module (for working with file and directory paths)
const circomlib = require("circomlibjs"); // importing the circomlib module (for the poseidon hash function)
const ffjavascript = require("ffjavascript"); // importing the ffjavascript module (for finite field operations)

// describe() is a Mocha function that groups tests together
// The first argument is the description of the test group
// The second argument is a callback function that contains the individual tests
describe("Voting Circuit Test", function () {
  this.timeout(10000); // set timeout to 10 seconds

  // Defining the various paths required to run the tests
  const circomPath = path.join(__dirname, "../../circuits/voting.circom"); // path to the voting.circom circuit
  const inputPath = path.join(__dirname, "voting_input.json"); // path to the input JSON file
  const witnessPath = path.join(__dirname, "voting.wtns"); // path to the witness file
  const proofPath = path.join(__dirname, "voting_proof.json"); // path to the proof JSON file
  const publicPath = path.join(__dirname, "voting_public.json"); // path to the public JSON file
  const verificationKeyPath = path.join(__dirname, "verification_key.json"); // path to the verification key JSON file

  // before() is a Mocha function that is run once before all tests
  before(async function () {
    // Compile the circuit
    console.log("Compiling the circuit...");
    execSync(`circom ${circomPath} --r1cs --wasm --sym`, { stdio: "inherit" });

    // Generate the input JSON file
    console.log("Generating the input JSON file...");
    const generatedVoteCommitment = await generateVoteCommitment();
    fs.writeFileSync(
      inputPath,
      JSON.stringify(
        {
          vote: 1,
          randomness: 123456789,
          voteCommitment: generatedVoteCommitment,
        },
        null,
        2
      )
    );

    // Generate the witness file
    console.log("Generating the witness file...");
    execSync(
      `node ${path.join(
        __dirname,
        "../../circuits/voting_js/generate_witness.js"
      )} ${path.join(
        __dirname,
        "../../circuits/voting_js/voting.wasm"
      )} ${inputPath} ${witnessPath}`,
      { stdio: "inherit" }
    );

    // Generate the proof
    console.log("Generating the proof...");
    execSync(
      `snarkjs groth16 prove ${path.join(
        __dirname,
        "../../keys/voting_0001.zkey"
      )} ${witnessPath} ${proofPath} ${publicPath}`,
      { stdio: "inherit" }
    );
  });

  it("should verify the proof", function () {
    // Verify the proof
    console.log("Verifying the proof...");
    const result = execSync(
      `snarkjs groth16 verify ${verificationKeyPath} ${publicPath} ${proofPath}`,
      { encoding: "utf-8" }
    );
    expect(result).to.include("OK");
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
