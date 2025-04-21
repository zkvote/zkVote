# zkVote: Smart Contract Interface Specifications

**Document ID:** ZKV-INTF-2025-001  
**Version:** 1.0

## Table of Contents

1. [Introduction](#1-introduction)
2. [Core Voting Protocol Interfaces](#2-core-voting-protocol-interfaces)
3. [Zero-Knowledge Verification Interfaces](#3-zero-knowledge-verification-interfaces)
4. [Delegation Protocol Interfaces](#4-delegation-protocol-interfaces)
5. [Cross-Chain Bridge Interfaces](#5-cross-chain-bridge-interfaces)
6. [Identity and Eligibility Interfaces](#6-identity-and-eligibility-interfaces)
7. [Result Aggregation Interfaces](#7-result-aggregation-interfaces)
8. [Governance Integration Interfaces](#8-governance-integration-interfaces)
9. [Events and Error Specifications](#9-events-and-error-specifications)
10. [Security Considerations](#10-security-considerations)
11. [Implementation Guidelines](#11-implementation-guidelines)
12. [Appendices](#12-appendices)

## 1. Introduction

### 1.1 Purpose

This document specifies the smart contract interfaces for the zkVote protocol. These interfaces define the programmatic boundaries between the protocol's components and establish the standard methods for interacting with the system. The specifications are designed to ensure interoperability, extensibility, and security across different implementations and deployment environments.

### 1.2 Scope

This specification covers the following contract interfaces:

- Core voting protocol contracts
- Zero-knowledge proof verification contracts
- Delegation protocol contracts
- Cross-chain bridge contracts
- Identity and eligibility verification contracts
- Result aggregation contracts
- Governance integration contracts

The document focuses on interface specifications rather than implementation details, establishing a standard that various implementations must adhere to.

### 1.3 Intended Audience

- Protocol Developers
- Integration Partners
- Auditors
- DAO Developers
- Blockchain Engineers

### 1.4 Terminology

| Term              | Definition                                                                                           |
| ----------------- | ---------------------------------------------------------------------------------------------------- |
| **Interface**     | A set of function signatures that define the contract's public API                                   |
| **ABI**           | Application Binary Interface - the standard way to interact with contracts in the Ethereum ecosystem |
| **View Function** | A function that reads but does not modify the contract state                                         |
| **Call Function** | A function that may modify the contract state                                                        |
| **Event**         | Logged information that can be subscribed to and filtered                                            |
| **Modifier**      | Function modifier that changes the behavior of a function                                            |

## 2. Core Voting Protocol Interfaces

### 2.1 IVoteFactory Interface

Interface for creating and managing voting instances.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

### 2.2 IVoteProcessor Interface

Interface for processing vote submissions and validation.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Data structure for a single vote
    struct VoteData {
        bytes32 voteCommitment;
        bytes32 weightCommitment;
        bytes32 nullifier;
        bytes zkProof;
    }
}
```

### 2.3 IVoteResultManager Interface

Interface for managing and querying voting results.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Result status enum
    enum ResultStatus {
        NotFinalized,
        Finalized,
        Decrypting,
        Decrypted
    }
}
```

## 3. Zero-Knowledge Verification Interfaces

### 3.1 IZKVerifier Interface

Interface for verifying zero-knowledge proofs in the voting protocol.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Proof types used in the protocol
    enum ProofType {
        VoteValidity,        // Proves vote is valid
        VoterEligibility,    // Proves voter is eligible
        DelegationValidity,  // Proves delegation is valid
        ResultCorrectness,   // Proves results are correctly computed
        DecryptionValidity   // Proves decryption share is valid
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

Interface for managing the circuit registry and verification keys.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
        bytes32 circuitId,
        bytes calldata newVerificationKey
    ) external returns (bool success);

    /// @notice Information about a circuit
    struct CircuitInfo {
        bytes32 circuitId;
        string description;
        bytes verificationKey;
        address registrar;
        uint256 registrationTime;
        uint256 lastUpdated;
        bool active;
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
}
```

### 3.3 IProofProcessor Interface

Interface for specialized proof processing operations.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
}
```

## 4. Delegation Protocol Interfaces

### 4.1 IDelegationRegistry Interface

Interface for the delegation registry that manages delegation relationships.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Public information about a delegation
    struct DelegationInfo {
        bytes32 delegationPointer;
        bytes32 stealthAddressHint;
        bytes constraints;
        uint256 registrationTime;
        uint256 expirationTime; // 0 if no expiration
        DelegationStatus status;
    }

    /// @notice Status of a delegation
    enum DelegationStatus {
        Active,
        Revoked,
        Expired,
        Claimed
    }
}
```

### 4.2 IDelegationVoter Interface

Interface for voting with delegated authority.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Emitted when a vote is cast using delegation
    event DelegatedVoteCast(
        bytes32 indexed voteId,
        uint256 delegationCount,
        bytes32 voteCommitment,
        uint256 timestamp
    );
}
```

### 4.3 IDelegationDiscovery Interface

Interface for delegates to discover delegations assigned to them.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Check if an address has registered as a delegate
    /// @param delegateAddress Address to check
    /// @return isRegistered Whether the address is registered as a delegate
    function isDelegateRegistered(address delegateAddress) external view returns (bool isRegistered);

    /// @notice Get all registered delegates
    /// @return delegates Array of delegate information
    function getAllDelegates() external view returns (DelegateInfo[] memory delegates);

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
}
```

## 5. Cross-Chain Bridge Interfaces

### 5.1 ICrossChainBridge Interface

Interface for the core cross-chain bridge functionality.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

Interface for relaying votes across blockchain networks.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Information about a vote from another chain
    struct ForeignVote {
        bytes32 sourceChainId;
        bytes32 voteCommitment;
        bytes32 nullifier;
        uint256 timestamp;
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
}
```

### 5.3 ICrossChainResultSync Interface

Interface for synchronizing vote results across chains.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Emitted when results are published to other chains
    event ResultsPublished(
        bytes32 indexed proposalId,
        uint256 targetChainCount,
        bytes32 resultHash,
        uint256 timestamp
    );

    /// @notice Emitted when results from another chain are registered
    event ForeignResultsRegistered(
        bytes32 indexed proposalId,
        bytes32 indexed sourceChainId,
        bytes32 resultHash,
        uint256 timestamp
    );
}
```

## 6. Identity and Eligibility Interfaces

### 6.1 IIdentityRegistry Interface

Interface for the identity registry managing zero-knowledge identities.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Information about an identity
    struct IdentityInfo {
        bytes32 identityCommitment;
        bytes metadata;
        uint256 registrationTime;
        uint256 lastUpdated;
        bool active;
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
}
```

### 6.2 IEligibilityVerifier Interface

Interface for verifying voting eligibility.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Check if eligibility credentials are registered for a vote
    /// @param voteId Identifier of the vote
    /// @return registered Whether eligibility credentials are registered
    /// @return credentialRoot The Merkle root of eligible credentials (if registered)
    function hasEligibilityCredentials(bytes32 voteId) external view returns (bool registered, bytes32 credentialRoot);

    /// @notice Get the eligibility policy for a vote
    /// @param voteId Identifier of the vote
    /// @return policy The eligibility policy
    function getEligibilityPolicy(bytes32 voteId) external view returns (bytes memory policy);

    /// @notice Emitted when eligibility credentials are registered
    event EligibilityCredentialsRegistered(
        bytes32 indexed voteId,
        bytes32 credentialRoot,
        uint256 timestamp
    );
}
```

### 6.3 ICrossChainIdentityBridge Interface

Interface for bridging identities across blockchain networks.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
}
```

## 7. Result Aggregation Interfaces

### 7.1 IVoteAggregator Interface

Interface for aggregating votes across multiple voting instances.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Parameters for vote aggregation
    struct AggregationParameters {
        uint256[] quorumRequirements;
        uint256[] chainWeights;
        uint32 threshold;
        uint64 deadline;
    }

    /// @notice Status of an aggregation process
    enum AggregationStatus {
        NotInitialized,
        Collecting,
        Complete,
        Finalized,
        Failed
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
}
```

### 7.2 ICrossChainTally Interface

Interface for tallying votes across multiple chains.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Parameters for cross-chain tally
    struct TallyParameters {
        uint64 startTime;
        uint64 endTime;
        uint32 quorumPercentage;
        uint32 threshold;
        uint8 tallyType;  // 0: simple majority, 1: supermajority, 2: custom
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
}
```

### 7.3 INormalizedWeightCalculator Interface

Interface for calculating and normalizing voting weights across chains.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Emitted when chain weights are updated
    event ChainWeightsUpdated(
        address updater,
        uint256 chainCount,
        uint256 timestamp
    );
}
```

## 8. Governance Integration Interfaces

### 8.1 IGovernanceIntegration Interface

Interface for integrating with existing governance frameworks.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Emitted when a proposal is executed
    event ProposalExecuted(
        bytes32 indexed proposalId,
        bool success,
        uint256 timestamp
    );
}
```

### 8.2 IGovernanceAction Interface

Interface for implementing governance actions that can be executed as a result of voting.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
        address executor
```

```solidity
        bytes32 indexed proposalId,
        address executor,
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

Interface for executing governance decisions across multiple blockchains.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
}
```

## 9. Events and Error Specifications

### 9.1 Standardized Events

This section defines standardized events that should be emitted by compliant implementations.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    /// @notice Emitted when a vote is finalized
    event VoteFinalized(
        bytes32 indexed voteId,
        bytes32 resultHash,
        bool passed,
        uint256 timestamp
    );

    /// @notice Emitted when a delegation is registered
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

    /// @notice Emitted when a bridge message is sent
    event BridgeMessageSent(
        bytes32 indexed messageId,
        bytes32 indexed sourceChain,
        bytes32 indexed targetChain,
        uint8 messageType,
        uint256 timestamp
    );

    /// @notice Emitted when a bridge message is received
    event BridgeMessageReceived(
        bytes32 indexed messageId,
        bytes32 indexed sourceChain,
        uint8 messageType,
        uint256 timestamp
    );

    /// @notice Emitted when an identity is registered
    event IdentityRegistered(
        bytes32 indexed identityCommitment,
        uint256 timestamp
    );

    /// @notice Emitted when a cross-chain proposal is executed
    event CrossChainProposalExecuted(
        bytes32 indexed proposalId,
        bytes32 indexed chainId,
        uint256 timestamp
    );
}
```

### 9.2 Error Codes

This section defines standardized error codes for the protocol.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

library ZKVoteErrors {
    // Authentication errors (1000-1999)
    error Unauthorized();                  // 1000: Caller is not authorized
    error InvalidSignature();              // 1001: Signature verification failed
    error InvalidProof();                  // 1002: Zero-knowledge proof is invalid

    // Vote operation errors (2000-2999)
    error VoteNotFound();                  // 2000: Vote ID not found
    error VoteAlreadyExists();             // 2001: Vote ID already exists
    error VotingNotActive();               // 2002: Voting period not active
    error VoteAlreadyCast();               // 2003: Nullifier already used
    error InvalidVoteOption();             // 2004: Invalid vote option
    error VoteNotFinalized();              // 2005: Vote is not finalized yet
    error InvalidVotingParams();           // 2006: Invalid voting parameters

    // Delegation errors (3000-3999)
    error DelegationNotFound();            // 3000: Delegation not found
    error DelegationAlreadyExists();       // 3001: Delegation already exists
    error DelegationRevoked();             // 3002: Delegation has been revoked
    error InvalidDelegation();             // 3003: Invalid delegation
    error DelegationExpired();             // 3004: Delegation has expired

    // Bridge errors (4000-4999)
    error InvalidChainId();                // 4000: Invalid chain ID
    error MessageAlreadyProcessed();       // 4001: Message already processed
    error InvalidMessageFormat();          // 4002: Invalid message format
    error InsufficientValidators();        // 4003: Not enough validator signatures
    error BridgeMessageFailed();           // 4004: Bridge message execution failed

    // Identity errors (5000-5999)
    error IdentityAlreadyRegistered();     // 5000: Identity already registered
    error IdentityNotFound();              // 5001: Identity not found
    error InvalidIdentityProof();          // 5002: Invalid identity proof
    error InvalidCredentials();            // 5003: Invalid credentials

    // Aggregation errors (6000-6999)
    error AggregationNotInitialized();     // 6000: Aggregation not initialized
    error AggregationAlreadyComplete();    // 6001: Aggregation already complete
    error ChainResultAlreadyRegistered();  // 6002: Chain result already registered
    error InvalidChainResult();            // 6003: Invalid chain result
    error AggregationDeadlinePassed();     // 6004: Aggregation deadline passed

    // Governance errors (7000-7999)
    error ProposalNotFound();              // 7000: Proposal not found
    error ProposalAlreadyExists();         // 7001: Proposal already exists
    error ProposalExecutionFailed();       // 7002: Proposal execution failed
    error InvalidProposalState();          // 7003: Invalid proposal state
    error InvalidAction();                 // 7004: Invalid governance action

    // General errors (8000-8999)
    error InvalidParameter();              // 8000: Invalid parameter
    error OperationFailed();               // 8001: Operation failed
    error Overflow();                      // 8002: Arithmetic overflow
    error InsufficientFunds();             // 8003: Insufficient funds
    error ContractPaused();                // 8004: Contract is paused
    error DeadlinePassed();                // 8005: Deadline has passed
    error NotImplemented();                // 8006: Function not implemented
}
```

## 10. Security Considerations

### 10.1 Access Control

Implementations of these interfaces must enforce appropriate access controls:

1. **Role-Based Access**: Use role-based access control (RBAC) for administrative functions
2. **Time-Locked Administration**: Implement time delays for sensitive operations
3. **Multi-Signature Requirements**: Require multiple signatures for critical functions
4. **Graduated Access**: Implement different access levels based on operation sensitivity

### 10.2 Cryptographic Verification

Zero-knowledge proof verification requires specific security considerations:

1. **Verification Key Security**: Protect the integrity of verification keys
2. **Parameter Validation**: Validate all inputs to cryptographic functions
3. **Trusted Setup**: Document and secure any trusted setup requirements
4. **Circuit Upgradability**: Implement secure upgrade mechanisms for circuits
5. **Side-Channel Protection**: Guard against side-channel attacks on verification

### 10.3 Cross-Chain Security

Cross-chain operations introduce additional security requirements:

1. **Message Replay Protection**: Prevent replay attacks across chains
2. **Validator Security**: Secure validator key management and rotation
3. **Consensus Thresholds**: Set appropriate thresholds for cross-chain consensus
4. **Chain Reorganization Handling**: Account for potential chain reorganizations
5. **Cross-Chain Atomicity**: Ensure atomic execution or rollback of multi-chain operations

### 10.4 Privacy Guarantees

Privacy preservation requires specific security measures:

1. **Nullifier Management**: Properly implement and verify nullifiers
2. **Vote Privacy**: Ensure votes remain confidential even with compromised components
3. **Delegation Privacy**: Protect the privacy of delegation relationships
4. **Identity Protection**: Safeguard identity information across operations
5. **Metadata Analysis Resistance**: Prevent deanonymization through metadata analysis

## 11. Implementation Guidelines

### 11.1 Gas Optimization

Implementations should optimize gas usage:

1. **Storage Layout**: Optimize storage slot usage
2. **Batch Operations**: Support batched transactions where appropriate
3. **Circuit Efficiency**: Minimize constraints in zero-knowledge circuits
4. **Calldata Optimization**: Minimize calldata size for external functions
5. **Event Emission**: Balance event data with gas costs

### 11.2 Integration Patterns

Recommended patterns for integrating with external systems:

1. **Adapter Pattern**: Use adapters for connecting to different governance frameworks
2. **Proxy Pattern**: Implement upgradable contracts with proxy patterns
3. **Bridge Pattern**: Use standardized bridge interfaces for cross-chain operations
4. **Observer Pattern**: Implement event-based communication where appropriate
5. **Factory Pattern**: Use factories for creating vote instances

### 11.3 Testing Recommendations

Comprehensive testing approaches:

1. **Unit Testing**: Test individual contract functions
2. **Integration Testing**: Test interactions between contracts
3. **Formal Verification**: Verify critical properties using formal methods
4. **Fuzzing**: Conduct fuzz testing with randomized inputs
5. **Scenario Testing**: Test complete end-to-end voting scenarios
6. **Security Auditing**: Conduct professional security audits

### 11.4 Deployment Best Practices

Best practices for contract deployment:

1. **Incremental Deployment**: Deploy contracts in stages with increasing complexity
2. **Testnet Validation**: Thoroughly test on testnets before mainnet deployment
3. **Contract Verification**: Verify contract code on block explorers
4. **Documentation**: Provide comprehensive documentation of deployed contracts
5. **Monitoring**: Implement monitoring for contract events and errors

## 12. Appendices

### 12.1 Type Definitions

Common types and structures used across interfaces:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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
        uint8 status;            // 0: active, 1: revoked, 2: expired, 3: claimed
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
    }

    // Identity types
    struct IdentityInfo {
        bytes32 identityCommitment;
        bytes metadata;
        uint256 registrationTime;
        uint256 lastUpdated;
        bool active;
    }

    // Cross-chain types
    struct ChainInfo {
        bytes32 chainId;
        string name;
        uint256 weight;
        bool active;
    }
}
```

### 12.2 Interface Version History

Record of interface versions and changes:

| Interface              | Version | Date       | Key Changes     |
| ---------------------- | ------- | ---------- | --------------- |
| IVoteFactory           | 1.0     | 2025-04-19 | Initial release |
| IVoteProcessor         | 1.0     | 2025-04-19 | Initial release |
| IZKVerifier            | 1.0     | 2025-04-19 | Initial release |
| IDelegationRegistry    | 1.0     | 2025-04-19 | Initial release |
| ICrossChainBridge      | 1.0     | 2025-04-19 | Initial release |
| IIdentityRegistry      | 1.0     | 2025-04-19 | Initial release |
| IVoteAggregator        | 1.0     | 2025-04-19 | Initial release |
| IGovernanceIntegration | 1.0     | 2025-04-19 | Initial release |

### 12.3 Related Standards

Standards and EIPs that these interfaces relate to:

1. **ERC-165**: Standard Interface Detection
2. **ERC-20**: Token Standard (for token-weighted voting)
3. **ERC-712**: Typed structured data hashing and signing
4. **ERC-1155**: Multi Token Standard (for multiple vote types)
5. **EIP-2535**: Diamond Standard (for modular contract architecture)
6. **EIP-1967**: Proxy Storage Slots (for upgradable contracts)

---
