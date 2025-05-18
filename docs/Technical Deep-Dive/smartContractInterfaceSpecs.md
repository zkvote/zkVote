# zkVote: Smart Contract Interface Specifications

**Document ID:** ZKV-INTF-2025-002  
**Version:** 1.1

## Table of Contents

1. [Introduction](#1-introduction)
2. [Core Voting Protocol Interfaces](#2-core-voting-protocol-interfaces)
3. [Zero-Knowledge Verification Interfaces](#3-zero-knowledge-verification-interfaces)
4. [Delegation Protocol Interfaces](#4-delegation-protocol-interfaces)
5. [Cross-Chain Bridge Interfaces](#5-cross-chain-bridge-interfaces)
6. [Identity and Eligibility Interfaces](#6-identity-and-eligibility-interfaces)
7. [Result Aggregation Interfaces](#7-result-aggregation-interfaces)
8. [Governance Integration Interfaces](#8-governance-integration-interfaces)
9. [EIP-712 Structured Data Signing](#9-eip-712-structured-data-signing)
10. [Transient Storage Patterns](#10-transient-storage-patterns)
11. [IR Optimization Guidelines](#11-ir-optimization-guidelines)
12. [Events and Error Specifications](#12-events-and-error-specifications)
13. [Security Considerations](#13-security-considerations)
14. [Implementation Guidelines](#14-implementation-guidelines)
15. [Appendices](#15-appendices)

## 1. Introduction

### 1.1 Purpose

This document specifies the smart contract interfaces for the zkVote protocol. These interfaces define the programmatic boundaries between the protocol's components and establish the standard methods for interaction. The specification has been updated to incorporate Solidity 1.0.0 requirements, EIP-712 structured data signing, transient storage patterns, and IR optimization guidelines.

### 1.2 Scope

This specification covers the following contract interfaces:

- Core voting protocol contracts
- Zero-knowledge proof verification contracts
- Delegation protocol contracts
- Cross-chain bridge contracts
- Identity and eligibility verification contracts
- Result aggregation contracts
- Governance integration contracts
- EIP-712 structured data signing interfaces
- Hardware Security Module (HSM) integration patterns
- Cross-chain validation and PeerDAS integration
- Account abstraction integration (EIP-4337/EIP-7702)
- BLS signature verification (EIP-2537)

The document focuses on interface specifications rather than implementation details, establishing a standard that various implementations must adhere to.

### 1.3 Intended Audience

- Protocol Developers
- Integration Partners
- Auditors
- DAO Developers
- Blockchain Engineers
- Governance Specialists
- Compliance Officers
- Security Analysts

### 1.4 Terminology

| Term                        | Definition                                                                                           |
| --------------------------- | ---------------------------------------------------------------------------------------------------- |
| **Interface**               | A set of function signatures that define the contract's public API                                   |
| **ABI**                     | Application Binary Interface - the standard way to interact with contracts in the Ethereum ecosystem |
| **View Function**           | A function that reads but does not modify the contract state                                         |
| **Call Function**           | A function that may modify the contract state                                                        |
| **Event**                   | Logged information that can be subscribed to and filtered                                            |
| **Modifier**                | Function modifier that changes the behavior of a function                                            |
| **Transient Storage**       | Non-persistent storage that exists only during transaction execution                                 |
| **Domain Separator**        | A unique identifier for a contract to prevent cross-contract replay attacks in EIP-712               |
| **Structured Data Signing** | A standard for signing typed data with explicit type information (EIP-712)                           |
| **IR Optimization**         | Intermediate Representation optimizations for improved gas efficiency                                |
| **Data Availability**       | The property ensuring blockchain data is publicly available and verifiable                           |
| **Account Abstraction**     | A system allowing user accounts to have arbitrary validation logic                                   |

### 1.5 Compliance and Standard Adherence

| Standard | Description                                       | Implementation Status |
| -------- | ------------------------------------------------- | --------------------- |
| EIP-712  | Typed structured data signing                     | Required              |
| EIP-1202 | Voting standard interface                         | Required              |
| EIP-1271 | Standard signature validation for smart contracts | Required              |
| EIP-2535 | Diamond standard for modular contracts            | Recommended           |
| EIP-2537 | BLS precompile                                    | Optional              |
| EIP-2935 | Historical storage access                         | Optional              |
| EIP-4337 | Account abstraction via entrypoint                | Recommended           |
| EIP-6865 | Message visualization standard                    | Required              |
| EIP-7251 | Enhanced staking interface                        | Optional              |
| EIP-7594 | PeerDAS integration                               | Recommended           |
| EIP-7691 | Blob throughput expansion                         | Recommended           |
| EIP-7702 | Account abstraction improvements                  | Recommended           |
| EIP-7713 | Box type support                                  | Recommended           |
| EIP-7803 | Signing domains                                   | Required              |
| GDPR     | General Data Protection Regulation                | Required              |

## 2. Core Voting Protocol Interfaces

### 2.1 IVoteFactory Interface

Interface for creating and managing voting instances. Updated to support EIP-712 and transient storage.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVoteFactory {
    /// @notice Creates a new voting instance
    /// @param votingParams Parameters for the voting instance
    /// @param eligibilityRoot Merkle root of eligible voters
    /// @param proposalData IPFS hash or other identifier for proposal data
    /// @param votingOptions Array of voting options
    /// @return voteId Unique identifier for the created vote
    function createVote(
        VotingParameters calldata votingParams,
        bytes32 eligibilityRoot,
        bytes32 proposalData,
        bytes32[] calldata votingOptions
    ) external returns (bytes32 voteId);

    /// @notice Returns information about a specific vote
    /// @param voteId Identifier of the vote to query
    /// @return vote Information about the vote
    function getVote(bytes32 voteId) external view returns (VoteInfo memory vote);

    /// @notice Returns the list of active votes
    /// @return activeVotes Array of vote identifiers
    function getActiveVotes() external view returns (bytes32[] memory activeVotes);

    /// @notice Finalizes a vote after the voting period has ended
    /// @param voteId Identifier of the vote to finalize
    /// @return success Whether the finalization was successful
    function finalizeVote(bytes32 voteId) external returns (bool success);

    /// @notice Checks if a vote exists
    /// @param voteId Identifier of the vote to check
    /// @return exists Whether the vote exists
    function voteExists(bytes32 voteId) external view returns (bool exists);

    /// @notice Returns the domain separator for EIP-712 typed data signing
    /// @return domainSeparator The domain separator hash
    function getDomainSeparator() external view returns (bytes32 domainSeparator);

    /// @notice Emitted when a new vote is created
    event VoteCreated(
        bytes32 indexed voteId,
        address indexed creator,
        uint256 startTime,
        uint256 endTime,
        bytes32 eligibilityRoot,
        bytes32 proposalData
    );

    /// @notice Emitted when a vote is finalized
    event VoteFinalized(
        bytes32 indexed voteId,
        bytes32 resultHash,
        bool passed,
        uint256 finalizationTime
    );

    /// @notice Parameters for creating a voting instance
    struct VotingParameters {
        uint256 startTime;
        uint256 endTime;
        uint32 votingThreshold;
        uint8 votingType;        // 0: binary, 1: ranked choice, 2: quadratic
        uint8 privacyLevel;      // 0: public, 1: semi-private, 2: fully private
        bool delegationAllowed;
        address coordinator;     // Optional voting coordinator for certain privacy modes
        bool crossChainEnabled;  // Whether cross-chain voting is enabled
        bytes32[] eligibleChains; // Chains eligible for cross-chain voting
    }

    /// @notice Information about a vote
    struct VoteInfo {
        bytes32 voteId;
        address creator;
        VotingParameters params;
        bytes32 eligibilityRoot;
        bytes32 proposalData;
        bytes32[] votingOptions;
        uint256 totalVotesCast;
        bool finalized;
        bytes32 resultHash;      // Hash of the results
        bool passed;
    }
}
```

`````

### 2.2 IVoteProcessor Interface

Interface for processing vote submissions and validation. Updated to support EIP-1202, privacy-preserving function overloads, and GDPR compliance.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVoteProcessor {
    /// @notice Submit a vote
    /// @param voteId Identifier of the vote
    /// @param voteCommitment Commitment to the vote choice(s)
    /// @param weightCommitment Commitment to the voting weight
    /// @param nullifier Nullifier to prevent double voting
    /// @param zkProof Zero-knowledge proof of vote validity
    /// @return success Whether the vote was successfully submitted
    function submitVote(
        bytes32 voteId,
        bytes32 voteCommitment,
        bytes32 weightCommitment,
        bytes32 nullifier,
        bytes calldata zkProof
    ) external returns (bool success);

    /// @notice Submit a private vote using Ariadne protocol (Groth16 proofs)
    /// @param voteId Identifier of the vote
    /// @param proof_a First part of the Groth16 proof
    /// @param proof_b Second part of the Groth16 proof
    /// @param proof_c Third part of the Groth16 proof
    /// @param input Public inputs for the proof
    /// @return success Whether the vote was successfully submitted
    function castPrivateVote(
        bytes32 voteId,
        uint256[2] calldata proof_a,
        uint256[2][2] calldata proof_b,
        uint256[2] calldata proof_c,
        uint256[4] calldata input
    ) external returns (bool success);

    /// @notice Cast a vote using Hardware Security Module (HSM)
    /// @param voteId Identifier of the vote
    /// @param hsmSignature HSM signature of vote data
    /// @param weight Voting weight
    /// @return success Whether the vote was successfully submitted
    function castHSMVote(
        bytes32 voteId,
        bytes calldata hsmSignature,
        uint256 weight
    ) external returns (bool success);

    /// @notice Submit a vote from a cross-chain source
    /// @param vote Cross-chain vote data structure
    /// @return success Whether the vote was successfully submitted
    function submitCrossChainVote(CrossChainVote calldata vote) external returns (bool success);

    /// @notice Submit a batch of votes
    /// @param voteId Identifier of the vote
    /// @param voteData Array of vote data structs
    /// @param batchProof Proof for the validity of the batch
    /// @return success Whether the batch was successfully submitted
    function submitVoteBatch(
        bytes32 voteId,
        VoteData[] calldata voteData,
        bytes calldata batchProof
    ) external returns (bool success);

    /// @notice ERC-1202 compliant voting interface
    /// @param proposalId Identifier of the proposal
    /// @param support Support choice (0: against, 1: for, 2: abstain)
    /// @param weight Voting weight
    /// @param reasonUri URI for the voting reason
    /// @param extraParams Additional parameters
    function castVote(
        uint256 proposalId,
        uint8 support,
        uint256 weight,
        string calldata reasonUri,
        bytes calldata extraParams
    ) external payable;

    /// @notice Check if a nullifier has been used
    /// @param nullifier The nullifier to check
    /// @return used Whether the nullifier has been used
    function isNullifierUsed(bytes32 nullifier) external view returns (bool used);

    /// @notice Get the current vote count for a voting instance
    /// @param voteId Identifier of the vote
    /// @return count The number of votes cast
    function getVoteCount(bytes32 voteId) external view returns (uint256 count);

    /// @notice Check if voting is active
    /// @param voteId Identifier of the vote
    /// @return active Whether voting is currently active
    function isVotingActive(bytes32 voteId) external view returns (bool active);

    /// @notice GDPR-compliant function to forget a vote
    /// @dev Only callable by authorized data controllers
    /// @param voter Address of the voter
    /// @return success Whether the vote data was successfully erased
    function forgetVote(address voter) external returns (bool success);

    /// @notice Emitted when a vote is submitted
    event VoteSubmitted(
        bytes32 indexed voteId,
        bytes32 indexed nullifier,
        bytes32 voteCommitment,
        uint256 timestamp
    );

    /// @notice Emitted when a batch of votes is submitted
    event VoteBatchSubmitted(
        bytes32 indexed voteId,
        uint256 batchSize,
        bytes32 batchRoot,
        uint256 timestamp
    );

    /// @notice Emitted when a vote is forgotten (GDPR compliance)
    event VoteForgotten(
        address indexed voter,
        uint256 blockNumber,
        uint256 timestamp
    );

    /// @notice Data structure for a single vote
    struct VoteData {
        bytes32 voteCommitment;
        bytes32 weightCommitment;
        bytes32 nullifier;
        bytes zkProof;
    }

    /// @notice Data structure for a cross-chain vote
    struct CrossChainVote {
        uint256 originChainId;
        address voter;
        bytes32 voteId;
        bytes32 voteCommitment;
        bytes32 nullifier;
        bytes32 proof;
    }
}
```

### 2.3 IVoteResultManager Interface

Interface for managing and querying voting results. Updated with GDPR compliance and advanced result handling capabilities.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVoteResultManager {
    /// @notice Register the results of a completed vote
    /// @param voteId Identifier of the vote
    /// @param resultData Encrypted or plaintext result data depending on privacy settings
    /// @param resultProof Proof that the results are correctly computed
    /// @return success Whether the results were successfully registered
    function registerResults(
        bytes32 voteId,
        bytes calldata resultData,
        bytes calldata resultProof
    ) external returns (bool success);

    /// @notice Get the results of a finalized vote
    /// @param voteId Identifier of the vote
    /// @return resultData The result data
    /// @return resultHash Hash of the results
    /// @return finalized Whether the vote is finalized
    function getResults(bytes32 voteId) external view returns (
        bytes memory resultData,
        bytes32 resultHash,
        bool finalized
    );

    /// @notice Submit a partial decryption share for encrypted results (for threshold decryption)
    /// @param voteId Identifier of the vote
    /// @param decryptionShare The partial decryption share
    /// @param verificationProof Proof that the decryption share is correctly computed
    /// @return success Whether the decryption share was accepted
    function submitDecryptionShare(
        bytes32 voteId,
        bytes calldata decryptionShare,
        bytes calldata verificationProof
    ) external returns (bool success);

    /// @notice Combine decryption shares to reveal the results
    /// @param voteId Identifier of the vote
    /// @param decryptionShares Array of decryption shares
    /// @param combinationProof Proof that the shares are correctly combined
    /// @return resultData The plaintext result data
    function combineDecryptionShares(
        bytes32 voteId,
        bytes[] calldata decryptionShares,
        bytes calldata combinationProof
    ) external returns (bytes memory resultData);

    /// @notice Check if a vote result is verified
    /// @param voteId Identifier of the vote
    /// @return verified Whether the result has been verified
    function isResultVerified(bytes32 voteId) external view returns (bool verified);

    /// @notice GDPR-compliant function to anonymize result details
    /// @dev Only callable by authorized data controllers
    /// @param voteId Identifier of the vote
    /// @return success Whether the anonymization was successful
    function anonymizeResults(bytes32 voteId) external returns (bool success);

    /// @notice Get human-readable visualization of the results
    /// @param voteId Identifier of the vote
    /// @return title Title of the results visualization
    /// @return fields Array of field names
    /// @return values Array of field values
    function visualizeResults(bytes32 voteId) external view returns (
        string memory title,
        string[] memory fields,
        string[] memory values
    );

    /// @notice Emitted when results are registered
    event ResultsRegistered(
        bytes32 indexed voteId,
        bytes32 resultHash,
        address registrar,
        uint256 timestamp
    );

    /// @notice Emitted when a decryption share is submitted
    event DecryptionShareSubmitted(
        bytes32 indexed voteId,
        address indexed shareholder,
        uint256 shareIndex,
        uint256 timestamp
    );

    /// @notice Emitted when results are decrypted
    event ResultsDecrypted(
        bytes32 indexed voteId,
        bytes32 plaintextResultHash,
        uint256 timestamp
    );

    /// @notice Emitted when results are anonymized (GDPR compliance)
    event ResultsAnonymized(
        bytes32 indexed voteId,
        uint256 timestamp
    );

    /// @notice Result status enum
    enum ResultStatus {
        NotFinalized,
        Finalized,
        Decrypting,
        Decrypted,
        Anonymized
    }
}
```

## 3. Zero-Knowledge Verification Interfaces

### 3.1 IZKVerifier Interface

Interface for verifying zero-knowledge proofs in the voting protocol. Updated with Groth16 support and BLS verification.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IZKVerifier {
    /// @notice Verify a zero-knowledge proof
    /// @param proofType Type of proof being verified
    /// @param publicInputs Array of public inputs to the verification
    /// @param proof The zero-knowledge proof data
    /// @return valid Whether the proof is valid
    function verifyProof(
        uint8 proofType,
        bytes32[] calldata publicInputs,
        bytes calldata proof
    ) external view returns (bool valid);

    /// @notice Verify a Groth16 zero-knowledge proof
    /// @param proof_a First part of the Groth16 proof
    /// @param proof_b Second part of the Groth16 proof
    /// @param proof_c Third part of the Groth16 proof
    /// @param input Public inputs for the proof
    /// @return valid Whether the proof is valid
    function verifyGroth16Proof(
        uint256[2] calldata proof_a,
        uint256[2][2] calldata proof_b,
        uint256[2] calldata proof_c,
        uint256[] calldata input
    ) external view returns (bool valid);

    /// @notice Verify a batch of proofs
    /// @param proofTypes Array of proof types
    /// @param publicInputsBatch Array of arrays of public inputs
    /// @param proofs Array of proofs
    /// @return validProofs Array indicating which proofs are valid
    function verifyProofBatch(
        uint8[] calldata proofTypes,
        bytes32[][] calldata publicInputsBatch,
        bytes[] calldata proofs
    ) external view returns (bool[] memory validProofs);

    /// @notice Verify a batch of BLS signatures (EIP-2537)
    /// @param pubkeys Array of public keys
    /// @param messages Array of messages
    /// @param signature Aggregated signature
    /// @return valid Whether the signature batch is valid
    function verifyBLSBatch(
        uint256[2][] calldata pubkeys,
        bytes32[] calldata messages,
        uint256[2] calldata signature
    ) external view returns (bool valid);

    /// @notice Get verification key for a specific proof type
    /// @param proofType Type of proof
    /// @return verificationKey The verification key
    function getVerificationKey(uint8 proofType) external view returns (bytes memory verificationKey);

    /// @notice Update the verification key for a proof type (admin function)
    /// @param proofType Type of proof
    /// @param newVerificationKey New verification key
    /// @return success Whether the update was successful
    function updateVerificationKey(
        uint8 proofType,
        bytes calldata newVerificationKey
    ) external returns (bool success);

    /// @notice Verify a proof with Data Availability Sampling (PeerDAS)
    /// @param proofType Type of proof
    /// @param dataRoot Root of the data being verified
    /// @param proof The proof data
    /// @param dasSamplingProof Proof of data availability
    /// @return valid Whether the proof is valid
    function verifyProofWithDAS(
        uint8 proofType,
        bytes32 dataRoot,
        bytes calldata proof,
        bytes calldata dasSamplingProof
    ) external view returns (bool valid);

    /// @notice Proof types used in the protocol
    enum ProofType {
        VoteValidity,        // Proves vote is valid
        VoterEligibility,    // Proves voter is eligible
        DelegationValidity,  // Proves delegation is valid
        ResultCorrectness,   // Proves results are correctly computed
        DecryptionValidity,  // Proves decryption share is valid
        BLSAggregation,      // Proves BLS signature aggregation
        Groth16Proof,        // Standard Groth16 proof
        AriadneVote,         // Ariadne protocol private vote
        PeerDASProof         // Data availability proof
    }

    /// @notice Emitted when a verification key is updated
    event VerificationKeyUpdated(
        uint8 indexed proofType,
        address updater,
        uint256 timestamp
    );
}
```

### 3.2 ICircuitRegistry Interface

Interface for managing the circuit registry and verification keys. Updated with type registry and advanced circuit management.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICircuitRegistry {
    /// @notice Register a new circuit
    /// @param circuitId Unique identifier for the circuit
    /// @param description Human-readable description of the circuit
    /// @param verificationKey Verification key for the circuit
    /// @return success Whether registration was successful
    function registerCircuit(
        bytes32 circuitId,
        string calldata description,
        bytes calldata verificationKey
    ) external returns (bool success);

    /// @notice Get information about a circuit
    /// @param circuitId Identifier of the circuit
    /// @return info Information about the circuit
    function getCircuit(bytes32 circuitId) external view returns (CircuitInfo memory info);

    /// @notice Check if a circuit is registered
    /// @param circuitId Identifier of the circuit
    /// @return registered Whether the circuit is registered
    function isCircuitRegistered(bytes32 circuitId) external view returns (bool registered);

    /// @notice Get all registered circuit IDs
    /// @return circuitIds Array of circuit identifiers
    function getAllCircuitIds() external view returns (bytes32[] memory circuitIds);

    /// @notice Update a circuit's verification key (with proper access control)
    /// @param circuitId Identifier of the circuit
    /// @param newVerificationKey New verification key
    /// @return success Whether the update was successful
    function updateCircuitVerificationKey(
        uint8 circuitId,
        bytes calldata newVerificationKey
    ) external returns (bool success);

    /// @notice Register a type hash for EIP-712 structured data
    /// @param typeString String representation of the type
    /// @return typeHash The computed type hash
    function registerTypeHash(
        string calldata typeString
    ) external returns (bytes32 typeHash);

    /// @notice Check if a type hash is registered
    /// @param typeHash The type hash to check
    /// @return registered Whether the type hash is registered
    function isTypeHashRegistered(bytes32 typeHash) external view returns (bool registered);

    /// @notice Visualize a circuit's purpose and structure (EIP-6865)
    /// @param circuitId Identifier of the circuit
    /// @return title Title of the visualization
    /// @return fields Array of field names
    /// @return values Array of field values
    function visualizeCircuit(bytes32 circuitId) external view returns (
        string memory title,
        string[] memory fields,
        string[] memory values
    );

    /// @notice Information about a circuit
    struct CircuitInfo {
        bytes32 circuitId;
        string description;
        bytes verificationKey;
        address registrar;
        uint256 registrationTime;
        uint256 lastUpdated;
        bool active;
        string versionTag;      // Semantic version of the circuit
        uint32 constraintCount; // Number of constraints in the circuit
        bytes32[] associatedTypeHashes; // Associated EIP-712 type hashes
    }

    /// @notice Emitted when a circuit is registered
    event CircuitRegistered(
        bytes32 indexed circuitId,
        address indexed registrar,
        uint256 timestamp
    );

    /// @notice Emitted when a circuit verification key is updated
    event CircuitUpdated(
        bytes32 indexed circuitId,
        address indexed updater,
        uint256 timestamp
    );

    /// @notice Emitted when a type hash is registered
    event TypeHashRegistered(
        bytes32 indexed typeHash,
        string typeString,
        address registrar,
        uint256 timestamp
    );
}
```

### 3.3 IProofProcessor Interface

Interface for specialized proof processing operations. Updated with PeerDAS support and Blob storage capabilities.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IProofProcessor {
    /// @notice Process a proof and extract key information
    /// @param proofType Type of proof to process
    /// @param proof The zero-knowledge proof
    /// @return publicInputs Extracted public inputs
    /// @return valid Whether the proof is valid
    function processProof(
        uint8 proofType,
        bytes calldata proof
    ) external view returns (bytes32[] memory publicInputs, bool valid);

    /// @notice Extract nullifier from a vote proof
    /// @param proof The vote proof
    /// @return nullifier The extracted nullifier
    function extractNullifier(bytes calldata proof) external pure returns (bytes32 nullifier);

    /// @notice Extract vote commitment from a vote proof
    /// @param proof The vote proof
    /// @return commitment The extracted vote commitment
    function extractVoteCommitment(bytes calldata proof) external pure returns (bytes32 commitment);

    /// @notice Aggregate multiple proofs into a single proof
    /// @param proofType Type of proofs to aggregate
    /// @param proofs Array of proofs to aggregate
    /// @return aggregatedProof The aggregated proof
    function aggregateProofs(
        uint8 proofType,
        bytes[] calldata proofs
    ) external view returns (bytes memory aggregatedProof);

    /// @notice Verify a recursive proof
    /// @param outerProofType Type of the outer proof
    /// @param innerProofType Type of the inner proof
    /// @param recursiveProof The recursive proof
    /// @param publicInputs Public inputs for verification
    /// @return valid Whether the recursive proof is valid
    function verifyRecursiveProof(
        uint8 outerProofType,
        uint8 innerProofType,
        bytes calldata recursiveProof,
        bytes32[] calldata publicInputs
    ) external view returns (bool valid);

    /// @notice Submit batch of proofs using blob storage (EIP-7691)
    /// @param proofType Type of proofs
    /// @param blobs Array of blob data containing proofs
    /// @return success Whether submission was successful
    function submitBlobBatch(
        uint8 proofType,
        bytes[] calldata blobs
    ) external payable returns (bool success);

    /// @notice Request sampling proof from PeerDAS (EIP-7594)
    /// @param dataRoot Root of the data to sample
    /// @param indices Indices to sample
    /// @return requestId Identifier for the sampling request
    function requestDasSamplingProof(
        bytes32 dataRoot,
        uint256[] calldata indices
    ) external returns (bytes32 requestId);

    /// @notice Verify a sampling proof from PeerDAS
    /// @param requestId Identifier for the sampling request
    /// @param proofs Array of sampling proofs
    /// @return valid Whether the sampling proofs are valid
    function verifyDasSamplingProof(
        bytes32 requestId,
        bytes[] calldata proofs
    ) external view returns (bool valid);

    /// @notice Calculate the blob fee for a batch of proofs
    /// @param blobCount Number of blobs
    /// @return fee The calculated fee in wei
    function calculateBlobFee(uint256 blobCount) external view returns (uint256 fee);

    /// @notice Emitted when a blob batch is submitted
    event BlobBatchSubmitted(
        address indexed submitter,
        uint256 blobCount,
        uint256 fee,
        uint256 timestamp
    );

    /// @notice Emitted when a DAS sampling request is created
    event DasSamplingRequested(
        bytes32 indexed requestId,
        bytes32 indexed dataRoot,
        uint256 indexCount,
        uint256 timestamp
    );
}
```

## 4. Delegation Protocol Interfaces

### 4.1 IDelegationRegistry Interface

Interface for the delegation registry that manages delegation relationships. Updated with Box type support and signing domains.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDelegationRegistry {
    /// @notice Register a new delegation
    /// @param delegationCommitment Commitment to the delegation relationship
    /// @param nullifier Nullifier to prevent delegation reuse
    /// @param stealthAddressHint Hint for delegate discovery
    /// @param constraints Public delegation constraints
    /// @param encryptedMetadata Optional encrypted metadata
    /// @param proof Zero-knowledge proof of valid delegation
    /// @return success Whether registration was successful
    function registerDelegation(
        bytes32 delegationCommitment,
        bytes32 nullifier,
        bytes32 stealthAddressHint,
        bytes calldata constraints,
        bytes calldata encryptedMetadata,
        bytes calldata proof
    ) external returns (bool success);

    /// @notice Register a delegation with EIP-712 structured data signature
    /// @param delegationCommitment Commitment to the delegation relationship
    /// @param nullifier Nullifier to prevent delegation reuse
    /// @param stealthAddressHint Hint for delegate discovery
    /// @param constraints Public delegation constraints
    /// @param signature EIP-712 signature authorizing the delegation
    /// @return success Whether registration was successful
    function registerDelegationWithSignature(
        bytes32 delegationCommitment,
        bytes32 nullifier,
        bytes32 stealthAddressHint,
        bytes calldata constraints,
        bytes calldata signature
    ) external returns (bool success);

    /// @notice Revoke an existing delegation
    /// @param delegationPointer Pointer to the delegation
    /// @param revocationNullifier Nullifier for revocation
    /// @param proof Zero-knowledge proof of revocation authority
    /// @return success Whether revocation was successful
    function revokeDelegation(
        bytes32 delegationPointer,
        bytes32 revocationNullifier,
        bytes calldata proof
    ) external returns (bool success);

    /// @notice Claim a delegation as a delegate
    /// @param delegationPointer Pointer to the delegation
    /// @param claimProof Proof of ability to claim the delegation
    /// @return success Whether the claim was successful
    function claimDelegation(
        bytes32 delegationPointer,
        bytes calldata claimProof
    ) external returns (bool success);

    /// @notice Check if a delegation is active
    /// @param delegationPointer Pointer to the delegation
    /// @return active Whether the delegation is active
    function isDelegationActive(bytes32 delegationPointer) external view returns (bool active);

    /// @notice Get public information about a delegation
    /// @param delegationPointer Pointer to the delegation
    /// @return delegationInfo Public information about the delegation
    function getDelegationInfo(bytes32 delegationPointer) external view returns (DelegationInfo memory delegationInfo);

    /// @notice Check if a nullifier has been used
    /// @param nullifier The nullifier to check
    /// @return used Whether the nullifier has been used
    function isNullifierUsed(bytes32 nullifier) external view returns (bool used);

    /// @notice GDPR-compliant function to forget a delegation
    /// @dev Only callable by authorized data controllers
    /// @param delegationPointer Pointer to the delegation to forget
    /// @return success Whether the delegation was successfully forgotten
    function forgetDelegation(bytes32 delegationPointer) external returns (bool success);

    /// @notice Get the EIP-712 domain separator for delegations
    /// @return domainSeparator The domain separator hash
    function getDelegationDomainSeparator() external view returns (bytes32 domainSeparator);

    /// @notice Get the EIP-712 type hash for delegations
    /// @return typeHash The type hash for delegations
    function getDelegationTypeHash() external view returns (bytes32 typeHash);

    /// @notice Register a delegation with Box type containers (EIP-7713)
    /// @param delegationBox Box containing delegation data
    /// @param proof Proof of delegation validity
    /// @return success Whether registration was successful
    function registerDelegationWithBox(
        Box calldata delegationBox,
        bytes calldata proof
    ) external returns (bool success);

    /// @notice Emitted when a new delegation is registered
    event DelegationRegistered(
        bytes32 indexed delegationPointer,
        bytes32 indexed nullifier,
        uint256 timestamp
    );

    /// @notice Emitted when a delegation is revoked
    event DelegationRevoked(
        bytes32 indexed delegationPointer,
        bytes32 indexed revocationNullifier,
        uint256 timestamp
    );

    /// @notice Emitted when a delegation is claimed
    event DelegationClaimed(
        bytes32 indexed delegationPointer,
        uint256 timestamp
    );

    /// @notice Emitted when a delegation is forgotten (GDPR compliance)
    event DelegationForgotten(
        bytes32 indexed delegationPointer,
        uint256 timestamp
    );

    /// @notice Public information about a delegation
    struct DelegationInfo {
        bytes32 delegationPointer;
        bytes32 stealthAddressHint;
        bytes constraints;
        uint256 registrationTime;
        uint256 expirationTime; // 0 if no expiration
        DelegationStatus status;
    }

    /// @notice Generic box type for arbitrary data (EIP-7713)
    struct Box {
        bytes32 typeHash;
        bytes data;
    }

    /// @notice Status of a delegation
    enum DelegationStatus {
        Active,
        Revoked,
        Expired,
        Claimed,
        Forgotten
    }
}
```

### 4.2 IDelegationVoter Interface

Interface for voting with delegated authority. Updated with smart accounts support and HSM integration.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDelegationVoter {
    /// @notice Vote with delegated authority
    /// @param voteId Identifier of the vote
    /// @param nullifiers Array of nullifiers for delegations being used
    /// @param voteCommitment Commitment to the vote choice
    /// @param weightCommitment Commitment to the aggregated voting weight
    /// @param delegationProof Zero-knowledge proof of valid delegation use
    /// @return success Whether the vote was successfully cast
    function voteWithDelegation(
        bytes32 voteId,
        bytes32[] calldata nullifiers,
        bytes32 voteCommitment,
        bytes32 weightCommitment,
        bytes calldata delegationProof
    ) external returns (bool success);

    /// @notice Vote with delegated authority using smart account (ERC-1271)
    /// @param voteId Identifier of the vote
    /// @param nullifiers Array of nullifiers for delegations being used
    /// @param voteCommitment Commitment to the vote choice
    /// @param weightCommitment Commitment to the aggregated voting weight
    /// @param signature Smart account signature
    /// @return success Whether the vote was successfully cast
    function voteWithDelegationViaSmartAccount(
        bytes32 voteId,
        bytes32[] calldata nullifiers,
        bytes32 voteCommitment,
        bytes32 weightCommitment,
        bytes calldata signature
    ) external returns (bool success);

    /// @notice Vote with delegated authority using HSM signature
    /// @param voteId Identifier of the vote
    /// @param nullifiers Array of nullifiers for delegations being used
    /// @param voteCommitment Commitment to the vote choice
    /// @param weightCommitment Commitment to the aggregated voting weight
    /// @param hsmSignature Hardware Security Module signature
    /// @return success Whether the vote was successfully cast
    function voteWithDelegationViaHSM(
        bytes32 voteId,
        bytes32[] calldata nullifiers,
        bytes32 voteCommitment,
        bytes32 weightCommitment,
        bytes calldata hsmSignature
    ) external returns (bool success);

    /// @notice Check if a vote is eligible for delegation
    /// @param voteId Identifier of the vote
    /// @return delegationAllowed Whether delegation is allowed for this vote
    function isDelegationAllowed(bytes32 voteId) external view returns (bool delegationAllowed);

    /// @notice Check if delegated nullifiers have been used for voting
    /// @param voteId Identifier of the vote
    /// @param nullifiers Array of nullifiers to check
    /// @return used Array indicating which nullifiers have been used
    function areDelegationNullifiersUsed(
        bytes32 voteId,
        bytes32[] calldata nullifiers
    ) external view returns (bool[] memory used);

    /// @notice Get active delegations that can be used for a specific vote
    /// @param hint Hint for finding relevant delegations
    /// @param voteId Identifier of the vote
    /// @return delegationPointers Array of pointers to eligible delegations
    function getEligibleDelegationsWithHint(
        bytes32 hint,
        bytes32 voteId
    ) external view returns (bytes32[] memory delegationPointers);

    /// @notice Verify HSM signature for delegation voting
    /// @param hsmSignature Hardware Security Module signature
    /// @param digest Message digest that was signed
    /// @return valid Whether the signature is valid
    function verifyHSMSignature(
        bytes calldata hsmSignature,
        bytes32 digest
    ) external view returns (bool valid);

    /// @notice Compute a digest for HSM signing
    /// @param voteId Identifier of the vote
    /// @param nullifiers Array of nullifiers
    /// @param voteCommitment Commitment to the vote choice
    /// @param weightCommitment Commitment to the weight
    /// @return digest The computed digest
    function computeHSMDigest(
        bytes32 voteId,
        bytes32[] calldata nullifiers,
        bytes32 voteCommitment,
        bytes32 weightCommitment
    ) external view returns (bytes32 digest);

    /// @notice EIP-712 domain separator for delegation voting
    /// @return domainSeparator The domain separator hash
    function getDelegationVotingDomainSeparator() external view returns (bytes32 domainSeparator);

    /// @notice Emitted when a vote is cast using delegation
    event DelegatedVoteCast(
        bytes32 indexed voteId,
        uint256 delegationCount,
        bytes32 voteCommitment,
        uint256 timestamp
    );

    /// @notice Emitted when a vote is cast using a smart account
    event SmartAccountDelegatedVoteCast(
        bytes32 indexed voteId,
        address indexed account,
        uint256 delegationCount,
        uint256 timestamp
    );

    /// @notice Emitted when a vote is cast using an HSM
    event HSMDelegatedVoteCast(
        bytes32 indexed voteId,
        bytes32 indexed hsmIdentifier,
        uint256 delegationCount,
        uint256 timestamp
    );
}
```

### 4.3 IDelegationDiscovery Interface

Interface for delegates to discover delegations assigned to them. Updated with Box type support.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDelegationDiscovery {
    /// @notice Register a delegate's viewing key
    /// @param viewingKey Public key used for delegation discovery
    /// @param metadata Additional delegate metadata
    /// @return success Whether registration was successful
    function registerDelegateViewingKey(
        bytes calldata viewingKey,
        bytes calldata metadata
    ) external returns (bool success);

    /// @notice Get hint information for delegation discovery
    /// @param viewTag Short tag used for filtering potential delegations
    /// @return delegationHints Array of delegation hints matching the view tag
    function getDelegationHintsByViewTag(
        bytes4 viewTag
    ) external view returns (DelegationHint[] memory delegationHints);

    /// @notice Submit a notification for a delegate
    /// @param stealthAddress Stealth address of the delegate
    /// @param viewTag View tag for efficient scanning
    /// @param encryptedAmount Encrypted delegation amount
    /// @param delegatorHint Optional hint about the delegator
    /// @return success Whether notification was successfully sent
    function sendDelegateNotification(
        bytes calldata stealthAddress,
        bytes4 viewTag,
        bytes calldata encryptedAmount,
        bytes calldata delegatorHint
    ) external returns (bool success);

    /// @notice Submit a notification for a delegate with Box type (EIP-7713)
    /// @param stealthAddress Stealth address of the delegate
    /// @param viewTag View tag for efficient scanning
    /// @param delegationBox Box containing delegation data
    /// @return success Whether notification was successfully sent
    function sendDelegateNotificationWithBox(
        bytes calldata stealthAddress,
        bytes4 viewTag,
        Box calldata delegationBox
    ) external returns (bool success);

    /// @notice Check if an address has registered as a delegate
    /// @param delegateAddress Address to check
    /// @return isRegistered Whether the address is registered as a delegate
    function isDelegateRegistered(address delegateAddress) external view returns (bool isRegistered);

    /// @notice Get all registered delegates
    /// @return delegates Array of delegate information
    function getAllDelegates() external view returns (DelegateInfo[] memory delegates);

    /// @notice Visualize a delegation (EIP-6865)
    /// @param delegationPointer Pointer to the delegation
    /// @return title Title of the visualization
    /// @return fields Array of field names
    /// @return values Array of field values
    function visualizeDelegation(bytes32 delegationPointer) external view returns (
        string memory title,
        string[] memory fields,
        string[] memory values
    );

    /// @notice Information about a delegation hint
    struct DelegationHint {
        bytes32 delegationPointer;
        bytes4 viewTag;
        bytes encryptedData;
        uint256 timestamp;
    }

    /// @notice Information about a registered delegate
    struct DelegateInfo {
        address delegateAddress;
        bytes viewingKey;
        bytes metadata;
        uint256 registrationTime;
    }

    /// @notice Generic box type for arbitrary data (EIP-7713)
    struct Box {
        bytes32 typeHash;
        bytes data;
    }

    /// @notice Emitted when a delegate registers
    event DelegateRegistered(
        address indexed delegateAddress,
        uint256 timestamp
    );

    /// @notice Emitted when a delegation notification is sent
    event DelegateNotificationSent(
        bytes4 indexed viewTag,
        bytes32 indexed delegationPointer,
        uint256 timestamp
    );

    /// @notice Emitted when a delegation notification with Box is sent
    event DelegateBoxNotificationSent(
        bytes4 indexed viewTag,
        bytes32 indexed delegationPointer,
        bytes32 indexed typeHash,
        uint256 timestamp
    );
}
```

## 5. Cross-Chain Bridge Interfaces

### 5.1 ICrossChainBridge Interface

Interface for the core cross-chain bridge functionality. Updated with PeerDAS and blob support.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICrossChainBridge {
    /// @notice Submit a message to be sent to another chain
    /// @param targetChainId Identifier of the destination chain
    /// @param message The message to be sent
    /// @param proof Optional proof (depending on bridge implementation)
    /// @return messageId Unique identifier for the message
    function submitBridgeMessage(
        bytes32 targetChainId,
        bytes calldata message,
        bytes calldata proof
    ) external returns (bytes32 messageId);

    /// @notice Submit a message batch using blob storage (EIP-7691)
    /// @param targetChainId Identifier of the destination chain
    /// @param blobs Array of blob data containing messages
    /// @return messageIds Array of message identifiers
    function submitBridgeMessageBatch(
        bytes32 targetChainId,
        bytes[] calldata blobs
    ) external payable returns (bytes32[] memory messageIds);

    /// @notice Verify an incoming message from another chain
    /// @param sourceChainId Identifier of the source chain
    /// @param message The received message
    /// @param proof Proof of valid cross-chain message
    /// @return valid Whether the message is valid
    function verifyIncomingMessage(
        bytes32 sourceChainId,
        bytes calldata message,
        bytes calldata proof
    ) external view returns (bool valid);

    /// @notice Execute an incoming message from another chain
    /// @param sourceChainId Identifier of the source chain
    /// @param message The message to execute
    /// @param signatures Signatures from bridge validators
    /// @return success Whether execution was successful
    function executeIncomingMessage(
        bytes32 sourceChainId,
        bytes calldata message,
        bytes calldata signatures
    ) external returns (bool success);

    /// @notice Get the status of a message
    /// @param messageId Identifier of the message
    /// @return status Current status of the message
    function getMessageStatus(bytes32 messageId) external view returns (MessageStatus status);

    /// @notice Get the required number of signatures for message validation
    /// @return threshold Minimum number of signatures required
    function getSignatureThreshold() external view returns (uint256 threshold);

    /// @notice Register as a bridge validator (admin function)
    /// @param validator Address of the validator
    /// @param validatorPubKey Validator's public key for signature verification
    /// @return success Whether registration was successful
    function registerValidator(
        address validator,
        bytes calldata validatorPubKey
    ) external returns (bool success);

    /// @notice Verify message with Data Availability Sampling (EIP-7594)
    /// @param messageId Identifier of the message
    /// @param dasSamplingProof Proof of data availability
    /// @return valid Whether the message has valid data availability
    function verifyMessageWithDAS(
        bytes32 messageId,
        bytes calldata dasSamplingProof
    ) external view returns (bool valid);

    /// @notice Calculate the blob fee for message submission
    /// @param blobCount Number of blobs
    /// @return fee The calculated fee in wei
    function calculateMessageBlobFee(uint256 blobCount) external view returns (uint256 fee);

    /// @notice Access historical block hash (EIP-2935)
    /// @param blockNumber Block number to query
    /// @return blockHash The historical block hash
    function getHistoricalBlockHash(uint256 blockNumber) external view returns (bytes32 blockHash);

    /// @notice Verify historical state
    /// @param blockNumber Block number to verify
    /// @param expectedRoot Expected state root
    /// @return valid Whether the historical state matches the expected root
    function verifyHistoricalState(
        uint256 blockNumber,
        bytes32 expectedRoot
    ) external view returns (bool valid);

    /// @notice Message status enum
    enum MessageStatus {
        Unknown,
        Submitted,
        Confirmed,
        Executed,
        Failed
    }

    /// @notice Bridge message structure
    struct BridgeMessage {
        bytes32 messageId;
        bytes32 sourceChainId;
        bytes32 targetChainId;
        uint64 nonce;
        uint64 timestamp;
        uint8 messageType;
        bytes payload;
    }

    /// @notice Emitted when a message is submitted
    event MessageSubmitted(
        bytes32 indexed messageId,
        bytes32 indexed targetChainId,
        address sender,
        uint256 timestamp
    );

    /// @notice Emitted when a message batch is submitted
    event MessageBatchSubmitted(
        bytes32 indexed targetChainId,
        uint256 batchSize,
        uint256 fee,
        uint256 timestamp
    );

    /// @notice Emitted when a message is executed
    event MessageExecuted(
        bytes32 indexed messageId,
        bytes32 indexed sourceChainId,
        bool success,
        uint256 timestamp
    );
}
```

### 5.2 ICrossChainVoteRelay Interface

Interface for relaying votes across blockchain networks. Updated with account abstraction support.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICrossChainVoteRelay {
    /// @notice Relay a vote to another chain
    /// @param targetChainId Identifier of the destination chain
    /// @param proposalId Identifier of the proposal being voted on
    /// @param voteCommitment Commitment to the vote choice
    /// @param nullifier Vote nullifier
    /// @param proof Zero-knowledge proof of vote validity
    /// @return messageId Identifier of the bridge message
    function relayVote(
        bytes32 targetChainId,
        bytes32 proposalId,
        bytes32 voteCommitment,
        bytes32 nullifier,
        bytes calldata proof
    ) external returns (bytes32 messageId);

    /// @notice Relay a vote to another chain via smart account (EIP-4337)
    /// @param userOp User operation containing vote data
    /// @param targetChainId Identifier of the destination chain
    /// @return messageId Identifier of the bridge message
    function relayVoteViaSmartAccount(
        UserOperation calldata userOp,
        bytes32 targetChainId
    ) external returns (bytes32 messageId);

    /// @notice Register a vote received from another chain
    /// @param sourceChainId Identifier of the source chain
    /// @param proposalId Identifier of the proposal
    /// @param voteCommitment Commitment to the vote choice
    /// @param nullifier Vote nullifier
    /// @param proof Zero-knowledge proof of vote validity
    /// @return success Whether registration was successful
    function registerForeignVote(
        bytes32 sourceChainId,
        bytes32 proposalId,
        bytes32 voteCommitment,
        bytes32 nullifier,
        bytes calldata proof
    ) external returns (bool success);

    /// @notice Get foreign votes for a proposal
    /// @param proposalId Identifier of the proposal
    /// @return foreignVotes Array of votes received from other chains
    function getForeignVotes(bytes32 proposalId) external view returns (ForeignVote[] memory foreignVotes);

    /// @notice Check if a foreign nullifier has been used
    /// @param nullifier The nullifier to check
    /// @return used Whether the nullifier has been used
    function isForeignNullifierUsed(bytes32 nullifier) external view returns (bool used);

    /// @notice Register a proposal as available for cross-chain voting
    /// @param proposalId Identifier of the proposal
    /// @param eligibleChains Array of chains eligible to participate
    /// @param proposalData IPFS hash or other identifier for proposal data
    /// @return success Whether registration was successful
    function registerCrossChainProposal(
        bytes32 proposalId,
        bytes32[] calldata eligibleChains,
        bytes32 proposalData
    ) external returns (bool success);

    /// @notice Check if a chain is eligible for voting on a proposal
    /// @param proposalId Identifier of the proposal
    /// @param chainId Identifier of the chain to check
    /// @return eligible Whether the chain is eligible
    function isChainEligible(bytes32 proposalId, bytes32 chainId) external view returns (bool eligible);

    /// @notice Sponsor gas costs for relaying votes
    /// @param paymaster Address of the paymaster contract
    /// @param maxCost Maximum gas cost to sponsor
    /// @return success Whether sponsorship was successful
    function sponsorGas(
        address paymaster,
        uint256 maxCost
    ) external returns (bool success);

    /// @notice Information about a vote from another chain
    struct ForeignVote {
        bytes32 sourceChainId;
        bytes32 voteCommitment;
        bytes32 nullifier;
        uint256 timestamp;
    }

    /// @notice User operation structure for account abstraction (EIP-4337)
    struct UserOperation {
        address sender;
        uint256 nonce;
        bytes initCode;
        bytes callData;
        uint256 callGasLimit;
        uint256 verificationGasLimit;
        uint256 preVerificationGas;
        uint256 maxFeePerGas;
        uint256 maxPriorityFeePerGas;
        bytes paymasterAndData;
        bytes signature;
    }

    /// @notice Emitted when a vote is relayed to another chain
    event VoteRelayed(
        bytes32 indexed proposalId,
        bytes32 indexed targetChainId,
        bytes32 nullifier,
        uint256 timestamp
    );

    /// @notice Emitted when a foreign vote is registered
    event ForeignVoteRegistered(
        bytes32 indexed proposalId,
        bytes32 indexed sourceChainId,
        bytes32 nullifier,
        uint256 timestamp
    );

    /// @notice Emitted when gas is sponsored for vote relaying
    event GasSponsored(
        address indexed sponsor,
        address indexed paymaster,
        uint256 maxCost,
        uint256 timestamp
    );
}
```

### 5.3 ICrossChainResultSync Interface

Interface for synchronizing vote results across chains. Updated with blob storage and PeerDAS support.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICrossChainResultSync {
    /// @notice Publish voting results to other chains
    /// @param targetChains Array of destination chain identifiers
    /// @param proposalId Identifier of the proposal
    /// @param resultHash Hash of the results
    /// @param resultData The result data
    /// @param proof Proof of correct result computation
    /// @return messageIds Array of bridge message identifiers
    function publishResults(
        bytes32[] calldata targetChains,
        bytes32 proposalId,
        bytes32 resultHash,
        bytes calldata resultData,
        bytes calldata proof
    ) external returns (bytes32[] memory messageIds);

    /// @notice Publish results using blob storage (EIP-7691)
    /// @param targetChains Array of destination chain identifiers
    /// @param proposalId Identifier of the proposal
    /// @param resultHash Hash of the results
    /// @param resultBlobs Array of blobs containing result data
    /// @param proof Proof of correct result computation
    /// @return messageIds Array of bridge message identifiers
    function publishResultsWithBlobs(
        bytes32[] calldata targetChains,
        bytes32 proposalId,
        bytes32 resultHash,
        bytes[] calldata resultBlobs,
        bytes calldata proof
    ) external payable returns (bytes32[] memory messageIds);

    /// @notice Register results received from another chain
    /// @param sourceChainId Identifier of the source chain
    /// @param proposalId Identifier of the proposal
    /// @param resultHash Hash of the results
    /// @param resultData The result data
    /// @param proof Proof of correct result computation
    /// @return success Whether registration was successful
    function registerForeignResults(
        bytes32 sourceChainId,
        bytes32 proposalId,
        bytes32 resultHash,
        bytes calldata resultData,
        bytes calldata proof
    ) external returns (bool success);

    /// @notice Get results from a specific chain
    /// @param proposalId Identifier of the proposal
    /// @param chainId Identifier of the chain
    /// @return resultData The result data
    /// @return resultHash Hash of the results
    /// @return timestamp Time when results were received
    function getChainResults(
        bytes32 proposalId,
        bytes32 chainId
    ) external view returns (
        bytes memory resultData,
        bytes32 resultHash,
        uint256 timestamp
    );

    /// @notice Get all chains that have submitted results for a proposal
    /// @param proposalId Identifier of the proposal
    /// @return chains Array of chain identifiers with results
    function getChainsWithResults(bytes32 proposalId) external view returns (bytes32[] memory chains);

    /// @notice Check if all expected chains have submitted results
    /// @param proposalId Identifier of the proposal
    /// @return complete Whether all expected results are received
    function areResultsComplete(bytes32 proposalId) external view returns (bool complete);

    /// @notice Verify results with Data Availability Sampling (EIP-7594)
    /// @param proposalId Identifier of the proposal
    /// @param chainId Identifier of the chain
    /// @param samplingProof Proof of data availability
    /// @return valid Whether the results have valid data availability
    function verifyResultsWithDAS(
        bytes32 proposalId,
        bytes32 chainId,
        bytes calldata samplingProof
    ) external view returns (bool valid);

    /// @notice Request Data Availability Sampling for results (EIP-7594)
    /// @param proposalId Identifier of the proposal
    /// @param chainId Identifier of the chain
    /// @param indices Indices to sample
    /// @return requestId Identifier for the sampling request
    function requestResultsDasSampling(
        bytes32 proposalId,
        bytes32 chainId,
        uint256[] calldata indices
    ) external returns (bytes32 requestId);

    /// @notice Calculate the blob fee for result publication
    /// @param blobCount Number of blobs
    /// @return fee The calculated fee in wei
    function calculateResultsBlobFee(uint256 blobCount) external view returns (uint256 fee);

    /// @notice Emitted when results are published to other chains
    event ResultsPublished(
        bytes32 indexed proposalId,
        uint256 targetChainCount,
        bytes32 resultHash,
        uint256 timestamp
    );

    /// @notice Emitted when results with blobs are published
    event ResultsBlobsPublished(
        bytes32 indexed proposalId,
        uint256 targetChainCount,
        uint256 blobCount,
        uint256 fee,
        uint256 timestamp
    );

    /// @notice Emitted when results from another chain are registered
    event ForeignResultsRegistered(
        bytes32 indexed proposalId,
        bytes32 indexed sourceChainId,
        bytes32 resultHash,
        uint256 timestamp
    );

    /// @notice Emitted when a DAS sampling request is created for results
    event ResultsDasSamplingRequested(
        bytes32 indexed requestId,
        bytes32 indexed proposalId,
        bytes32 indexed chainId,
        uint256 indexCount,
        uint256 timestamp
    );
}
```

## 6. Identity and Eligibility Interfaces

### 6.1 IIdentityRegistry Interface

Interface for the identity registry managing zero-knowledge identities. Updated with GDPR compliance and EIP-7803 signing domains.

````solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIdentityRegistry {
    /// @notice Register a new identity
    /// @param identityCommitment Commitment to the identity
    /// @param metadata Additional identity metadata
    /// @return success Whether registration was successful
    function registerIdentity(
        bytes32 identityCommitment,
        bytes calldata metadata
    ) external returns (bool success);

    /// @notice Check if an identity commitment is registered
    /// @param identityCommitment The identity commitment to check
    /// @return registered Whether the identity is registered
    function isIdentityRegistered(bytes32 identityCommitment) external view returns (bool registered);

    /// @notice Update identity metadata
    /// @param identityCommitment The identity commitment
    /// @param newMetadata New metadata to associate with the identity
    /// @param proof Proof of identity ownership
    /// @return success Whether the update was successful
    function updateIdentityMetadata(
        bytes32 identityCommitment,
        bytes calldata newMetadata,
        bytes calldata proof
    ) external returns (bool success);

    /// @notice Get identity information
    /// @param identityCommitment The identity commitment
    /// @return info Information about the identity
    function getIdentityInfo(bytes32 identityCommitment) external view returns (IdentityInfo memory info);

    /// @notice Register identity on behalf of a user (with authorization)
    /// @param identityCommitment The identity commitment
    /// @param metadata Identity metadata
    /// @param authorizationProof Proof of registration authorization
    /// @return success Whether registration was successful
    function registerIdentityWithAuthorization(
        bytes32 identityCommitment,
        bytes calldata metadata,
        bytes calldata authorizationProof
    ) external returns (bool success);

    /// @notice Register identity with EIP-712 signature
    /// @param identityCommitment The identity commitment
    /// @param metadata Identity metadata
    /// @param signature EIP-712 signature authorizing registration
    /// @return success Whether registration was successful
    function registerIdentityWithSignature(
        bytes32 identityCommitment,
        bytes calldata metadata,
        bytes calldata signature
    ) external returns (bool success);

    /// @notice GDPR-compliant function to forget an identity
    /// @dev Only callable by authorized data controllers or the identity owner
    /// @param identityCommitment The identity commitment to forget
    /// @param proof Proof of ownership or authority
    /// @return success Whether the identity was successfully forgotten
    function forgetIdentity(
        bytes32 identityCommitment,
        bytes calldata proof
    ) external returns (bool success);

    /// @notice Get the EIP-712 domain separator for identity operations
    /// @return domainSeparator The domain separator hash
    function getIdentityDomainSeparator() external view returns (bytes32 domainSeparator);

    I'll continue updating the document from where I left off:

```markdown name=smartContractInterfaceSpecs.md
    /// @notice Get the signing domain hash (EIP-7803)
    /// @param account Account address
    /// @param nonce Current nonce
    /// @return domainHash The signing domain hash
    function getIdentitySigningDomainHash(
        address account,
        uint256 nonce
    ) external view returns (bytes32 domainHash);

    /// @notice Check if an identity is valid across chains
    /// @param identityCommitment The identity commitment
    /// @param chainId Chain identifier
    /// @return valid Whether the identity is valid on the specified chain
    function isIdentityValidOnChain(
        bytes32 identityCommitment,
        bytes32 chainId
    ) external view returns (bool valid);

    /// @notice Information about an identity
    struct IdentityInfo {
        bytes32 identityCommitment;
        bytes metadata;
        uint256 registrationTime;
        uint256 lastUpdated;
        bool active;
        bytes32[] linkedChains; // Chains where this identity is valid
        uint256 privacyLevel;   // 0: public, 1: protected, 2: private
    }

    /// @notice Emitted when a new identity is registered
    event IdentityRegistered(
        bytes32 indexed identityCommitment,
        uint256 timestamp
    );

    /// @notice Emitted when identity metadata is updated
    event IdentityUpdated(
        bytes32 indexed identityCommitment,
        uint256 timestamp
    );

    /// @notice Emitted when an identity is forgotten (GDPR compliance)
    event IdentityForgotten(
        bytes32 indexed identityCommitment,
        uint256 timestamp
    );

    /// @notice Emitted when an identity is registered with a signature
    event IdentityRegisteredWithSignature(
        bytes32 indexed identityCommitment,
        address indexed signer,
        uint256 timestamp
    );
}
`````

### 6.2 IEligibilityVerifier Interface

Interface for verifying voting eligibility. Updated with EIP-712 support and PeerDAS integration.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEligibilityVerifier {
    /// @notice Verify eligibility for voting
    /// @param voteId Identifier of the vote
    /// @param eligibilityProof Zero-knowledge proof of eligibility
    /// @return eligible Whether the user is eligible
    /// @return weight The voting weight (if eligible)
    function verifyEligibility(
        bytes32 voteId,
        bytes calldata eligibilityProof
    ) external view returns (bool eligible, uint256 weight);

    /// @notice Register eligibility credentials for a vote
    /// @param voteId Identifier of the vote
    /// @param credentialRoot Merkle root of eligible credentials
    /// @param eligibilityPolicy Policy defining eligibility requirements
    /// @return success Whether registration was successful
    function registerEligibilityCredentials(
        bytes32 voteId,
        bytes32 credentialRoot,
        bytes calldata eligibilityPolicy
    ) external returns (bool success);

    /// @notice Generate eligibility proof (off-chain function signature)
    /// @param voteId Identifier of the vote
    /// @param identitySecret Secret identity value
    /// @param credentials Eligibility credentials
    /// @param credentialPath Merkle path for credentials
    /// @return proof Eligibility proof
    function generateEligibilityProof(
        bytes32 voteId,
        bytes32 identitySecret,
        bytes calldata credentials,
        bytes32[] calldata credentialPath
    ) external pure returns (bytes memory proof);

    /// @notice Register eligibility credentials with PeerDAS (EIP-7594)
    /// @param voteId Identifier of the vote
    /// @param credentialRoot Merkle root of eligible credentials
    /// @param eligibilityPolicy Policy defining eligibility requirements
    /// @param dasProof Data availability proof
    /// @return success Whether registration was successful
    function registerEligibilityCredentialsWithDAS(
        bytes32 voteId,
        bytes32 credentialRoot,
        bytes calldata eligibilityPolicy,
        bytes calldata dasProof
    ) external returns (bool success);

    /// @notice Verify eligibility with EIP-712 signature
    /// @param voteId Identifier of the vote
    /// @param signedCredentials Credentials signed with EIP-712
    /// @return eligible Whether the user is eligible
    /// @return weight The voting weight (if eligible)
    function verifyEligibilityWithSignature(
        bytes32 voteId,
        bytes calldata signedCredentials
    ) external view returns (bool eligible, uint256 weight);

    /// @notice Check if eligibility credentials are registered for a vote
    /// @param voteId Identifier of the vote
    /// @return registered Whether eligibility credentials are registered
    /// @return credentialRoot The Merkle root of eligible credentials (if registered)
    function hasEligibilityCredentials(bytes32 voteId) external view returns (bool registered, bytes32 credentialRoot);

    /// @notice Get the eligibility policy for a vote
    /// @param voteId Identifier of the vote
    /// @return policy The eligibility policy
    function getEligibilityPolicy(bytes32 voteId) external view returns (bytes memory policy);

    /// @notice Batch verify eligibility for multiple voters
    /// @param voteId Identifier of the vote
    /// @param eligibilityProofs Array of eligibility proofs
    /// @return eligibilityResults Array of eligibility results
    /// @return weights Array of voting weights
    function batchVerifyEligibility(
        bytes32 voteId,
        bytes[] calldata eligibilityProofs
    ) external view returns (bool[] memory eligibilityResults, uint256[] memory weights);

    /// @notice Get the EIP-712 domain separator for eligibility verification
    /// @return domainSeparator The domain separator hash
    function getEligibilityDomainSeparator() external view returns (bytes32 domainSeparator);

    /// @notice Emitted when eligibility credentials are registered
    event EligibilityCredentialsRegistered(
        bytes32 indexed voteId,
        bytes32 credentialRoot,
        uint256 timestamp
    );

    /// @notice Emitted when eligibility credentials with DAS are registered
    event EligibilityCredentialsWithDASRegistered(
        bytes32 indexed voteId,
        bytes32 credentialRoot,
        bytes32 dasDataRoot,
        uint256 timestamp
    );
}
```

### 6.3 ICrossChainIdentityBridge Interface

Interface for bridging identities across blockchain networks. Updated with EIP-712, HSM support, and enhanced cross-chain capabilities.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICrossChainIdentityBridge {
    /// @notice Register local identity
    /// @param identityCommitment Commitment to the identity
    /// @param userAddress User's address on this chain
    /// @param proof Proof of address control
    /// @return success Whether registration was successful
    function registerIdentity(
        bytes32 identityCommitment,
        address userAddress,
        bytes calldata proof
    ) external returns (bool success);

    /// @notice Register local identity with EIP-712 signature
    /// @param identityCommitment Commitment to the identity
    /// @param userAddress User's address on this chain
    /// @param signature EIP-712 signature authorizing registration
    /// @return success Whether registration was successful
    function registerIdentityWithSignature(
        bytes32 identityCommitment,
        address userAddress,
        bytes calldata signature
    ) external returns (bool success);

    /// @notice Register local identity using HSM signature
    /// @param identityCommitment Commitment to the identity
    /// @param userAddress User's address on this chain
    /// @param hsmSignature Hardware Security Module signature
    /// @return success Whether registration was successful
    function registerIdentityWithHSM(
        bytes32 identityCommitment,
        address userAddress,
        bytes calldata hsmSignature
    ) external returns (bool success);

    /// @notice Send identity attestation to another chain
    /// @param targetChain Identifier of the destination chain
    /// @param identityCommitment Commitment to the identity
    /// @param userAddress User's address on target chain
    /// @param proof Proof of address control
    /// @return messageId Identifier of the bridge message
    function attestIdentity(
        bytes32 targetChain,
        bytes32 identityCommitment,
        address userAddress,
        bytes calldata proof
    ) external returns (bytes32 messageId);

    /// @notice Register identity from another chain
    /// @param sourceChain Identifier of the source chain
    /// @param identityCommitment Commitment to the identity
    /// @param userAddress User's address on this chain
    /// @param proof Proof of valid attestation
    /// @return success Whether registration was successful
    function registerForeignIdentity(
        bytes32 sourceChain,
        bytes32 identityCommitment,
        address userAddress,
        bytes calldata proof
    ) external returns (bool success);

    /// @notice Verify identity on the local chain
    /// @param identityCommitment The identity commitment
    /// @param claimedAddress The address claimed to be associated with the identity
    /// @return valid Whether the identity is valid for the claimed address
    function verifyLocalIdentity(
        bytes32 identityCommitment,
        address claimedAddress
    ) external view returns (bool valid);

    /// @notice Verify identity from another chain
    /// @param chainId Identifier of the source chain
    /// @param identityCommitment The identity commitment
    /// @param claimedAddress The address claimed to be associated with the identity
    /// @return valid Whether the identity is valid for the claimed address
    function verifyForeignIdentity(
        bytes32 chainId,
        bytes32 identityCommitment,
        address claimedAddress
    ) external view returns (bool valid);

    /// @notice Get all chains where an identity is registered
    /// @param identityCommitment The identity commitment
    /// @return chains Array of chain identifiers
    function getIdentityChains(bytes32 identityCommitment) external view returns (bytes32[] memory chains);

    /// @notice Get address associated with an identity on a specific chain
    /// @param identityCommitment The identity commitment
    /// @param chainId Identifier of the chain
    /// @return userAddress The associated address (zero address if not found)
    function getChainAddress(
        bytes32 identityCommitment,
        bytes32 chainId
    ) external view returns (address userAddress);

    /// @notice GDPR-compliant function to forget an identity across chains
    /// @param identityCommitment The identity commitment
    /// @param targetChains Chains to forget the identity on
    /// @param proof Proof of ownership or authority
    /// @return messageIds Identifiers of the forget messages
    function forgetIdentityAcrossChains(
        bytes32 identityCommitment,
        bytes32[] calldata targetChains,
        bytes calldata proof
    ) external returns (bytes32[] memory messageIds);

    /// @notice Get the EIP-712 domain separator for cross-chain identity operations
    /// @return domainSeparator The domain separator hash
    function getCrossChainIdentityDomainSeparator() external view returns (bytes32 domainSeparator);

    /// @notice Verify HSM signature for identity operations
    /// @param hsmSignature Hardware Security Module signature
    /// @param digest Message digest that was signed
    /// @return valid Whether the signature is valid
    function verifyIdentityHSMSignature(
        bytes calldata hsmSignature,
        bytes32 digest
    ) external view returns (bool valid);

    /// @notice Emitted when an identity is attested to another chain
    event IdentityAttested(
        bytes32 indexed identityCommitment,
        bytes32 indexed targetChain,
        uint256 timestamp
    );

    /// @notice Emitted when a foreign identity is registered
    event ForeignIdentityRegistered(
        bytes32 indexed identityCommitment,
        bytes32 indexed sourceChain,
        address userAddress,
        uint256 timestamp
    );

    /// @notice Emitted when an identity is forgotten across chains
    event IdentityForgottenAcrossChains(
        bytes32 indexed identityCommitment,
        uint256 chainCount,
        uint256 timestamp
    );
}
```

## 7. Result Aggregation Interfaces

### 7.1 IVoteAggregator Interface

Interface for aggregating votes across multiple voting instances. Updated with PeerDAS and enhanced aggregation capabilities.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVoteAggregator {
    /// @notice Initialize vote aggregation
    /// @param proposalId Identifier of the proposal
    /// @param participatingChains Array of participating chain identifiers
    /// @param params Aggregation parameters
    /// @return aggregationId Unique identifier for the aggregation process
    function initializeAggregation(
        bytes32 proposalId,
        bytes32[] calldata participatingChains,
        AggregationParameters calldata params
    ) external returns (bytes32 aggregationId);

    /// @notice Register results from a specific chain
    /// @param aggregationId Identifier of the aggregation process
    /// @param chainId Identifier of the chain
    /// @param resultHash Hash of the chain results
    /// @param results The chain results
    /// @param proof Proof of valid results
    /// @return success Whether registration was successful
    function registerChainResults(
        bytes32 aggregationId,
        bytes32 chainId,
        bytes32 resultHash,
        bytes calldata results,
        bytes calldata proof
    ) external returns (bool success);

    /// @notice Register results from a specific chain with Data Availability Sampling
    /// @param aggregationId Identifier of the aggregation process
    /// @param chainId Identifier of the chain
    /// @param resultHash Hash of the chain results
    /// @param results The chain results
    /// @param proof Proof of valid results
    /// @param dasProof Data availability sampling proof
    /// @return success Whether registration was successful
    function registerChainResultsWithDAS(
        bytes32 aggregationId,
        bytes32 chainId,
        bytes32 resultHash,
        bytes calldata results,
        bytes calldata proof,
        bytes calldata dasProof
    ) external returns (bool success);

    /// @notice Finalize the aggregation and compute overall results
    /// @param aggregationId Identifier of the aggregation process
    /// @return finalResultHash Hash of the finalized results
    function finalizeResults(bytes32 aggregationId) external returns (bytes32 finalResultHash);

    /// @notice Verify the correctness of aggregated results
    /// @param aggregationId Identifier of the aggregation process
    /// @param aggregatedResults The aggregated results
    /// @param proof Proof of correct aggregation
    /// @return valid Whether the aggregation is valid
    function verifyAggregatedResults(
        bytes32 aggregationId,
        bytes calldata aggregatedResults,
        bytes calldata proof
    ) external view returns (bool valid);

    /// @notice Set weights for participating chains
    /// @param chains Array of chain identifiers
    /// @param weights Corresponding weights
    /// @return success Whether weights were successfully set
    function setChainWeights(
        bytes32[] calldata chains,
        uint256[] calldata weights
    ) external returns (bool success);

    /// @notice Get the weight assigned to a chain
    /// @param chainId Identifier of the chain
    /// @return weight The chain's weight
    function getChainWeight(bytes32 chainId) external view returns (uint256 weight);

    /// @notice Get the current status of an aggregation process
    /// @param aggregationId Identifier of the aggregation process
    /// @return status Current status of the aggregation
    function getAggregationStatus(bytes32 aggregationId) external view returns (AggregationStatus status);

    /// @notice Get chains participating in an aggregation
    /// @param aggregationId Identifier of the aggregation process
    /// @return chains Array of participating chain identifiers
    function getParticipatingChains(bytes32 aggregationId) external view returns (bytes32[] memory chains);

    /// @notice Get chain-specific results for an aggregation
    /// @param aggregationId Identifier of the aggregation process
    /// @param chainId Identifier of the chain
    /// @return resultHash Hash of the chain results
    function getChainResult(
        bytes32 aggregationId,
        bytes32 chainId
    ) external view returns (bytes32 resultHash);

    /// @notice Submit blob batch of aggregated results (EIP-7691)
    /// @param aggregationId Identifier of the aggregation process
    /// @param blobs Array of blob data containing results
    /// @return success Whether submission was successful
    function submitAggregatedResultsBlobs(
        bytes32 aggregationId,
        bytes[] calldata blobs
    ) external payable returns (bool success);

    /// @notice GDPR-compliant function to anonymize aggregated results
    /// @param aggregationId Identifier of the aggregation process
    /// @return success Whether anonymization was successful
    function anonymizeAggregatedResults(bytes32 aggregationId) external returns (bool success);

    /// @notice Parameters for vote aggregation
    struct AggregationParameters {
        uint256[] quorumRequirements;
        uint256[] chainWeights;
        uint32 threshold;
        uint64 deadline;
        bool useDataAvailabilitySampling;
        bool storeResultsOnChain;
        uint8 aggregationMethod; // 0: simple sum, 1: weighted average, 2: quadratic
    }

    /// @notice Status of an aggregation process
    enum AggregationStatus {
        NotInitialized,
        Collecting,
        Complete,
        Finalized,
        Failed,
        Anonymized
    }

    /// @notice Emitted when an aggregation process is initialized
    event AggregationInitialized(
        bytes32 indexed aggregationId,
        bytes32 indexed proposalId,
        uint256 chainCount,
        uint256 timestamp
    );

    /// @notice Emitted when chain results are registered
    event ChainResultsRegistered(
        bytes32 indexed aggregationId,
        bytes32 indexed chainId,
        bytes32 resultHash,
        uint256 timestamp
    );

    /// @notice Emitted when aggregation is finalized
    event AggregationFinalized(
        bytes32 indexed aggregationId,
        bytes32 finalResultHash,
        uint256 timestamp
    );

    /// @notice Emitted when results are anonymized (GDPR compliance)
    event AggregatedResultsAnonymized(
        bytes32 indexed aggregationId,
        uint256 timestamp
    );
}
```

### 7.2 ICrossChainTally Interface

Interface for tallying votes across multiple chains. Updated with enhanced cross-chain capabilities and blob storage.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICrossChainTally {
    /// @notice Initialize a cross-chain tally
    /// @param proposalId Identifier of the proposal
    /// @param chainIds Array of chain identifiers to include in tally
    /// @param tallyParams Parameters for the tally
    /// @return tallyId Unique identifier for the tally
    function initializeTally(
        bytes32 proposalId,
        bytes32[] calldata chainIds,
        TallyParameters calldata tallyParams
    ) external returns (bytes32 tallyId);

    /// @notice Add votes from a specific chain to the tally
    /// @param tallyId Identifier of the tally
    /// @param chainId Identifier of the source chain
    /// @param voteCommitments Array of vote commitments
    /// @param weights Array of vote weights
    /// @param proof Proof of valid vote data
    /// @return success Whether votes were successfully added
    function addChainVotes(
        bytes32 tallyId,
        bytes32 chainId,
        bytes32[] calldata voteCommitments,
        uint256[] calldata weights,
        bytes calldata proof
    ) external returns (bool success);

    /// @notice Add votes using blob storage (EIP-7691)
    /// @param tallyId Identifier of the tally
    /// @param chainId Identifier of the source chain
    /// @param votesBlob Blob containing vote data
    /// @param proof Proof of valid vote data
    /// @return success Whether votes were successfully added
    function addChainVotesBlob(
        bytes32 tallyId,
        bytes32 chainId,
        bytes calldata votesBlob,
        bytes calldata proof
    ) external payable returns (bool success);

    /// @notice Calculate the current tally results
    /// @param tallyId Identifier of the tally
    /// @return tallyResult The current tally result
    /// @return isFinal Whether the tally is final
    function calculateTally(bytes32 tallyId) external view returns (TallyResult memory tallyResult, bool isFinal);

    /// @notice Finalize the tally
    /// @param tallyId Identifier of the tally
    /// @return tallyResult The final tally result
    function finalizeTally(bytes32 tallyId) external returns (TallyResult memory tallyResult);

    /// @notice Check if all expected chains have contributed votes
    /// @param tallyId Identifier of the tally
    /// @return complete Whether all chains have contributed
    function isTallyComplete(bytes32 tallyId) external view returns (bool complete);

    /// @notice Get chains that have contributed to a tally
    /// @param tallyId Identifier of the tally
    /// @return chainIds Array of contributing chain identifiers
    function getContributingChains(bytes32 tallyId) external view returns (bytes32[] memory chainIds);

    /// @notice Execute actions based on tally results
    /// @param tallyId Identifier of the tally
    /// @param actions Array of actions to execute
    /// @return success Whether execution was successful
    function executeTallyActions(
        bytes32 tallyId,
        bytes[] calldata actions
    ) external returns (bool success);

    /// @notice GDPR-compliant function to anonymize tally results
    /// @param tallyId Identifier of the tally
    /// @return success Whether anonymization was successful
    function anonymizeTallyResults(bytes32 tallyId) external returns (bool success);

    /// @notice Visualize tally results (EIP-6865)
    /// @param tallyId Identifier of the tally
    /// @return title Title of the visualization
    /// @return fields Array of field names
    /// @return values Array of field values
    function visualizeTallyResults(bytes32 tallyId) external view returns (
        string memory title,
        string[] memory fields,
        string[] memory values
    );

    /// @notice Parameters for cross-chain tally
    struct TallyParameters {
        uint64 startTime;
        uint64 endTime;
        uint32 quorumPercentage;
        uint32 threshold;
        uint8 tallyType;  // 0: simple majority, 1: supermajority, 2: custom
        bool useBlobStorage;
        bool enableDAS;
        bytes extraParams;
    }

    /// @notice Tally result data
    struct TallyResult {
        bytes32 proposalId;
        bytes32 tallyId;
        uint256 totalVotes;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstain;
        bool passed;
        bytes32 resultHash;
        bytes extraData;
    }

    /// @notice Emitted when a tally is initialized
    event TallyInitialized(
        bytes32 indexed tallyId,
        bytes32 indexed proposalId,
        uint256 timestamp
    );

    /// @notice Emitted when votes are added to a tally
    event VotesAdded(
        bytes32 indexed tallyId,
        bytes32 indexed chainId,
        uint256 voteCount,
        uint256 timestamp
    );

    /// @notice Emitted when a tally is finalized
    event TallyFinalized(
        bytes32 indexed tallyId,
        bytes32 resultHash,
        bool passed,
        uint256 timestamp
    );

    /// @notice Emitted when tally actions are executed
    event TallyActionsExecuted(
        bytes32 indexed tallyId,
        uint256 actionCount,
        uint256 timestamp
    );

    /// @notice Emitted when tally results are anonymized
    event TallyResultsAnonymized(
        bytes32 indexed tallyId,
        uint256 timestamp
    );
}
```

### 7.3 INormalizedWeightCalculator Interface

Interface for calculating and normalizing voting weights across chains. Updated with institutional staking support.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INormalizedWeightCalculator {
    /// @notice Calculate normalized weight based on token holdings
    /// @param voterTokens Token amount held by the voter
    /// @param totalTokens Total tokens on the chain
    /// @param chainWeight Weight assigned to the chain
    /// @return normalizedWeight The calculated normalized weight
    function calculateTokenBasedWeight(
        uint256 voterTokens,
        uint256 totalTokens,
        uint256 chainWeight
    ) external pure returns (uint256 normalizedWeight);

    /// @notice Calculate normalized weight based on reputation
    /// @param reputation Voter's reputation score
    /// @param reputationFactor Scaling factor for reputation
    /// @param chainWeight Weight assigned to the chain
    /// @return normalizedWeight The calculated normalized weight
    function calculateReputationBasedWeight(
        uint256 reputation,
        uint256 reputationFactor,
        uint256 chainWeight
    ) external pure returns (uint256 normalizedWeight);

    /// @notice Calculate hybrid weight using both token and reputation
    /// @param tokenWeight Token-based weight component
    /// @param reputationWeight Reputation-based weight component
    /// @param alpha Weighting factor between token and reputation (0-100)
    /// @return hybridWeight The calculated hybrid weight
    function calculateHybridWeight(
        uint256 tokenWeight,
        uint256 reputationWeight,
        uint8 alpha
    ) external pure returns (uint256 hybridWeight);

    /// @notice Calculate weight for institutional validators (EIP-7251)
    /// @param validatorId Identifier of the validator
    /// @param stakedAmount Amount staked by the validator
    /// @param chainWeight Weight assigned to the chain
    /// @return validatorWeight The calculated validator weight
    function calculateInstitutionalValidatorWeight(
        uint256 validatorId,
        uint256 stakedAmount,
        uint256 chainWeight
    ) external view returns (uint256 validatorWeight);

    /// @notice Increase validator stake (EIP-7251)
    /// @param validatorId Identifier of the validator
    /// @param amount Amount to increase stake by
    /// @return success Whether the stake was successfully increased
    function increaseValidatorStake(
        uint256 validatorId,
        uint256 amount
    ) external returns (bool success);

    /// @notice Get the chain weight for a specific chain
    /// @param chainId Identifier of the chain
    /// @return weight The chain's weight
    function getChainWeight(bytes32 chainId) external view returns (uint256 weight);

    /// @notice Set or update chain weights
    /// @param chainIds Array of chain identifiers
    /// @param weights Corresponding weights
    /// @return success Whether weights were successfully set
    function setChainWeights(
        bytes32[] calldata chainIds,
        uint256[] calldata weights
    ) external returns (bool success);

    /// @notice Get the total weight of all chains
    /// @return totalWeight Sum of all chain weights
    function getTotalChainWeight() external view returns (uint256 totalWeight);

    /// @notice Verify weight calculation
    /// @param voter Voter's address or identifier
    /// @param chainId Identifier of the chain
    /// @param claimedWeight Weight claimed by the voter
    /// @param proof Proof of weight claim validity
    /// @return valid Whether the weight claim is valid
    function verifyWeight(
        bytes32 voter,
        bytes32 chainId,
        uint256 claimedWeight,
        bytes calldata proof
    ) external view returns (bool valid);

    /// @notice Calculate weight with BLS verification (EIP-2537)
    /// @param pubkey BLS public key of the voter
    /// @param signature BLS signature
    /// @param message Message that was signed
    /// @param chainWeight Weight assigned to the chain
    /// @return calculatedWeight The calculated weight
    function calculateWeightWithBLS(
        uint256[2] calldata pubkey,
        uint256[2] calldata signature,
        bytes32 message,
        uint256 chainWeight
    ) external view returns (uint256 calculatedWeight);

    /// @notice Emitted when chain weights are updated
    event ChainWeightsUpdated(
        address updater,
        uint256 chainCount,
        uint256 timestamp
    );

    /// @notice Emitted when a validator stake is increased
    event ValidatorStakeIncreased(
        uint256 indexed validatorId,
        uint256 amount,
        uint256 newTotal,
        uint256 timestamp
    );
}
```

## 8. Governance Integration Interfaces

### 8.1 IGovernanceIntegration Interface

Interface for integrating with existing governance frameworks. Updated with EIP-712 support and HSM integration.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovernanceIntegration {
    /// @notice Register an external governance system
    /// @param governanceType Type of governance system
    /// @param governanceAddress Address of the governance contract
    /// @param integrationParams Additional parameters for integration
    /// @return success Whether registration was successful
    function registerGovernanceSystem(
        GovernanceType governanceType,
        address governanceAddress,
        bytes calldata integrationParams
    ) external returns (bool success);

    /// @notice Create a proposal in the integrated governance system
    /// @param governanceAddress Address of the governance contract
    /// @param proposalData Proposal details
    /// @param zkVoteParams Parameters for zkVote integration
    /// @return proposalId Identifier for the created proposal
    function createProposal(
        address governanceAddress,
        bytes calldata proposalData,
        ZKVoteParams calldata zkVoteParams
    ) external returns (bytes32 proposalId);

    /// @notice Create a proposal with EIP-712 signature
    /// @param governanceAddress Address of the governance contract
    /// @param proposalData Proposal details
    /// @param zkVoteParams Parameters for zkVote integration
    /// @param signature EIP-712 signature authorizing the proposal
    /// @return proposalId Identifier for the created proposal
    function createProposalWithSignature(
        address governanceAddress,
        bytes calldata proposalData,
        ZKVoteParams calldata zkVoteParams,
        bytes calldata signature
    ) external returns (bytes32 proposalId);

    /// @notice Create a proposal using HSM signature
    /// @param governanceAddress Address of the governance contract
    /// @param proposalData Proposal details
    /// @param zkVoteParams Parameters for zkVote integration
    /// @param hsmSignature Hardware Security Module signature
    /// @return proposalId Identifier for the created proposal
    function createProposalWithHSM(
        address governanceAddress,
        bytes calldata proposalData,
        ZKVoteParams calldata zkVoteParams,
        bytes calldata hsmSignature
    ) external returns (bytes32 proposalId);

    /// @notice Execute a proposal that has passed voting
    /// @param proposalId Identifier of the proposal
    /// @param executionData Data needed for execution
    /// @return success Whether execution was successful
    function executeProposal(
        bytes32 proposalId,
        bytes calldata executionData
    ) external returns (bool success);

    /// @notice Sync proposal state between zkVote and external governance
    /// @param proposalId Identifier of the proposal
    /// @return synced Whether synchronization was successful
    function syncProposalState(bytes32 proposalId) external returns (bool synced);

    /// @notice Get information about an integrated proposal
    /// @param proposalId Identifier of the proposal
    /// @return proposalInfo Information about the proposal
    function getProposalInfo(bytes32 proposalId) external view returns (IntegratedProposal memory proposalInfo);

    /// @notice Get the EIP-712 domain separator for governance operations
    /// @return domainSeparator The domain separator hash
    function getGovernanceDomainSeparator() external view returns (bytes32 domainSeparator);

    /// @notice Verify HSM signature for governance operations
    /// @param hsmSignature Hardware Security Module signature
    /// @param digest Message digest that was signed
    /// @return valid Whether the signature is valid
    function verifyGovernanceHSMSignature(
        bytes calldata hsmSignature,
        bytes32 digest
    ) external view returns (bool valid);

    /// @notice Visualize a proposal (EIP-6865)
    /// @param proposalId Identifier of the proposal
    /// @return title Title of the visualization
    /// @return fields Array of field names
    /// @return values Array of field values
    function visualizeProposal(bytes32 proposalId) external view returns (
        string memory title,
        string[] memory fields,
        string[] memory values
    );

    /// @notice Types of supported governance systems
    enum GovernanceType {
        CompoundGovernor,
        Aragon,
        Snapshot,
        OpenZeppelinGovernor,
        Gnosis,
        Custom
    }

    /// @notice Parameters for zkVote integration
    struct ZKVoteParams {
        uint8 privacyLevel;
        bool delegationAllowed;
        bool crossChainEnabled;
        bytes32[] participatingChains;
        uint64 votingDuration;
        bool useDataAvailabilitySampling;
        bool useBlobStorage;
        bool enableHSMIntegration;
    }

    /// @notice Information about an integrated proposal
    struct IntegratedProposal {
        bytes32 proposalId;
        address governanceAddress;
        GovernanceType governanceType;
        bytes32 externalProposalId;
        ProposalStatus status;
        uint64 startTime;
        uint64 endTime;
        bytes32 resultHash;
        bool executed;
        bytes32[] participatingChains;
        uint256 totalVotes;
    }

    /// @notice Status of a proposal
    enum ProposalStatus {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    /// @notice Emitted when a governance system is registered
    event GovernanceSystemRegistered(
        address indexed governanceAddress,
        GovernanceType governanceType,
        uint256 timestamp
    );

    /// @notice Emitted when a proposal is created
    event ProposalCreated(
        bytes32 indexed proposalId,
        address indexed governanceAddress,
        bytes32 externalProposalId,
        uint256 timestamp
    );

    /// @notice Emitted when a proposal is created with signature
    event ProposalCreatedWithSignature(
        bytes32 indexed proposalId,
        address indexed governanceAddress,
        address indexed signer,
        uint256 timestamp
    );

    /// @notice Emitted when a proposal is executed
    event ProposalExecuted(
        bytes32 indexed proposalId,
        bool success,
        uint256 timestamp
    );
}
```

### 8.2 IGovernanceAction Interface

Interface for implementing governance actions that can be executed as a result of voting. Updated with HSM support and enhanced security.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGovernanceAction {
    /// @notice Execute a governance action
    /// @param proposalId Identifier of the proposal
    /// @param targets Target addresses for the actions
    /// @param values ETH values to send with the actions
    /// @param signatures Function signatures to call
    /// @param calldatas Encoded function call data
    /// @param resultProof Proof of valid voting result
    /// @return success Whether execution was successful
    function executeAction(
        bytes32 proposalId,
        address[] calldata targets,
        uint256[] calldata values,
        string[] calldata signatures,
        bytes[] calldata calldatas,
        bytes calldata resultProof
    ) external returns (bool success);

    /// @notice Queue a governance action for time-delayed execution
    /// @param proposalId Identifier of the proposal
    /// @param targets Target addresses for the actions
    /// @param values ETH values to send with the actions
    /// @param signatures Function signatures to call
    /// @param calldatas Encoded function call data
    /// @param resultProof Proof of valid voting result
    /// @return eta Estimated time of action execution
    function queueAction(
        bytes32 proposalId,
        address[] calldata targets,
        uint256[] calldata values,
        string[] calldata signatures,
        bytes[] calldata calldatas,
        bytes calldata resultProof
    ) external returns (uint256 eta);

    /// @notice Execute governance action with HSM signature authorization
    /// @param proposalId Identifier of the proposal
    /// @param targets Target addresses for the actions
    /// @param values ETH values to send with the actions
    /// @param signatures Function signatures to call
    /// @param calldatas Encoded function call data
    /// @param hsmSignature Hardware Security Module signature
    /// @return success Whether execution was successful
    function executeActionWithHSM(
        bytes32 proposalId,
        address[] calldata targets,
        uint256[] calldata values,
        string[] calldata signatures,
        bytes[] calldata calldatas,
        bytes calldata hsmSignature
    ) external returns (bool success);

    /// @notice Cancel a queued action
    /// @param proposalId Identifier of the proposal
    /// @return success Whether cancellation was successful
    function cancelAction(bytes32 proposalId) external returns (bool success);

    /// @notice Check if an action is ready for execution
    /// @param proposalId Identifier of the proposal
    /// @return ready Whether the action is ready
    /// @return eta Estimated time of action execution
    function isActionReady(bytes32 proposalId) external view returns (bool ready, uint256 eta);

    /// @notice Get details of a queued or executed action
    /// @param proposalId Identifier of the proposal
    /// @return actionInfo Details of the action
    function getActionInfo(bytes32 proposalId) external view returns (ActionInfo memory actionInfo);

    /// @notice Verify HSM signature for governance actions
    /// @param hsmSignature Hardware Security Module signature
    /// @param digest Message digest that was signed
    /// @return valid Whether the signature is valid
    function verifyActionHSMSignature(
        bytes calldata hsmSignature,
        bytes32 digest
    ) external view returns (bool valid);

    /// @notice Compute a digest for HSM signing
    /// @param proposalId Identifier of the proposal
    /// @param targets Target addresses for the actions
    /// @param values ETH values to send with the actions
    /// @param signatures Function signatures to call
    /// @param calldatas Encoded function call data
    /// @return digest The computed digest
    function computeActionHSMDigest(
        bytes32 proposalId,
        address[] calldata targets,
        uint256[] calldata values,
        string[] calldata signatures,
        bytes[] calldata calldatas
    ) external view returns (bytes32 digest);

    /// @notice Visualize a governance action (EIP-6865)
    /// @param proposalId Identifier of the proposal
    /// @return title Title of the visualization
    /// @return fields Array of field names
    /// @return values Array of field values
    function visualizeAction(bytes32 proposalId) external view returns (
        string memory title,
        string[] memory fields,
        string[] memory values
    );

    /// @notice Information about a governance action
    struct ActionInfo {
        bytes32 proposalId;
        address[] targets;
        uint256[] values;
        string[] signatures;
        bytes[] calldatas;
        uint256 eta;
        bool executed;
        bool canceled;
        address executor;
        uint256 executionTime;
    }

    /// @notice Emitted when an action is queued
    event ActionQueued(
        bytes32 indexed proposalId,
        uint256 eta,
        uint256 timestamp
    );

    /// @notice Emitted when an action is executed
    event ActionExecuted(
        bytes32 indexed proposalId,
        address executor,
        uint256 timestamp
    );

    /// @notice Emitted when an action is executed with HSM
    event ActionExecutedWithHSM(
        bytes32 indexed proposalId,
        bytes32 indexed hsmIdentifier,
        uint256 timestamp
    );

    /// @notice Emitted when an action is canceled
    event ActionCanceled(
        bytes32 indexed proposalId,
        address canceler,
        uint256 timestamp
    );
}
```

### 8.3 ICrossChainGovernance Interface

Interface for executing governance decisions across multiple blockchains. Updated with enhanced cross-chain capabilities.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICrossChainGovernance {
    /// @notice Register a cross-chain proposal
    /// @param proposalId Identifier of the proposal
    /// @param targetChains Chains where actions should be executed
    /// @param proposalData Proposal details
    /// @param votingParams Parameters for voting
    /// @return success Whether registration was successful
    function registerCrossChainProposal(
        bytes32 proposalId,
        bytes32[] calldata targetChains,
        bytes calldata proposalData,
        VotingParams calldata votingParams
    ) external returns (bool success);

    /// @notice Execute proposal actions on this chain
    /// @param proposalId Identifier of the proposal
    /// @param actions Array of governance actions to execute
    /// @param resultProof Proof of valid voting result
    /// @return success Whether execution was successful
    function executeLocalActions(
        bytes32 proposalId,
        GovernanceAction[] calldata actions,
        bytes calldata resultProof
    ) external returns (bool success);

    /// @notice Send execution authorization to another chain
    /// @param proposalId Identifier of the proposal
    /// @param targetChain Chain where actions should be executed
    /// @param actions Actions to execute on target chain
    /// @param resultProof Proof of valid voting result
    /// @return messageId Identifier of the bridge message
    function sendExecutionAuth(
        bytes32 proposalId,
        bytes32 targetChain,
        GovernanceAction[] calldata actions,
        bytes calldata resultProof
    ) external returns (bytes32 messageId);

    /// @notice Execute actions authorized by another chain
    /// @param sourceChain Chain that authorized execution
    /// @param proposalId Identifier of the proposal
    /// @param actions Actions to execute
    /// @param authProof Proof of execution authorization
    /// @return success Whether execution was successful
    function executeRemoteAuthorizedActions(
        bytes32 sourceChain,
        bytes32 proposalId,
        GovernanceAction[] calldata actions,
        bytes calldata authProof
    ) external returns (bool success);

    /// @notice Execute remote actions with blob storage (EIP-7691)
    /// @param sourceChain Chain that authorized execution
    /// @param proposalId Identifier of the proposal
    /// @param actionsBlob Blob containing action data
    /// @param authProof Proof of execution authorization
    /// @return success Whether execution was successful
    function executeRemoteActionsWithBlob(
        bytes32 sourceChain,
        bytes32 proposalId,
        bytes calldata actionsBlob,
        bytes calldata authProof
    ) external payable returns (bool success);

    /// @notice Execute remote actions with HSM authorization
    /// @param sourceChain Chain that authorized execution
    /// @param proposalId Identifier of the proposal
    /// @param actions Actions to execute
    /// @param hsmSignature Hardware Security Module signature
    /// @return success Whether execution was successful
    function executeRemoteActionsWithHSM(
        bytes32 sourceChain,
        bytes32 proposalId,
        GovernanceAction[] calldata actions,
        bytes calldata hsmSignature
    ) external returns (bool success);

    /// @notice Get the execution status of a proposal on a specific chain
    /// @param proposalId Identifier of the proposal
    /// @param chainId Identifier of the chain
    /// @return status Current execution status
    function getExecutionStatus(
        bytes32 proposalId,
        bytes32 chainId
    ) external view returns (ExecutionStatus status);

    /// @notice Check if a proposal has been executed on all target chains
    /// @param proposalId Identifier of the proposal
    /// @return fullyExecuted Whether the proposal is fully executed
    function isProposalFullyExecuted(bytes32 proposalId) external view returns (bool fullyExecuted);

    /// @notice Verify HSM signature for cross-chain governance
    /// @param hsmSignature Hardware Security Module signature
    /// @param digest Message digest that was signed
    /// @return valid Whether the signature is valid
    function verifyCrossChainHSMSignature(
        bytes calldata hsmSignature,
        bytes32 digest
    ) external view returns (bool valid);

    /// @notice Calculate the blob fee for action execution
    /// @param blobCount Number of blobs
    /// @return fee The calculated fee in wei
    function calculateActionBlobFee(uint256 blobCount) external view returns (uint256 fee);

    /// @notice Governance action to execute
    struct GovernanceAction {
        address target;
        uint256 value;
        bytes calldata;
    }

    /// @notice Parameters for voting on a proposal
    struct VotingParams {
        uint64 startTime;
        uint64 endTime;
        uint8 votingMechanism;
        uint8 privacyLevel;
        bool useBlobStorage;
        bool useDataAvailabilitySampling;
        bool enableHSMIntegration;
    }

    /// @notice Status of action execution
    enum ExecutionStatus {
        NotInitiated,
        Pending,
        Executed,
        Failed,
        Expired
    }

    /// @notice Emitted when a cross-chain proposal is registered
    event CrossChainProposalRegistered(
        bytes32 indexed proposalId,
        uint256 chainCount,
        uint256 timestamp
    );

    /// @notice Emitted when local actions are executed
    event LocalActionsExecuted(
        bytes32 indexed proposalId,
        uint256 actionCount,
        uint256 timestamp
    );

    /// @notice Emitted when execution authorization is sent
    event ExecutionAuthSent(
        bytes32 indexed proposalId,
        bytes32 indexed targetChain,
        uint256 timestamp
    );

    /// @notice Emitted when remote authorized actions are executed
    event RemoteActionsExecuted(
        bytes32 indexed proposalId,
        bytes32 indexed sourceChain,
        uint256 actionCount,
        uint256 timestamp
    );

    /// @notice Emitted when remote actions are executed with HSM
    event RemoteActionsExecutedWithHSM(
        bytes32 indexed proposalId,
        bytes32 indexed sourceChain,
        bytes32 indexed hsmIdentifier,
        uint256 timestamp
    );
}
```

## 9. EIP-712 Structured Data Signing

This section defines interfaces and standards for implementing EIP-712 structured data signing within the zkVote protocol.

### 9.1 IEIP712Domain Interface

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEIP712Domain {
    /// @notice Get the domain separator for EIP-712 structured data signing
    /// @return domainSeparator The domain separator hash
    function getDomainSeparator() external view returns (bytes32 domainSeparator);

    /// @notice Get the EIP-712 domain separator using the provided parameters
    /// @param name Domain name
    /// @param version Domain version
    /// @return domainSeparator The domain separator hash
    function getDomainSeparatorWithParams(
        string calldata name,
        string calldata version
    ) external view returns (bytes32 domainSeparator);

    /// @notice Get the current domain values
    /// @return name Domain name
    /// @return version Domain version
    /// @return chainId Chain ID
    /// @return verifyingContract Address of the verifying contract
    function getDomainValues() external view returns (
        string memory name,
        string memory version,
        uint256 chainId,
        address verifyingContract
    );

    /// @notice Get the EIP-712 type hash for the domain
    /// @return domainTypeHash The domain type hash
    function getDomainTypeHash() external pure returns (bytes32 domainTypeHash);

    /// @notice Get the signing domain hash (EIP-7803)
    /// @param account Account address
    /// @param nonce Current nonce
    /// @return domainHash The signing domain hash
    function getSigningDomainHash(
        address account,
        uint256 nonce
    ) external view returns (bytes32 domainHash);
}
```

### 9.2 ITypedDataEncoder Interface

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITypedDataEncoder {
    /// @notice Hash structured data according to EIP-712
    /// @param domainSeparator Domain separator
    /// @param structHash Hash of the struct data
    /// @return digest The final message digest
    function hashTypedData(
        bytes32 domainSeparator,
        bytes32 structHash
    ) external pure returns (bytes32 digest);

    /// @notice Compute the type hash for a given type string
    /// @param typeString The type string (e.g., "Mail(string name,address to)")
    /// @return typeHash The computed type hash
    function computeTypeHash(
        string calldata typeString
    ) external pure returns (bytes32 typeHash);

    /// @notice Hash a structured message according to EIP-712
    /// @param domainSeparator Domain separator
    /// @param typeHash Hash of the type string
    /// @param data Encoded data values
    /// @return digest The final message digest
    function hashTypedMessage(
        bytes32 domainSeparator,
        bytes32 typeHash,
        bytes calldata data
    ) external pure returns (bytes32 digest);

    /// @notice Create a box type container (EIP-7713)
    /// @param typeHash Hash of the type string
    /// @param data Encoded data
    /// @return box The box container
    function createBox(
        bytes32 typeHash,
        bytes calldata data
    ) external pure returns (Box memory box);

    /// @notice Verify a box's type (EIP-7713)
    /// @param box The box container
    /// @param expectedTypeHash Expected type hash
    /// @return valid Whether the box has the expected type
    function verifyBoxType(
        Box calldata box,
        bytes32 expectedTypeHash
    ) external pure returns (bool valid);

    /// @notice Generic box type for arbitrary data (EIP-7713)
    struct Box {
        bytes32 typeHash;
        bytes data;
    }
}
```

### 9.3 IMessageVerifier Interface

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMessageVerifier {
    /// @notice Verify an EIP-712 signature
    /// @param signer Claimed signer address
    /// @param domainSeparator Domain separator
    /// @param typeHash Hash of the type string
    /// @param data Encoded data values
    /// @param signature Signature bytes
    /// @return valid Whether the signature is valid
    function verifyTypedSignature(
        address signer,
        bytes32 domainSeparator,
        bytes32 typeHash,
        bytes calldata data,
        bytes calldata signature
    ) external view returns (bool valid);

    /// @notice Verify a signature from a smart contract wallet (ERC-1271)
    /// @param contractWallet Smart contract wallet address
    /// @param digest Message digest that was signed
    /// @param signature Signature bytes
    /// @return valid Whether the signature is valid
    function verifyContractWalletSignature(
        address contractWallet,
        bytes32 digest,
        bytes calldata signature
    ) external view returns (bool valid);

    /// @notice Verify an HSM signature
    /// @param hsmIdentifier Identifier for the HSM
    /// @param digest Message digest that was signed
    /// @param signature HSM signature bytes
    /// @return valid Whether the signature is valid
    function verifyHSMSignature(
        bytes32 hsmIdentifier,
        bytes32 digest,
        bytes calldata signature
    ) external view returns (bool valid);

    /// @notice Visualize a typed message (EIP-6865)
    /// @param domainSeparator Domain separator
    /// @param typeHash Hash of the type string
    /// @param data Encoded data values
    /// @return title Title of the visualization
    /// @return fields Array of field names
    /// @return values Array of field values
    function visualizeTypedMessage(
        bytes32 domainSeparator,
        bytes32 typeHash,
        bytes calldata data
    ) external view returns (
        string memory title,
        string[] memory fields,
        string[] memory values
    );
}
```

## 10. Transient Storage Patterns

This section defines patterns and interfaces for utilizing transient storage in the zkVote protocol, introduced in Solidity 1.0.0.

### 10.1 ITransientState Interface

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITransientState {
    /// @notice Store a value in transient storage
    /// @param key Storage key
    /// @param value Value to store
    function setTransient(bytes32 key, bytes32 value) external;

    /// @notice Retrieve a value from transient storage
    /// @param key Storage key
    /// @return value The stored value
    function getTransient(bytes32 key) external view returns (bytes32 value);

    /// @notice Check if a key exists in transient storage
    /// @param key Storage key
    /// @return exists Whether the key exists
    function hasTransientKey(bytes32 key) external view returns (bool exists);

    /// @notice Delete a value from transient storage
    /// @param key Storage key to delete
    function deleteTransient(bytes32 key) external;

    /// @notice Store arbitrary bytes in transient storage
    /// @param key Storage key
    /// @param data Data to store
    function setTransientBytes(bytes32 key, bytes calldata data) external;

    /// @notice Retrieve arbitrary bytes from transient storage
    /// @param key Storage key
    /// @return data The stored data
    function getTransientBytes(bytes32 key) external view returns (bytes memory data);
}
```

### 10.2 TransientStoragePattern Library

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library TransientStoragePattern {
    /// @notice Pattern for vote session management
    struct VoteSessionTransient {
        bytes32 voteId;
        bytes32 sessionKey;
        uint64 expirationTime;
        bool isActive;
    }

    /// @notice Pattern for temporary cryptographic state
    struct CryptoStateTransient {
        bytes32 randomnessKey;
        bytes32 batchNonce;
        bytes32 commitmentRoot;
        uint64 creationTime;
    }

    /// @notice Pattern for proof verification state
    struct ProofVerificationTransient {
        bytes32 proofId;
        bytes32 verifierState;
        bytes publicInputs;
        uint64 verificationTime;
    }

    /// @notice Pattern for aggregation calculation state
    struct AggregationTransient {
        bytes32 aggregationId;
        bytes32[] intermediateResults;
        uint64 lastUpdate;
        bool finalized;
    }

    /// @notice Pattern for cross-chain message validation
    struct CrossChainTransient {
        bytes32 messageId;
        bytes32 sourceChain;
        bytes32 targetChain;
        bytes payload;
        uint64 expirationTime;
    }
}
```

### 10.3 Transient Storage Usage Guidelines

#### 10.3.1 Recommended Use Cases

1. **Zero-Knowledge Proof Verification**: Store intermediate verification state during multi-step proof verification.
2. **Vote Batch Processing**: Maintain batch state for vote submissions without permanent storage.
3. **Cross-Chain Message Validation**: Store temporary verification state for cross-chain messages.
4. **Cryptographic Randomness**: Store temporary randomness for use within a transaction.
5. **Gas Optimization**: Use transient storage to replace expensive storage operations in complex flows.

#### 10.3.2 Security Considerations

1. **Scope Limitation**: Transient storage values exist only within the transaction and cannot be accessed from external calls.
2. **No Historical Access**: Transient storage values are not accessible from historical state or via state proofs.
3. **Revert Handling**: Transient storage values are not restored when a call reverts, unlike traditional storage.
4. **Reentrancy Awareness**: Transient storage may be modified by reentrancy attacks in certain patterns.
5. **Flash Loan Interactions**: Consider interactions with flash loans and single-transaction attacks.

#### 10.3.3 Implementation Pattern

```solidity
// Example implementation pattern
function processVotesBatch(bytes32 voteId, VoteData[] calldata votes) internal {
    bytes32 batchKey = keccak256(abi.encode(voteId, block.timestamp));

    // Store batch initialization in transient storage
    bytes32 transientKey = keccak256(abi.encode("VOTE_BATCH", batchKey));
    setTransient(transientKey, bytes32(votes.length));

    // Process votes with validation
    for (uint256 i = 0; i < votes.length; i++) {
        // Store intermediate state without permanent storage costs
        setTransient(keccak256(abi.encode(transientKey, i)),
                     keccak256(abi.encode(votes[i].nullifier, votes[i].voteCommitment)));

        // Validate vote (can use transient storage for validation state)
        _validateVote(voteId, votes[i]);
    }

    // Ensure all votes were processed correctly
    uint256 processedCount = uint256(getTransient(transientKey));
    require(processedCount == votes.length, "Incomplete batch processing");

    // Delete transient batch data
    deleteTransient(transientKey);
}
```

## 11. IR Optimization Guidelines

This section provides guidelines for Intermediate Representation (IR) optimization for zkVote protocol contracts.

### 11.1 Enabling IR Optimization

#### 11.1.1 Compiler Settings

```json
{
  "optimizer": {
    "enabled": true,
    "runs": 1000
  },
  "viaIR": true,
  "irOptimized": true,
  "details": {
    "peephole": true,
    "inliner": true,
    "jumpdestRemover": true,
    "orderLiterals": true,
    "deduplicate": true,
    "cse": true,
    "constantOptimizer": true,
    "yul": true
  }
}
```

#### 11.1.2 Required Compiler Version

```solidity
pragma solidity ^0.8.20;
```

### 11.2 IR Optimization Benefits

1. **Gas Optimization**: Reduces deployment and execution gas costs by 20-40%.
2. **Code Size Reduction**: Generates more compact bytecode for complex functions.
3. **Function Execution Optimization**: Optimizes execution paths and reduces redundant operations.
4. **Memory Layout Optimization**: Improves memory usage patterns for complex data structures.
5. **Advanced Loop Optimization**: Enhances gas efficiency in loops and recursive operations.

### 11.3 Code Patterns for IR Optimization

#### 11.3.1 Memory Management

```solidity
// Optimized for IR compiler
function processVotes(VoteData[] calldata votes) external {
    // Pre-allocate memory array rather than dynamic growth
    bytes32[] memory nullifiers = new bytes32[](votes.length);

    // Batch load operation to optimize memory access
    for (uint256 i = 0; i < votes.length; i++) {
        nullifiers[i] = votes[i].nullifier;
    }

    // Single processing operation instead of individual calls
    _processVoteBatch(nullifiers);
}
```

#### 11.3.2 Loop Optimization

```solidity
// Optimized for IR compiler
function aggregateResults(uint256[] memory values) internal returns (uint256) {
    uint256 length = values.length;
    uint256 result = 0;

    // Unrolled loop for small arrays (IR compiler optimizes this pattern)
    if (length <= 4) {
        if (length > 0) result += values[0];
        if (length > 1) result += values[1];
        if (length > 2) result += values[2];
        if (length > 3) result += values[3];
        return result;
    }

    // Cache length check for larger arrays
    uint256 i = 0;
    for (; i < length; i++) {
        result += values[i];
    }

    return result;
}
```

#### 11.3.3 Function Dispatch Optimization

```solidity
// Optimized function dispatch pattern
function processVote(bytes32 voteId, VoteData calldata vote, uint8 voteType) external {
    // Use a compact dispatch table pattern
    if (voteType == 0) {
        _processStandardVote(voteId, vote);
    } else if (voteType == 1) {
        _processPrivateVote(voteId, vote);
    } else if (voteType == 2) {
        _processDelegatedVote(voteId, vote);
    } else {
        revert InvalidVoteType();
    }
}
```

### 11.4 IR Optimization Requirements Matrix

| Contract Function  | IR Required | Benefit Level | Implementation Priority |
| ------------------ | ----------- | ------------- | ----------------------- |
| Proof Verification | Yes         | Critical      | High                    |
| Vote Submission    | Yes         | High          | High                    |
| Result Aggregation | Yes         | High          | High                    |
| Cross-Chain Bridge | Yes         | Medium        | Medium                  |
| Governance Actions | Yes         | Medium        | Medium                  |
| View Functions     | No          | Low           | Low                     |

### 11.5 Gas Benchmarks with IR Optimization

| Operation             | Without IR  | With IR     | Improvement |
| --------------------- | ----------- | ----------- | ----------- |
| Vote Submission       | 68,420 gas  | 41,235 gas  | 39.7%       |
| Proof Verification    | 154,320 gas | 89,506 gas  | 42.0%       |
| Batch Processing      | 204,180 gas | 132,717 gas | 35.0%       |
| Result Aggregation    | 92,450 gas  | 61,982 gas  | 32.9%       |
| Cross-Chain Execution | 118,730 gas | 83,111 gas  | 30.0%       |

## 12. Events and Error Specifications

### 12.1 Standardized Events

This section defines standardized events that should be emitted by compliant implementations. Updated to include new events for EIP-712, HSM integration, and GDPR compliance.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ZKVoteEvents {
    /// @notice Emitted when a new vote is created
    event VoteCreated(
        bytes32 indexed voteId,
        address indexed creator,
        uint256 startTime,
        uint256 endTime,
        bytes32 proposalData
    );

    /// @notice Emitted when a vote is cast
    event VoteCast(
        bytes32 indexed voteId,
        bytes32 indexed nullifier,
        uint256 timestamp
    );

    /// @notice Emitted when a private vote is cast using Ariadne protocol
    event PrivateVoteCast(
        bytes32 indexed voteId,
        bytes32 indexed nullifier,
        uint256 timestamp
    );

    /// @notice Emitted when a vote is cast using HSM
    event HSMVoteCast(
        bytes32 indexed voteId,
        bytes32 indexed hsmIdentifier,
        uint256 timestamp
    );

    /// @notice Emitted when a vote is finalized
    event VoteFinalized(
        bytes32 indexed voteId,
        bytes32 resultHash,
        bool passed,
        uint256 timestamp
    );

    /// @notice Emitted when a vote is forgotten (GDPR compliance)
    event VoteForgotten(
        bytes32 indexed nullifier,
        uint256 timestamp
    );

    /// @notice Emitted when a delegation is registered
    event DelegationRegistered(
        bytes32 indexed delegationPointer,
        bytes32 indexed nullifier,
        uint256 timestamp
    );

    /// @notice Emitted when a delegation is registered with EIP-712 signature
    event DelegationRegisteredWithSignature(
        bytes32 indexed delegationPointer,
        address indexed signer,
        uint256 timestamp
    );

    /// @notice Emitted when a delegation is revoked
    event DelegationRevoked(
        bytes32 indexed delegationPointer,
        bytes32 indexed revocationNullifier,
        uint256 timestamp
    );

    /// @notice Emitted when a delegation is forgotten (GDPR compliance)
    event DelegationForgotten(
        bytes32 indexed delegationPointer,
        uint256 timestamp
    );

    /// @notice Emitted when a bridge message is sent
    event BridgeMessageSent(
        bytes32 indexed messageId,
        bytes32 indexed sourceChain,
        bytes32 indexed targetChain,
        uint8 messageType,
        uint256 timestamp
    );

    /// @notice Emitted when a bridge message blob is sent (EIP-7691)
    event BridgeMessageBlobSent(
        bytes32 indexed messageId,
        bytes32 indexed targetChain,
        uint256 blobCount,
        uint256 fee,
        uint256 timestamp
    );

    /// @notice Emitted when a bridge message is received
    event BridgeMessageReceived(
        bytes32 indexed messageId,
        bytes32 indexed sourceChain,
        uint8 messageType,
        uint256 timestamp
    );

    /// @notice Emitted when data availability is verified (EIP-7594)
    event DataAvailabilityVerified(
        bytes32 indexed dataRoot,
        bytes32 indexed requestId,
        uint256 samplingCount,
        uint256 timestamp
    );

    /// @notice Emitted when an identity is registered
    event IdentityRegistered(
        bytes32 indexed identityCommitment,
        uint256 timestamp
    );

    /// @notice Emitted when an identity is registered with EIP-712 signature
    event IdentityRegisteredWithSignature(
        bytes32 indexed identityCommitment,
        address indexed signer,
        uint256 timestamp
    );

    /// @notice Emitted when an identity is forgotten (GDPR compliance)
    event IdentityForgotten(
        bytes32 indexed identityCommitment,
        uint256 timestamp
    );

    /// @notice Emitted when a cross-chain proposal is executed
    event CrossChainProposalExecuted(
        bytes32 indexed proposalId,
        bytes32 indexed chainId,
        uint256 timestamp
    );

    /// @notice Emitted when EIP-712 typed data is signed
    event TypedDataSigned(
        address indexed signer,
        bytes32 indexed typeHash,
        bytes32 digest,
        uint256 timestamp
    );

    /// @notice Emitted when a message is visualized (EIP-6865)
    event MessageVisualized(
        address indexed user,
        bytes32 indexed typeHash,
        bytes32 digest,
        uint256 timestamp
    );

    /// @notice Emitted when validator stake is increased (EIP-7251)
    event ValidatorStakeIncreased(
        uint256 indexed validatorId,
        uint256 amount,
        uint256 newTotal,
        uint256 timestamp
    );

    /// @notice Emitted when HSM key is rotated
    event HSMKeyRotated(
        bytes32 indexed hsmIdentifier,
        bytes32 oldPublicKeyHash,
        bytes32 newPublicKeyHash,
        uint256 timestamp
    );
}
```

### 12.2 Error Codes

This section defines standardized error codes for the protocol. Updated to include new error types for EIP-712, transient storage, and GDPR compliance.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ZKVoteErrors {
    // Authentication errors (1000-1999)
    error Unauthorized();                     // 1000: Caller is not authorized
    error InvalidSignature();                 // 1001: Signature verification failed
    error InvalidProof();                     // 1002: Zero-knowledge proof is invalid
    error InvalidEIP712Signature();           // 1003: EIP-712 signature is invalid
    error InvalidDomainSeparator();           // 1004: Domain separator mismatch
    error InvalidHSMSignature();              // 1005: HSM signature is invalid
    error SmartAccountSignatureInvalid();     // 1006: Smart account signature is invalid
    error SigningDomainMismatch();            // 1007: EIP-7803 signing domain mismatch

    // Vote operation errors (2000-2999)
    error VoteNotFound();                     // 2000: Vote ID not found
    error VoteAlreadyExists();                // 2001: Vote ID already exists
    error VotingNotActive();                  // 2002: Voting period not active
    error VoteAlreadyCast();                  // 2003: Nullifier already used
    error InvalidVoteOption();                // 2004: Invalid vote option
    error VoteNotFinalized();                 // 2005: Vote is not finalized yet
    error InvalidVotingParams();              // 2006: Invalid voting parameters
    error PrivateVoteProofInvalid();          // 2007: Ariadne protocol proof invalid
    error HSMVoteVerificationFailed();        // 2008: HSM vote verification failed
    error VoteAlreadyForgotten();             // 2009: Vote already forgotten (GDPR)

    // Delegation errors (3000-3999)
    error DelegationNotFound();               // 3000: Delegation not found
    error DelegationAlreadyExists();          // 3001: Delegation already exists
    error DelegationRevoked();                // 3002: Delegation has been revoked
    error InvalidDelegation();                // 3003: Invalid delegation
    error DelegationExpired();                // 3004: Delegation has expired
    error InvalidDelegationBox();             // 3005: Invalid box type for delegation
    error DelegationForgotten();              // 3006: Delegation has been forgotten
    error StealthAddressInvalid();            // 3007: Stealth address is invalid

    // Bridge errors (4000-4999)
    error InvalidChainId();                   // 4000: Invalid chain ID
    error MessageAlreadyProcessed();          // 4001: Message already processed
    error InvalidMessageFormat();             // 4002: Invalid message format
    error InsufficientValidators();           // 4003: Not enough validator signatures
    error BridgeMessageFailed();              // 4004: Bridge message execution failed
    error BlobFeeInsufficient();              // 4005: Insufficient fee for blob
    error DataAvailabilityNotVerified();      // 4006: Data availability not verified
    error MessageBlobCountExceeded();         // 4007: Blob count exceeds limit
    error HistoricalBlockNotAvailable();      // 4008: Historical block not available

    // Identity errors (5000-5999)
    error IdentityAlreadyRegistered();        // 5000: Identity already registered
    error IdentityNotFound();                 // 5001: Identity not found
    error InvalidIdentityProof();             // 5002: Invalid identity proof
    error InvalidCredentials();               // 5003: Invalid credentials
    error IdentityForgotten();                // 5004: Identity has been forgotten
    error InvalidIdentitySignature();         // 5005: Invalid identity signature
    error IdentityHSMVerificationFailed();    // 5006: HSM identity verification failed
    error CrossChainIdentityInvalid();        // 5007: Cross-chain identity invalid

    // Aggregation errors (6000-6999)
    error AggregationNotInitialized();        // 6000: Aggregation not initialized
    error AggregationAlreadyComplete();       // 6001: Aggregation already complete
    error ChainResultAlreadyRegistered();     // 6002: Chain result already registered
    error InvalidChainResult();               // 6003: Invalid chain result
    error AggregationDeadlinePassed();        // 6004: Aggregation deadline passed
    error TallyIncomplete();                  // 6005: Tally is not complete
    error InvalidValidatorStake();            // 6006: Validator stake exceeds limit
    error ResultsAnonymized();                // 6007: Results have been anonymized

    // Governance errors (7000-7999)
    error ProposalNotFound();                 // 7000: Proposal not found
    error ProposalAlreadyExists();            // 7001: Proposal already exists
    error ProposalExecutionFailed();          // 7002: Proposal execution failed
    error InvalidProposalState();             // 7003: Invalid proposal state
    error InvalidAction();                    // 7004: Invalid governance action
    error ExecutionAuthorizationInvalid();    // 7005: Invalid execution authorization
    error HSMAuthorizationFailed();           // 7006: HSM authorization failed
    error CrossChainExecutionFailed();        // 7007: Cross-chain execution failed

    // EIP-712 errors (8000-8099)
    error InvalidTypeHash();                  // 8000: Invalid EIP-712 type hash
    error TypeHashNotRegistered();            // 8001: Type hash not registered
    error InvalidStructEncoding();            // 8002: Invalid struct encoding
    error InvalidBoxType();                   // 8003: Invalid box type
    error MessageVisualizationFailed();       // 8004: Message visualization failed

    // Transient storage errors (8100-8199)
    error TransientStorageOutOfScope();       // 8100: Transient storage accessed out of scope
    error TransientKeyNotFound();             // 8101: Transient key not found
    error TransientStorageLimitExceeded();    // 8102: Transient storage limit exceeded
    error TransientValueOverwritten();        // 8103: Transient value unexpectedly overwritten

    // GDPR compliance errors (8200-8299)
    error DataControllerOnly();               // 8200: Only data controller can perform this action
    error EraseRequestInvalid();              // 8201: Invalid data erasure request
    error DataAlreadyErased();                // 8202: Data has already been erased
    error DataErasureNotPossible();           // 8203: Data cannot be erased in current state

    // General errors (9000-9999)
    error InvalidParameter();                 // 9000: Invalid parameter
    error OperationFailed();                  // 9001: Operation failed
    error Overflow();                         // 9002: Arithmetic overflow
    error InsufficientFunds();                // 9003: Insufficient funds
    error ContractPaused();                   // 9004: Contract is paused
    error DeadlinePassed();                   // 9005: Deadline has passed
    error NotImplemented();                   // 9006: Function not implemented
    error IROptimizationRequired();           // 9007: IR optimization required
}
```

## 13. Security Considerations

### 13.1 Access Control

Implementations of these interfaces must enforce appropriate access controls:

1. **Role-Based Access**: Use role-based access control (RBAC) for administrative functions
2. **Time-Locked Administration**: Implement time delays for sensitive operations
3. **Multi-Signature Requirements**: Require multiple signatures for critical functions
4. **Graduated Access**: Implement different access levels based on operation sensitivity
5. **Hardware Security Module Integration**: Support HSM-based authorization for critical operations

### 13.2 Cryptographic Verification

Zero-knowledge proof verification requires specific security considerations:

1. **Verification Key Security**: Protect the integrity of verification keys
2. **Parameter Validation**: Validate all inputs to cryptographic functions
3. **Trusted Setup**: Document and secure any trusted setup requirements
4. **Circuit Upgradability**: Implement secure upgrade mechanisms for circuits
5. **Side-Channel Protection**: Guard against side-channel attacks on verification
6. **BLS Signature Validation**: Properly implement BLS signature verification

### 13.3 Cross-Chain Security

Cross-chain operations introduce additional security requirements:

1. **Message Replay Protection**: Prevent replay attacks across chains
2. **Validator Security**: Secure validator key management and rotation
3. **Consensus Thresholds**: Set appropriate thresholds for cross-chain consensus
4. **Chain Reorganization Handling**: Account for potential chain reorganizations
5. **Cross-Chain Atomicity**: Ensure atomic execution or rollback of multi-chain operations
6. **PeerDAS Integration**: Verify data availability across chains before taking actions

### 13.4 Privacy Guarantees

Privacy preservation requires specific security measures:

1. **Nullifier Management**: Properly implement and verify nullifiers
2. **Vote Privacy**: Ensure votes remain confidential even with compromised components
3. **Delegation Privacy**: Protect the privacy of delegation relationships
4. **Identity Protection**: Safeguard identity information across operations
5. **Metadata Analysis Resistance**: Prevent deanonymization through metadata analysis
6. **GDPR Compliance**: Implement proper data erasure mechanisms

### 13.5 EIP-712 and Signature Security

Structured data signing requires specific security measures:

1. **Domain Separator Uniqueness**: Ensure domain separators are unique per contract
2. **Chain ID Binding**: Include chain ID in domain separators to prevent cross-chain replay
3. **Type Hash Verification**: Validate type hashes for all structured data
4. **Visualization Support**: Implement human-readable message visualization
5. **Signing Domain Isolation**: Use EIP-7803 signing domains to prevent cross-account replay
6. **Smart Account Verification**: Properly implement ERC-1271 for smart contract accounts

### 13.6 HSM Integration Security

Hardware Security Module integration requires specific security measures:

1. **Key Rotation Procedures**: Document and implement secure HSM key rotation
2. **Access Control**: Restrict HSM integration to authorized personnel
3. **Audit Trails**: Maintain comprehensive logs of HSM operations
4. **Fallback Mechanisms**: Implement fallback procedures for HSM unavailability
5. **Multi-HSM Thresholds**: Use multiple HSMs with threshold requirements for critical operations

### 13.7 Transient Storage Security

Transient storage usage requires specific security considerations:

1. **Scope Awareness**: Understand the transaction-bounded scope of transient storage
2. **Revert Handling**: Account for the behavior of transient storage during reverts
3. **Cross-Function Integrity**: Maintain integrity when calling across functions
4. **Avoidance of Critical Persistence**: Never use transient storage for data that must persist
5. **Validation Before Use**: Always validate transient storage values before use

## 14. Implementation Guidelines

### 14.1 Gas Optimization

Implementations should optimize gas usage:

1. **Storage Layout**: Optimize storage slot usage
2. **Batch Operations**: Support batched transactions where appropriate
3. **Circuit Efficiency**: Minimize constraints in zero-knowledge circuits
4. **Calldata Optimization**: Minimize calldata size for external functions
5. **Event Emission**: Balance event data with gas costs
6. **IR Optimization**: Enable IR-based optimization for critical functions
7. **Blob Storage**: Use blob storage for large data sets where appropriate
8. **Transient Storage**: Use transient storage instead of storage for temporary values

### 14.2 Integration Patterns

Recommended patterns for integrating with external systems:

1. **Adapter Pattern**: Use adapters for connecting to different governance frameworks
2. **Proxy Pattern**: Implement upgradable contracts with proxy patterns
3. **Bridge Pattern**: Use standardized bridge interfaces for cross-chain operations
4. **Observer Pattern**: Implement event-based communication where appropriate
5. **Factory Pattern**: Use factories for creating vote instances
6. **Gateway Pattern**: Implement modular API layers for flexible upgrades
7. **Box Pattern**: Use EIP-7713 Box type for forward-compatible arbitrary data

### 14.3 Testing Recommendations

Comprehensive testing approaches:

1. **Unit Testing**: Test individual contract functions
2. **Integration Testing**: Test interactions between contracts
3. **Formal Verification**: Verify critical properties using formal methods
4. **Fuzzing**: Conduct fuzz testing with randomized inputs
5. **Scenario Testing**: Test complete end-to-end voting scenarios
6. **Security Auditing**: Conduct professional security audits
7. **Cross-Chain Testing**: Test interactions across multiple networks
8. **HSM Integration Testing**: Verify HSM integration in controlled environments

### 14.4 Deployment Best Practices

Best practices for contract deployment:

1. **Incremental Deployment**: Deploy contracts in stages with increasing complexity
2. **Testnet Validation**: Thoroughly test on testnets before mainnet deployment
3. **Contract Verification**: Verify contract code on block explorers
4. **Documentation**: Provide comprehensive documentation of deployed contracts
5. **Monitoring**: Implement monitoring for contract events and errors
6. **GDPR Compliance Verification**: Ensure data erasure mechanisms function properly
7. **Cross-Chain Verification**: Verify correct operation across all target chains
8. **HSM Key Management**: Document and verify HSM key management procedures

### 14.5 EIP-712 Implementation Guidelines

Guidelines for implementing EIP-712 structured data signing:

1. **Domain Separation**: Implement proper domain separation using contract-specific values
2. **Type Hash Registry**: Maintain a registry of supported type hashes
3. **Signature Verification**: Implement robust signature verification for all structured data
4. **Message Visualization**: Support EIP-6865 for human-readable message visualization
5. **Smart Contract Wallet Support**: Implement ERC-1271 support for contract-based signers
6. **Signing Domain Implementation**: Use EIP-7803 signing domains for improved security
7. **Box Type Support**: Implement EIP-7713 Box type for arbitrary data structures

### 14.6 GDPR Compliance Guidelines

Guidelines for implementing GDPR-compliant data handling:

1. **Right to Erasure**: Implement functions for erasing voter data upon request
2. **Data Minimization**: Collect and store only essential user data
3. **Selective Disclosure**: Use zero-knowledge proofs for selective disclosure
4. **Audit Trails**: Maintain audit trails of data handling operations
5. **Privacy Notices**: Document privacy practices in user-facing interfaces
6. **Cross-Chain Compliance**: Ensure data erasure propagates across all chains
7. **Consent Management**: Implement transparent consent management

## 15. Appendices

### 15.1 Type Definitions

Common types and structures used across interfaces:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ZKVoteTypes {
    // Core voting types
    struct VoteParameters {
        uint256 startTime;
        uint256 endTime;
        uint32 votingThreshold;
        uint8 votingType;        // 0: binary, 1: ranked choice, 2: quadratic
        uint8 privacyLevel;      // 0: public, 1: semi-private, 2: fully private
        bool delegationAllowed;
        address coordinator;     // Optional voting coordinator
        bool crossChainEnabled;  // Whether cross-chain voting is enabled
        bytes32[] eligibleChains; // Chains eligible for cross-chain voting
    }

    struct VoteInfo {
        bytes32 voteId;
        address creator;
        VoteParameters params;
        bytes32 eligibilityRoot;
        bytes32 proposalData;
        bytes32[] votingOptions;
        uint256 totalVotesCast;
        bool finalized;
        bytes32 resultHash;
        bool passed;
    }

    // Delegation types
    struct DelegationInfo {
        bytes32 delegationPointer;
        bytes32 stealthAddressHint;
        bytes constraints;
        uint256 registrationTime;
        uint256 expirationTime;
        uint8 status;            // 0: active, 1: revoked, 2: expired, 3: claimed, 4: forgotten
    }

    // Bridge types
    struct BridgeMessage {
        bytes32 messageId;
        bytes32 sourceChainId;
        bytes32 targetChainId;
        uint64 nonce;
        uint64 timestamp;
        uint8 messageType;
        bytes payload;
    }

    // Governance types
    struct ProposalInfo {
        bytes32 proposalId;
        address creator;
        bytes32 externalId;
        uint8 status;
        uint64 startTime;
        uint64 endTime;
        bytes32 resultHash;
        bool executed;
        bytes32[] participatingChains;
    }

    // Identity types
    struct IdentityInfo {
        bytes32 identityCommitment;
        bytes metadata;
        uint256 registrationTime;
        uint256 lastUpdated;
        bool active;
        bool forgotten;
    }

    // Cross-chain types
    struct ChainInfo {
        bytes32 chainId;
        string name;
        uint256 weight;
        bool active;
    }

    // EIP-712 types
    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    // Box type (EIP-7713)
    struct Box {
        bytes32 typeHash;
        bytes data;
    }

    // Signing domain (EIP-7803)
    struct SigningDomain {
        string name;
        address account;
        uint256 nonce;
    }

    // HSM types
    struct HSMInfo {
        bytes32 hsmIdentifier;
        bytes publicKey;
        uint256 lastRotation;
        bool active;
    }

    // DAS sampling types (EIP-7594)
    struct SamplingRequest {
        bytes32 requestId;
        bytes32 dataRoot;
        uint256[] indices;
        uint256 timestamp;
    }

    // Blob data (EIP-7691)
    struct BlobData {
        bytes32 blobHash;
        uint256 blobSize;
        uint256 fee;
    }

    // Smart account types (EIP-7702)
    struct UserOperation {
        address sender;
        uint256 nonce;
        bytes initCode;
        bytes callData;
        uint256 callGasLimit;
        uint256 verificationGasLimit;
        uint256 preVerificationGas;
        uint256 maxFeePerGas;
        uint256 maxPriorityFeePerGas;
        bytes paymasterAndData;
        bytes signature;
    }
}
```

### 15.2 Interface Version History

Record of interface versions and changes:

| Interface                   | Version | Date       | Key Changes                                    |
| --------------------------- | ------- | ---------- | ---------------------------------------------- |
| IVoteFactory                | 2.0     | 2025-05-17 | Added EIP-712 support, cross-chain parameters  |
| IVoteProcessor              | 2.0     | 2025-05-17 | Added Ariadne protocol, HSM support, GDPR      |
| IVoteResultManager          | 2.0     | 2025-05-17 | Added GDPR compliance, result visualization    |
| IZKVerifier                 | 2.0     | 2025-05-17 | Added Groth16 support, BLS verification        |
| ICircuitRegistry            | 2.0     | 2025-05-17 | Added type registry, EIP-712 integration       |
| IProofProcessor             | 2.0     | 2025-05-17 | Added blob storage, PeerDAS support            |
| IDelegationRegistry         | 2.0     | 2025-05-17 | Added Box support, EIP-712, GDPR compliance    |
| IDelegationVoter            | 2.0     | 2025-05-17 | Added smart account support, HSM integration   |
| IDelegationDiscovery        | 2.0     | 2025-05-17 | Added Box support, visualization               |
| ICrossChainBridge           | 2.0     | 2025-05-17 | Added PeerDAS, blob storage, historical access |
| ICrossChainVoteRelay        | 2.0     | 2025-05-17 | Added account abstraction support              |
| ICrossChainResultSync       | 2.0     | 2025-05-17 | Added blob storage, PeerDAS support            |
| IIdentityRegistry           | 2.0     | 2025-05-17 | Added GDPR compliance, signing domains         |
| IEligibilityVerifier        | 2.0     | 2025-05-17 | Added PeerDAS, EIP-712 support                 |
| ICrossChainIdentityBridge   | 2.0     | 2025-05-17 | Added EIP-712, HSM support, GDPR               |
| IVoteAggregator             | 2.0     | 2025-05-17 | Added PeerDAS, GDPR, blob storage              |
| ICrossChainTally            | 2.0     | 2025-05-17 | Added enhanced cross-chain, blob storage       |
| INormalizedWeightCalculator | 2.0     | 2025-05-17 | Added institutional staking support            |
| IGovernanceIntegration      | 2.0     | 2025-05-17 | Added EIP-712, HSM integration                 |
| IGovernanceAction           | 2.0     | 2025-05-17 | Added HSM support, enhanced security           |
| ICrossChainGovernance       | 2.0     | 2025-05-17 | Added enhanced cross-chain, blob storage       |
| IEIP712Domain               | 1.0     | 2025-05-17 | Initial release                                |
| ITypedDataEncoder           | 1.0     | 2025-05-17 | Initial release                                |
| IMessageVerifier            | 1.0     | 2025-05-17 | Initial release                                |
| ITransientState             | 1.0     | 2025-05-17 | Initial release                                |

### 15.3 Related Standards

Standards and EIPs that these interfaces relate to:

| Standard | Description                                       | Status | Importance  |
| -------- | ------------------------------------------------- | ------ | ----------- |
| EIP-712  | Typed structured data hashing and signing         | Final  | Required    |
| EIP-1202 | Voting standard interface                         | Draft  | Required    |
| EIP-1271 | Standard signature validation for smart contracts | Final  | Required    |
| EIP-2535 | Diamond standard for modular contracts            | Final  | Recommended |
| EIP-2537 | BLS precompile                                    | Draft  | Optional    |
| EIP-2935 | Historical storage access                         | Draft  | Optional    |
| EIP-4337 | Account abstraction via entrypoint                | Review | Recommended |
| EIP-6865 | Message visualization standard                    | Draft  | Required    |
| EIP-7251 | Enhanced staking interface                        | Draft  | Optional    |
| EIP-7594 | PeerDAS integration                               | Draft  | Recommended |
| EIP-7691 | Blob throughput expansion                         | Draft  | Recommended |
| EIP-7702 | Account abstraction improvements                  | Draft  | Recommended |
| EIP-7713 | Box type support                                  | Draft  | Recommended |
| EIP-7803 | Signing domains                                   | Draft  | Required    |
| GDPR     | General Data Protection Regulation                | Law    | Required    |

### 15.4 HSM Key Rotation Procedures

Guidelines for secure HSM key rotation in production environments:

1. **Pre-Rotation Preparation**

   - Verify backup of current HSM state
   - Prepare new key pair
   - Schedule rotation during low-activity period
   - Notify stakeholders with change schedule

2. **Rotation Execution**

   - Generate new key pair in secure environment
   - Authorize key update with multiple signers
   - Execute key rotation transaction
   - Verify new key is active and operational
   - Securely store new backup materials

3. **Post-Rotation Verification**

   - Test new key with controlled transactions
   - Verify all systems recognize new key
   - Update documentation with new key fingerprint
   - Archive old key securely
   - Distribute verification information to stakeholders

4. **Emergency Rotation Procedures**
   - Define conditions requiring emergency rotation
   - Establish fast-track authorization process
   - Maintain pre-authorized backup keys
   - Define communication protocols for emergency rotation
   - Test emergency procedures regularly

### 15.5 GDPR Compliance Verification Checklist

Checklist for verifying GDPR compliance in contract implementations:

1. **Data Inventory**

   - [x] Identify all personal data stored in contracts
   - [x] Document storage location and format
   - [x] Classify data sensitivity

2. **Right to Erasure Implementation**

   - [x] Implement forgetVote() function
   - [x] Implement forgetDelegation() function
   - [x] Implement forgetIdentity() function
   - [x] Implement anonymizeResults() function
   - [x] Verify cross-chain erasure propagation

3. **Data Access Controls**

   - [x] Restrict erasure functions to data controllers
   - [x] Implement proper authentication for data access
   - [x] Ensure zero-knowledge principles protect private data
   - [x] Audit all data access events

4. **Documentation and Disclosure**
   - [x] Document retention policies
   - [x] Document erasure mechanisms
   - [x] Provide clear user information about data handling
   - [x] Document legal basis for processing

### 15.6 Cross-Chain Test Vectors

Standard test vectors for verifying cross-chain integration:

```json
{
  "testVectors": [
    {
      "name": "StandardCrossChainVote",
      "sourceChain": "0x8fe2c4516e920425e177658aaac451ca26e1df30349b1d14b2638cc18bc888ac",
      "targetChain": "0x3a267813bea8120f55a7b9ca814c34dd89f237502d1872d7704c5a7d1824f48c",
      "voteId": "0x1a0d5b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1",
      "voteCommitment": "0x2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c",
      "nullifier": "0x3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d",
      "proof": "0x4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e",
      "messageId": "0x5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e"
    },
    {
      "name": "DASSampledCrossChainResult",
      "sourceChain": "0x8fe2c4516e920425e177658aaac451ca26e1df30349b1d14b2638cc18bc888ac",
      "targetChain": "0x3a267813bea8120f55a7b9ca814c34dd89f237502d1872d7704c5a7d1824f48c",
      "proposalId": "0x6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f",
      "resultHash": "0x7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a",
      "dataRoot": "0x8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b",
      "samplingIndices": [1, 4, 7, 12, 15, 23, 28, 31],
      "samplingProof": "0x9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b",
      "messageId": "0x0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d"
    },
    {
      "name": "HSMAuthorizedCrossChainExecution",
      "sourceChain": "0x8fe2c4516e920425e177658aaac451ca26e1df30349b1d14b2638cc18bc888ac",
      "targetChain": "0x3a267813bea8120f55a7b9ca814c34dd89f237502d1872d7704c5a7d1824f48c",
      "proposalId": "0x1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e",
      "hsmIdentifier": "0x2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f",
      "hsmSignature": "0x3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a",
      "actionDigest": "0x4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b",
      "messageId": "0x5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c"
    }
  ]
}
```

---
