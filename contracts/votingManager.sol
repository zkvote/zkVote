// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; // Specify the Solidity version

/// @dev Interface for the generated verifier contract
interface IVerifier {
    function verifyProof(
        uint[2] calldata _pA, // Proof A parameter
        uint[2][2] calldata _pB, // Proof B parameter
        uint[2] calldata _pC, // Proof C parameter
        uint[1] calldata _pubSignals // Public signals (voteCommitment)
    ) external view returns (bool); // Returns true if the proof is valid (false otherwise)
}

// Voting Manager contract
contract VotingManager {
    // Admin address (which is set to the deployer of the contract)
    address public admin;

    // Instance of the verifier contract (IVerifier)
    IVerifier public verifier;

    // Struct for a voting session
    struct VotingSession {
        uint256 id; // Unique identifier for the voting session
        string name; // Name of the voting session
        uint256 startTime; // Start time of the voting session
        uint256 endTime; // End time of the voting session
        bool isActive; // Indicates if the voting session is active
        uint256 candidateCount; // Number of candidates in the voting session
        // Mapping from candidate index (1-indexed) to vote count
        mapping(uint256 => uint256) votes; // Vote count for each candidate
        // Mapping to store used nullifiers to prevent double voting
        mapping(uint256 => bool) usedNullifiers; // Used nullifiers
    }

    // Mapping from voting session ID to VotingSession struct
    mapping(uint256 => VotingSession) public votingSessions;
    uint256 public votingSessionCount; // Total number of voting sessions

    // Event emitted when a new voting session is created
    event VotingSessionCreated(uint256 indexed sessionId, string name, uint256 startTime, uint256 endTime);
    // Event emitted when a vote is cast
    event VoteCast(uint256 indexed sessionId, uint256 candidate, uint256 nullifier);
    // Event emitted when a voting session is ended
    event VotingSessionEnded(uint256 indexed sessionId);

    // Modifier to restrict access to the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
    // Modifier to restrict access to the voting session
    modifier onlyActiveSession(uint256 _sessionId) {
        require(votingSessions[_sessionId].isActive, "Voting session is not active");
        _;
    }
    // Modifier to restrict access to the voting session time
    modifier onlyDuringVoting(uint256 _sessionId) {
        require(block.timestamp >= votingSessions[_sessionId].startTime && block.timestamp <= votingSessions[_sessionId].endTime, "Voting session is not active");
        _;
    }

    // Constructor to initialize the contract with the verifier address and set the admin to the deployer
    constructor(address _verifier) {
        verifier = IVerifier(_verifier); // Set the verifier contract address
        admin = msg.sender; // Set the admin to the deployer of the contract
    }
    
    /// @notice Creates a new voting session.
    /// @param _name Name of the voting session
    /// @param _startTime Unix timestamp for the start time of the voting session
    /// @param _endTime Unix timestamp for the end time of the voting session
    /// @param _candidateCount Number of candidates in the voting session
    function createVotingSession(string calldata _name, uint256 _startTime, uint256 _endTime, uint256 _candidateCount) external onlyAdmin {
        require(_startTime < _endTime, "Start time must be before end time"); // Ensure start time is before end time
        require(_candidateCount > 0, "Candidate count must be greater than 0"); // Ensure candidate count is greater than 0

        votingSessionCount++; // Increment the voting session count
        VotingSession storage session = votingSessions[votingSessionCount]; // Create a new voting session
        session.id = votingSessionCount; // Set the ID of the voting session
        session.name = _name; // Set the name of the voting session
        session.startTime = _startTime; // Set the start time of the voting session
        session.endTime = _endTime; // Set the end time of the voting session
        session.isActive = true; // Set the voting session as active
        session.candidateCount = _candidateCount; // Set the number of candidates
        
        for(uint256 i = 1; i <= _candidateCount; i++) {
            session.votes[i] = 0; // Initialize vote count for each candidate to 0
            session.usedNullifiers[i] = false; // Initialize used nullifiers for each candidate to false
        }

        emit VotingSessionCreated(votingSessionCount, _name, _startTime, _endTime); // Emit event for new voting session creation
    }

    /// @notice Casts a vote for a candidate in a voting session with a valid zk-SNARK proof.
    /// @param _sessionId ID of the voting session
    /// @param _candidate Index of the candidate to vote for
    /// @param _nullifier Unique identifier for the vote (to prevent double voting)
    /// @param _pA Proof A parameter
    /// @param _pB Proof B parameter
    /// @param _pC Proof C parameter
    /// @param _pubSignals Public signals (vote commitment)
    function castVote(
        uint256 _sessionId,
        uint256 _candidate,
        uint256 _nullifier,
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[1] calldata _pubSignals
    ) external onlyActiveSession(_sessionId) onlyDuringVoting(_sessionId) {
        require(msg.sender != address(0), "Invalid voter address"); // Ensure the voter address is valid
        require(verifier.verifyProof(_pA, _pB, _pC, _pubSignals), "Invalid proof"); // Verify the zk-SNARK proof (using the verifier contract)
        require(!votingSessions[_sessionId].usedNullifiers[_nullifier], "Vote already cast with this nullifier"); // Ensure the nullifier has not been used before
        
        votingSessions[_sessionId].usedNullifiers[_nullifier] = true; // Mark the nullifier as used to prevent double voting
        votingSessions[_sessionId].votes[_candidate] += 1; // Increment the vote count for the candidate
        
        emit VoteCast(_sessionId, _candidate, _nullifier); // Emit event for vote cast
    }

    /// @notice Allows the admin to end a voting session.
    /// @param _sessionId ID of the voting session to end
    function closeVotingSession(uint256 _sessionId) external onlyAdmin onlyActiveSession(_sessionId) {
        votingSessions[_sessionId].isActive = false; // Mark the voting session as inactive
        emit VotingSessionEnded(_sessionId); // Emit event to indicate the session is ended
    }

    /// @notice Returns the vote count for a candidate in a voting session.
    /// @param _sessionId ID of the voting session
    /// @param _candidate Index of the candidate
    /// @return The vote count for the candidate
    function getVoteCount(uint256 _sessionId, uint256 _candidate) external view returns (uint256) {
        require(_candidate > 0 && _candidate <= votingSessions[_sessionId].candidateCount, "Invalid candidate index"); // Ensure the candidate index is valid
        return votingSessions[_sessionId].votes[_candidate]; // Return the vote count for the candidate
    }

}