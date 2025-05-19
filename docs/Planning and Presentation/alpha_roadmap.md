# zkVote: Incremental Testnet Alpha Roadmap

This document outlines the phased rollout of zkVote, with each Testnet Alpha version building upon the last, culminating in a feature-rich, privacy-preserving, cross-chain governance protocol.

## Core Assumptions:

- Each sprint is 2 weeks.
- Backend: Rust
- Scripts/SDK/UI: TypeScript

---

## Testnet Alpha v0.1: Core Private Voting on a Single EVM Chain

**Sprint Goal:** Demonstrate a basic, end-to-end private voting flow on a single EVM-compatible testnet. Voters can cast a vote privately, and the system can verify these votes without revealing individual choices.  
**Release Window:** Weeks 1-2

**Key Features Introduced/Demoed:**

- Admin can create a new voting instance with basic parameters (e.g., proposal description, voting period).
- Admin can define a set of eligible voters (e.g., by setting a Merkle root of voter public keys/commitments).
- Eligible voters can generate a ZK-SNARK proof locally, proving their eligibility and their vote choice without revealing either.
- Voters can submit their encrypted vote choice and the ZK proof to a smart contract.
- The smart contract verifies the ZK proof, records the vote commitment, and uses a nullifier to prevent double-voting.
- A simple, off-chain script can tally the votes (privacy of results during tallying is a more advanced feature).

**Focus Areas from Technical Deep-Dive Documents:**

- `zk-SNARK*circuitDesignSpecs.md`: Core vote casting and eligibility circuits.
- `smartContractInterfaceSpecs.md`: IVoteFactory, IVoteProcessor, basic IZKVerifier.
- `requirements.md`: Core functional requirements for voting (FR-1.1, FR-1.2, FR-1.3, FR-1.7).
- `architecture.md`: Basic Core Protocol Layer and Application Layer (minimal UI/SDK).

**Project Directory Structure (`zkVote_Alpha_v0.1/`):**

```plaintext
zkVote_Alpha_v0.1/
├── .gitignore
├── Cargo.toml # Rust project manifest (for potential backend tools/prover logic)
├── LICENSE
├── package.json # Node.js/TypeScript project manifest
├── README.md # Alpha v0.1 setup and usage
├── circuits/
│   └── vote_casting.circom # ZK-SNARK circuit for voting & basic eligibility
├── contracts/
│   ├── core/
│   │   ├── IVoteFactory.sol
│   │   ├── VoteFactory.sol # Creates voting instances
│   │   ├── IVoteProcessor.sol
│   │   └── VoteProcessor.sol # Handles vote submission & ZK proof verification
│   ├── identity/
│   │   ├── IIdentityRegistry.sol
│   │   └── IdentityRegistry.sol # Manages Merkle root of eligible voters
│   └── zk_verification/
│       └── Groth16Verifier.sol # Verifier contract for vote_casting.circom
├── docs/
│   └── Technical Deep-Dive/ # Contains all provided deep-dive documents
├── scripts/
│   ├── compile_circuits.sh # Compiles vote_casting.circom (e.g., using circom & snarkjs)
│   ├── deploy_contracts.ts # Deploys contracts to testnet (e.g., using Hardhat)
│   └── trusted_setup_alpha.sh # Basic (INSECURE FOR ALPHA) trusted setup script
├── src/ # Rust backend (minimal for now, e.g., proof generation helpers if not client-side)
│   ├── core/
│   │   └── proof_utils.rs # ZK proof generation helpers (if Rust prover used)
│   └── main.rs # Placeholder or simple CLI
├── sdk/
│   └── typescript/
│       ├── package.json
│       ├── src/
│       │   ├── index.ts
│       │   └── zkvote_client.ts # Basic client to interact with contracts
│       └── tsconfig.json
├── tests/
│   ├── contracts/
│   │   ├── VoteFactory.test.ts
│   │   └── VoteProcessor.test.ts
│   └── unit/
│       └── circuits/
│           └── vote_casting.test.js # Test for the circom circuit
└── ui/ # Minimal User Interface (e.g., React/Next.js)
    └── voter_app/
        ├── package.json
        ├── public/
        │   └── index.html
        └── src/
            ├── App.tsx
            ├── components/
            │   └── VoteForm.tsx
            └── services/
                └── zkvote.service.ts # Interacts with the SDK
```

**Key File Descriptions/Changes for Alpha v0.1:**

- `circuits/vote_casting.circom`: Core logic for proving vote validity and eligibility (e.g., Merkle proof of inclusion in an allowlist, valid vote option).
- `contracts/core/VoteFactory.sol`: Allows an admin to create a new vote, setting parameters like the Merkle root of eligible voters and voting duration.
- `contracts/core/VoteProcessor.sol`: Accepts vote submissions, verifies the Groth16Verifier.sol for the ZK proof, checks and records nullifiers, and stores vote commitments.
- `contracts/identity/IdentityRegistry.sol`: Stores the Merkle root of eligible voters for a given vote.
- `scripts/compile_circuits.sh`: Script to compile the Circom circuit to R1CS, WASM prover, and generate verification_key.json.
- `scripts/trusted_setup_alpha.sh`: A highly simplified and insecure script for generating Phase 1 and Phase 2 ptau files and the zkey for Groth16 setup for alpha testing. This is NOT for production.
- `sdk/typescript/src/zkvote_client.ts`: Functions to create votes (admin), cast votes (voter - including client-side proof generation using snarkjs), and potentially query basic vote info.
- `ui/voter_app/`: A very basic web interface for a voter to connect their wallet, select a vote option, generate a proof, and submit their vote.

---

## Testnet Alpha v0.2: Basic Private Delegation

**Sprint Goal:** Introduce the ability for users to privately delegate their voting power to another user (delegate). Delegates can then vote using their own and accumulated delegated power, all while maintaining privacy.  
**Release Window:** Weeks 3-4

**Key Features Introduced/Demoed (on top of v0.1):**

- Delegators can create a private delegation to a chosen delegate.
- Delegates can discover delegations made to them (e.g., via off-chain communication or scanning for specific on-chain hints).
- Delegates can cast votes using their combined (original + delegated) voting power.
- ZK-SNARK proofs ensure the validity of delegations and the correct use of delegated voting power without revealing the delegator-delegate relationship or the amount of power delegated.

**Focus Areas from Technical Deep-Dive Documents:**

- `delegationPrivacyDeepDive.md`: Core concepts of private delegation, stealth addresses, ZK proofs for delegation.
- `zk-SNARK_circuitDesignSpecs.md`: New circuits for delegation authorization and voting with delegated power.
- `smartContractInterfaceSpecs.md`: IDelegationRegistry, IDelegationVoter.
- `requirements.md`: Delegation requirements (FR-2.1, FR-2.2, FR-2.4).

**Project Directory Structure (`zkVote_Alpha_v0.2/`):**

```plaintext
zkVote_Alpha_v0.2/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.2
├── circuits/
│   ├── delegation_authorization.circom # New: ZK circuit for creating a delegation
│   ├── vote_casting.circom
│   └── vote_with_delegation.circom # New: ZK circuit for voting with delegated power
├── contracts/
│   ├── core/
│   │   ├── IVoteFactory.sol
│   │   ├── VoteFactory.sol
│   │   ├── IVoteProcessor.sol
│   │   └── VoteProcessor.sol # Modified: To handle delegated votes
│   ├── delegation/ # New Folder
│   │   ├── IDelegationRegistry.sol
│   │   ├── DelegationRegistry.sol # New: Manages delegation commitments & nullifiers
│   │   ├── IDelegationVoter.sol
│   │   └── DelegationVoter.sol # New: Handles voting with delegated power (could be part of VoteProcessor)
│   ├── identity/
│   │   ├── IIdentityRegistry.sol
│   │   └── IdentityRegistry.sol
│   └── zk_verification/
│       ├── Groth16Verifier_DelegationAuth.sol # New: Verifier for delegation_authorization.circom
│       ├── Groth16Verifier_VoteCast.sol # Renamed/Specific
│       └── Groth16Verifier_VoteWithDeleg.sol # New: Verifier for vote_with_delegation.circom
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   ├── compile_circuits.sh # Modified: To compile new circuits
│   ├── deploy_contracts.ts # Modified: To deploy new delegation contracts
│   └── trusted_setup_alpha.sh # Modified: For new circuits
├── src/
│   ├── core/
│   │   └── proof_utils.rs # Potentially updated for new proof types
│   └── main.rs
├── sdk/
│   └── typescript/
│       ├── package.json
│       ├── src/
│       │   ├── index.ts
│       │   └── zkvote_client.ts # Modified: Add functions for delegation
│       └── tsconfig.json
├── tests/
│   ├── contracts/
│   │   ├── VoteFactory.test.ts
│   │   ├── VoteProcessor.test.ts
│   │   └── delegation/ # New Folder
│   │       └── DelegationRegistry.test.ts
│   └── unit/
│       └── circuits/
│           ├── delegation_authorization.test.js # New
│           ├── vote_casting.test.js
│           └── vote_with_delegation.test.js # New
└── ui/
    └── voter_app/ # Modified: UI for creating and accepting delegations, voting with delegated power
        ├── package.json
        ├── public/
        │   └── index.html
        └── src/
            ├── App.tsx
            ├── components/
            │   ├── DelegateForm.tsx # New
            │   └── VoteForm.tsx # Modified
            └── services/
                └── zkvote.service.ts # Modified
```

**Key File Descriptions/Changes for Alpha v0.2:**

- `circuits/delegation_authorization.circom`: Proves a delegator has the right to delegate a certain amount of voting power and creates a commitment to the delegation (e.g., to a delegate's stealth address) without revealing the delegate or amount.
- `circuits/vote_with_delegation.circom`: Allows a delegate to prove they control certain delegations and can use their aggregated power to vote, without linking back to specific delegators.
- `contracts/delegation/DelegationRegistry.sol`: Stores commitments to valid delegations and nullifiers to prevent re-delegation of the same power.
- `contracts/core/VoteProcessor.sol (or DelegationVoter.sol)`: Extended to accept proofs from vote_with_delegation.circom.
- `Groth16Verifier*.sol`: Separate verifier contracts generated for each new circuit.
- SDK & UI: Updated to include flows for:
  - Delegator: Creating a delegation (specifying delegate, amount - all handled client-side to generate proof).
  - Delegate: Discovering delegations (simplified for alpha, e.g., manual input of delegation data or basic scanning of hints).
  - Delegate: Voting with combined power.

---

## Testnet Alpha v0.3: Basic Cross-Chain Bridge Infrastructure

**Sprint Goal:** Establish foundational cross-chain communication by deploying and testing a simple bridge mechanism between two EVM testnets. This alpha focuses on the bridge infrastructure itself, not yet integrating zkVote logic across chains.  
**Release Window:** Weeks 5-6

**Key Features Introduced/Demoed:**

- Deployment of a basic bridge contract (e.g., a simple multi-signature bridge or a mock light client bridge) on two separate testnets (e.g., Sepolia and Goerli, or two local Hardhat nodes configured for different chain IDs).
- A relayer service (can be a manual script for alpha) that observes events on Chain A and submits corresponding transactions to the bridge contract on Chain B.
- Ability to send a generic, simple message (e.g., a string or a number) from a contract on Chain A, have it relayed, and be received/processed by a contract on Chain B.
- Demonstrate message passing and basic state synchronization (e.g., Chain B contract stores the message received from Chain A).

**Focus Areas from Technical Deep-Dive Documents:**

- `cross-chain_and_aggregation.md`: Introduces concepts of bridge protocols (Light Client, Multi-Sig). This alpha implements a very simplified version.
- `smartContractInterfaceSpecs.md`: Basic ICrossChainBridge.
- `architecture.md`: Touches upon the Integration Layer.

**Project Directory Structure (`zkVote_Alpha_v0.3/`):**

```plaintext
zkVote_Alpha_v0.3/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.3
├── circuits/
│   ├── delegation_authorization.circom
│   ├── vote_casting.circom
│   └── vote_with_delegation.circom
├── contracts/
│   ├── core/
│   │   # ... (as in v0.2)
│   ├── cross_chain/ # New Folder
│   │   ├── ICrossChainBridge.sol
│   │   ├── CrossChainBridge_SimpleMultisig.sol # Example basic bridge
│   │   └── ReceiverAppExample.sol # Simple contract on Chain B to receive messages
│   │   └── SenderAppExample.sol # Simple contract on Chain A to send messages
│   ├── delegation/
│   │   # ... (as in v0.2)
│   ├── identity/
│   │   # ... (as in v0.2)
│   └── zk_verification/
│       # ... (as in v0.2)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   ├── compile_circuits.sh
│   ├── deploy_contracts.ts # Modified: To deploy example sender/receiver apps
│   ├── deploy_bridge.ts # New: Script to deploy bridge contracts on two chains
│   ├── relayer_alpha.ts # New: Simple relayer script for the bridge
│   └── trusted_setup_alpha.sh
├── src/ # Rust backend might house the relayer logic if more complex
│   ├── relayer_service/ # New (Optional, if relayer is in Rust)
│   │   └── main.rs
│   ├── core/
│   │   └── proof_utils.rs
│   └── main.rs
├── sdk/
│   └── typescript/
│       ├── package.json
│       ├── src/
│       │   ├── index.ts
│       │   └── zkvote_client.ts # Modified: Add functions to send test cross-chain messages
│       └── tsconfig.json
├── tests/
│   ├── contracts/
│   │   # ... (as in v0.2)
│   │   └── cross_chain/ # New Folder
│   │       └── CrossChainBridge_SimpleMultisig.test.ts
│   └── unit/
│       # ... (as in v0.2)
└── ui/
    ├── bridge_monitor_app/ # New: Minimal UI to send a test message & see relayed messages
    │   ├── package.json
    │   └── src/ App.tsx
    └── voter_app/ # ... (as in v0.2)
```

**Key File Descriptions/Changes for Alpha v0.3:**

- `contracts/cross_chain/CrossChainBridge_SimpleMultisig.sol`: A basic bridge where a set of trusted signers (multisig) authorize messages to be passed from one chain to another. For alpha, this could even be a single owner bridge for simplicity.
- `contracts/cross_chain/SenderAppExample.sol`: A contract on Chain A that emits an event with a message payload intended for Chain B.
- `contracts/cross_chain/ReceiverAppExample.sol`: A contract on Chain B that has a function callable by the bridge (or relayer authorized by bridge) to process the message from Chain A.
- `scripts/deploy_bridge.ts`: Deploys the bridge contract and example apps to two configured testnets.
- `scripts/relayer_alpha.ts`: A script that listens to SenderAppExample events on Chain A, and upon seeing an event, calls the CrossChainBridge_SimpleMultisig.sol on Chain A, which then (after multisig approval or directly) allows the relayer to call the ReceiverAppExample.sol on Chain B via its bridge contract.
- `sdk/typescript/src/zkvote_client.ts`: Updated with a function to trigger a message send from SenderAppExample.sol.
- `ui/bridge_monitor_app/`: A very simple UI to initiate a test message and perhaps display messages that have been relayed.

---

## Testnet Alpha v0.4: Cross-Chain Vote Relay & Basic Aggregation

**Sprint Goal:** Enable voters to cast votes on a source chain (Chain A), have these votes (or their commitments) relayed to a destination/aggregation chain (Chain B), and perform a basic aggregation of votes from multiple source chains on Chain B.  
**Release Window:** Weeks 7-8

**Key Features Introduced/Demoed (on top of v0.3):**

- A zkVote instance can be configured to accept votes from multiple chains.
- Voters cast votes on their respective source chains using the existing private voting mechanism (from v0.1/v0.2).
- Vote commitments (and necessary metadata like nullifiers) are relayed from source chains to the aggregation chain via the bridge (from v0.3).
- A contract on the aggregation chain (CrossChainResultSync.sol) collects these relayed vote commitments.
- A mechanism (can be off-chain or a simple on-chain function for alpha) tallies votes from all participating chains.
- Basic cross-chain nullifier synchronization to prevent a voter from voting on Chain A and Chain C for the same proposal if both are part of the same cross-chain vote.

**Focus Areas from Technical Deep-Dive Documents:**

- `cross-chain_and_aggregation.md`: Core concepts of vote relaying, result synchronization, and weight normalization (simplified for alpha).
- `smartContractInterfaceSpecs.md`: ICrossChainVoteRelay, ICrossChainResultSync, IVoteAggregator (simplified).
- `architecture.md`: Cross-Chain Coordination aspects.

**Project Directory Structure (`zkVote_Alpha_v0.4/`):**

```plaintext
zkVote_Alpha_v0.4/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.4
├── circuits/
│   # ... (as in v0.2, potentially a new circuit for cross-chain proof if ZK bridge is used, else not needed for simple bridge)
├── contracts/
│   ├── core/
│   │   ├── VoteFactory.sol # Modified: To configure cross-chain participation
│   │   ├── VoteProcessor.sol # Modified: To interact with vote relay
│   │   # ...
│   ├── cross_chain/
│   │   ├── ICrossChainBridge.sol
│   │   ├── CrossChainBridge_SimpleMultisig.sol
│   │   ├── ICrossChainVoteRelay.sol # New
│   │   ├── CrossChainVoteRelay.sol # New: Contract on source chains to send votes to bridge
│   │   ├── ICrossChainResultSync.sol # New
│   │   ├── CrossChainResultSync.sol # New: Contract on destination chain to receive/store vote commitments
│   │   └── ReceiverAppExample.sol # (Can be removed or kept for generic bridge testing)
│   │   └── SenderAppExample.sol # (Can be removed or kept for generic bridge testing)
│   ├── delegation/
│   │   # ... (as in v0.2)
│   ├── identity/
│   │   # ... (as in v0.2)
│   └── zk_verification/
│       # ... (as in v0.2)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   ├── compile_circuits.sh
│   ├── deploy_contracts.ts # Modified: To deploy new cross-chain voting contracts
│   ├── deploy_bridge.ts
│   ├── relayer_alpha.ts # Modified: To relay zkVote specific messages
│   └── trusted_setup_alpha.sh
├── src/ # Rust backend
│   ├── aggregator_service/ # New (Optional): Off-chain service for tallying cross-chain votes
│   │   └── main.rs
│   ├── relayer_service/
│   │   └── main.rs
│   ├── core/
│   │   └── proof_utils.rs
│   └── main.rs
├── sdk/
│   └── typescript/
│       ├── package.json
│       ├── src/
│       │   ├── index.ts
│       │   └── zkvote_client.ts # Modified: To support cross-chain vote creation and casting
│       └── tsconfig.json
├── tests/
│   ├── contracts/
│   │   # ... (as in v0.3)
│   │   └── cross_chain/
│   │       ├── CrossChainVoteRelay.test.ts # New
│   │       └── CrossChainResultSync.test.ts # New
│   └── unit/
│       # ... (as in v0.2)
└── ui/
    ├── bridge_monitor_app/
    └── voter_app/ # Modified: UI to select source chain for voting if applicable, display cross-chain results # ... (as in v0.3)
```

**Key File Descriptions/Changes for Alpha v0.4:**

- `contracts/core/VoteFactory.sol`: Modified to allow specifying which chains can participate in a vote and the address of the CrossChainResultSync contract on the aggregation chain.
- `contracts/core/VoteProcessor.sol`: On source chains, after local vote processing, it calls CrossChainVoteRelay.sol to send the vote commitment.
- `contracts/cross_chain/CrossChainVoteRelay.sol`: Deployed on source chains. It receives processed vote data (commitment, nullifier) from the local VoteProcessor and sends it to the bridge to be relayed to the aggregation chain.
- `contracts/cross_chain/CrossChainResultSync.sol`: Deployed on the aggregation chain. It receives vote commitments from the bridge (via its executeIncomingMessage function) and stores them. It will also manage a global or synchronized nullifier list for cross-chain votes.
- `scripts/relayer_alpha.ts`: Enhanced to listen for events from CrossChainVoteRelay on source chains and trigger message relaying to CrossChainResultSync on the aggregation chain.
- `src/aggregator_service/` (Optional): A simple off-chain service that queries CrossChainResultSync and performs the tally. For alpha, tallying can also be a manual script or a very basic on-chain view function in CrossChainResultSync.
- SDK & UI: Updated to allow admins to create cross-chain votes. Voters vote as usual on their source chain; the cross-chain aspect is mostly backend. UI might show results aggregated from multiple chains.

---

## Testnet Alpha v0.5: Basic Confidential Computing for Tallying (Conceptual/Mocked TEE)

**Sprint Goal:** Introduce the concept of using a Trusted Execution Environment (TEE) for vote tallying to enhance result privacy. For an alpha, this will likely involve a mocked TEE interaction or a very basic, non-production SGX enclave if development resources allow. The focus is on the architectural integration points.  
**Release Window:** Weeks 9-10

**Key Features Introduced/Demoed (on top of v0.4):**

- Encrypted vote commitments are sent to a (mocked) TEE for decryption and tallying.
- The (mocked) TEE produces a signed tally result and potentially a proof of correct execution within the enclave.
- The system architecture is updated to include a TEE interaction point for the tallying phase.
- Remote attestation (mocked) to verify the TEE's integrity before sending it encrypted data.

**Focus Areas from Technical Deep-Dive Documents:**

- `Confidential Computing & TEE Integration for zkVot.md`: Core concepts of TEE-enabled vote processing, SGX/TrustZone, attestation.
- `architecture.md`: Integration of a Confidential Computing Layer.
- `smartContractInterfaceSpecs.md`: Potentially new interfaces for submitting encrypted data to TEE and receiving results.

**Project Directory Structure (`zkVote_Alpha_v0.5/`):**

```plaintext
zkVote_Alpha_v0.5/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.5
├── circuits/
│   # ... (as in v0.4)
├── contracts/
│   ├── core/
│   │   ├── VoteResultManager.sol # May be enhanced or a new contract for TEE interaction
│   │   # ...
│   ├── cross_chain/
│   │   # ... (as in v0.4)
│   ├── delegation/
│   │   # ... (as in v0.2)
│   ├── identity/
│   │   # ... (as in v0.2)
│   └── zk_verification/
│       # ... (as in v0.2)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   # ... (as in v0.4)
├── security/ # New Folder
│   └── confidential_computing/
│       ├── sgx_enclave_mock/ # Mocked SGX enclave
│       │   ├── enclave.c # Basic C code for mock tallying
│       │   └── enclave.edl # Enclave Definition Language file (mocked)
│       └── attestation_service_mock/
│           └── attestation_logic.rs # Mocked attestation verification
├── src/ # Rust backend
│   ├── aggregator_service/ # Modified: To interact with the mocked TEE
│   │   ├── main.rs
│   │   └── tee_connector.rs # New: Logic to (mock) send data to TEE and get results
│   ├── relayer_service/
│   │   └── main.rs
│   ├── core/
│   │   └── proof_utils.rs
│   └── main.rs
├── sdk/
│   └── typescript/
│       # ... (as in v0.4, potentially minor updates for TEE-based tally query)
├── tests/
│   # ... (as in v0.4)
│   └── security/ # New Folder
│       └── confidential_computing/
│           └── test_tee_tallying_flow.ts # Test for the mocked TEE flow
└── ui/ # ... (as in v0.4, UI might show results sourced from the TEE-based tally)
```

**Key File Descriptions/Changes for Alpha v0.5:**

- `security/confidential_computing/sgx_enclave_mock/`: Contains a highly simplified, non-production C file (enclave.c) that simulates receiving encrypted votes, "decrypting" them (can be plaintext for mock), tallying, and "signing" the result. The .edl file would define the mock enclave's interface.
- `security/confidential_computing/attestation_service_mock/attestation_logic.rs`: A mock service that simulates verifying an SGX quote.
- `src/aggregator_service/tee_connector.rs`: Backend Rust code that simulates:
  - Requesting attestation from the (mocked) TEE.
  - Verifying the (mocked) attestation.
  - Encrypting vote data (can be simplified for mock) and sending it to the (mocked) TEE.
  - Receiving the "signed" tally from the (mocked) TEE and verifying its signature.
- `contracts/core/VoteResultManager.sol`: Might be updated to store results attested by the TEE, or a new contract could handle this.
- Testing: Focus on testing the interaction flow between the backend service and the mocked TEE components.

---

## Testnet Alpha v0.6: Basic Post-Quantum Signature Integration (Hybrid Model)

**Sprint Goal:** Introduce basic post-quantum (PQ) signature capabilities by implementing a hybrid signature scheme (e.g., ECDSA + Dilithium) for a critical, non-voting administrative function, such as creating a new voting instance. This demonstrates forward-thinking security without immediately impacting the core voting ZK circuits.  
**Release Window:** Weeks 11-12

**Key Features Introduced/Demoed (on top of v0.5):**

- Admin can create a new voting instance using a hybrid signature (ECDSA + a PQ signature like Dilithium).
- The VoteFactory contract (or a dedicated admin contract) is updated to verify this hybrid signature.
- Off-chain libraries/SDK are updated to support generating and handling these hybrid signatures.
- Focus is on the signature scheme itself, not yet on PQ ZKPs.

**Focus Areas from Technical Deep-Dive Documents:**

- `zkVote Post-Quantum Cryptography Implementation Gu.md`: Core concepts of hybrid signatures, selected PQ algorithms (e.g., Dilithium).
- `smartContractInterfaceSpecs.md`: Potentially new verifier contracts or libraries for PQ signatures.
- `architecture.md`: Touches upon the Post-Quantum Security layer.

**Project Directory Structure (`zkVote_Alpha_v0.6/`):**

```plaintext
zkVote_Alpha_v0.6/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.6
├── circuits/
│   # ... (as in v0.4 - no new circuits for this alpha)
├── contracts/
│   ├── core/
│   │   ├── VoteFactory.sol # Modified: To accept hybrid signatures for creation
│   │   # ... (other core contracts as in v0.4)
│   ├── cross_chain/
│   │   # ... (as in v0.4)
│   ├── delegation/
│   │   # ... (as in v0.2)
│   ├── identity/
│   │   # ... (as in v0.2)
│   ├── utils/ # New or enhanced
│   │   └── DilithiumVerifier.sol # New: Solidity verifier for Dilithium (or chosen PQ sig)
│   └── zk_verification/
│       # ... (as in v0.2)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   # ... (as in v0.4, deploy_contracts.ts might deploy new verifier)
├── security/
│   ├── confidential_computing/
│   │   # ... (as in v0.5)
│   └── post_quantum/ # New Folder
│       ├── pq_risk_assessment_alpha.md # Basic risk notes for alpha
│       └── pq_transition_plan_alpha.md # Basic transition notes for alpha
├── src/ # Rust backend
│   ├── aggregator_service/
│   │   # ... (as in v0.5)
│   ├── crypto/ # New or enhanced
│   │   └── post_quantum/ # New Folder
│   │       ├── dilithium_lib.rs # New: Rust library for Dilithium signing/verification
│   │       └── hybrid_signature.rs # New: Logic for creating/verifying hybrid sigs
│   ├── relayer_service/
│   │   # ... (as in v0.4)
│   ├── core/
│   │   # ... (as in v0.1)
│   └── main.rs
├── sdk/
│   └── typescript/
│       ├── package.json
│       ├── src/
│       │   ├── index.ts
│       │   └── zkvote_client.ts # Modified: To support hybrid sigs for admin actions
│       └── tsconfig.json
├── tests/
│   ├── contracts/
│   │   ├── core/
│   │   │   └── VoteFactory.test.ts # Modified: Test hybrid signature verification
│   │   # ... (other contract tests as in v0.4)
│   ├── security/
│   │   # ... (as in v0.5)
│   └── unit/
│       └── src/
│           └── crypto/
│               └── post_quantum/ # New Folder
│                   └── hybrid_signature.test.rs # New: Test hybrid signature logic
└── ui/
    ├── admin_app/ # New or enhanced UI for admin functions
    │   └── src/
    │       └── CreateVoteForm.tsx # Modified: To use hybrid signatures
    ├── bridge_monitor_app/
    │   # ... (as in v0.3)
    └── voter_app/ # ... (as in v0.4)
```

**Key File Descriptions/Changes for Alpha v0.6:**

- `contracts/utils/DilithiumVerifier.sol`: A Solidity contract (or library) capable of verifying Dilithium signatures (or the chosen PQ signature algorithm). This might be a simplified version or use precompiles if available on the testnet.
- `contracts/core/VoteFactory.sol`: The createVote function (or a similar admin function) would be modified to accept both an ECDSA signature and a PQ signature. It would then call the respective verifiers.
- `src/crypto/post_quantum/dilithium_lib.rs`: Rust library for generating and verifying Dilithium signatures. This could wrap existing C implementations or be a pure Rust one.
- `src/crypto/post_quantum/hybrid_signature.rs`: Logic to combine classical and PQ signatures and to verify them as a pair.
- SDK & UI: The admin part of the SDK and UI would be updated to generate and submit these hybrid signatures when an admin creates a new vote.

# Testnet Alpha v0.7: Basic Runtime Security Monitoring & Kubernetes Hardening

**Sprint Goal:** Introduce foundational runtime security monitoring by implementing a simple eBPF probe to monitor a specific, critical activity of the zkVote backend node (e.g., unexpected network connections, sensitive file access). Additionally, define and apply basic Kubernetes security configurations if zkVote components are containerized.  
**Release Window:** Weeks 13-14

**Key Features Introduced/Demoed (on top of v0.6):**

- A basic eBPF program deployed alongside the zkVote backend node (if running on Linux).
- This eBPF probe monitors a predefined set of system calls or network events and logs suspicious activity (e.g., to stdout or a simple log file for alpha).
- Basic Kubernetes Pod Security Policies (or their modern equivalent like Pod Security Admission) and Network Policies are defined for zkVote backend components if deployed on Kubernetes.
- Demonstrate the eBPF probe detecting a manually triggered "suspicious" event.
- Showcase the applied Kubernetes security configurations.

**Focus Areas from Technical Deep-Dive Documents:**

- Runtime Security Monitoring Framework for zkVote.md: eBPF-based threat detection, Kubernetes security hardening. This alpha implements a very minimal subset.
- architecture.md: Touches upon the Operational Security aspects within the Security Architecture.

**Project Directory Structure (`zkVote_Alpha_v0.7/`):**

```plaintext
zkVote_Alpha_v0.7/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.7
├── circuits/
│   # ... (as in v0.4)
├── contracts/
│   # ... (as in v0.6)
├── deployment/ # New or enhanced folder for K8s manifests
│   └── kubernetes/
│       ├── backend-deployment.yaml
│       ├── network-policy.yaml # New: Basic network policy
│       └── pod-security.yaml # New: Basic pod security configuration
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   # ... (as in v0.6)
│   └── deploy_monitoring_probe.sh # New: Script to load eBPF probe (if applicable)
├── security/
│   ├── confidential_computing/
│   │   # ... (as in v0.5)
│   ├── post_quantum/
│   │   # ... (as in v0.6)
│   └── runtime_monitoring/ # New Folder
│       ├── ebpf_probes/ # New Subfolder
│       │   └── basic_syscall_monitor.bpf.c # New: Simple eBPF C code
│       └── kubernetes_hardening/ # New Subfolder
│           └── hardening_notes_alpha.md # Notes on applied K8s policies
├── src/ # Rust backend
│   ├── runtime_security_agent/ # New (Optional): User-space agent for eBPF probe
│   │   └── main.rs # Collects data from eBPF, basic logging
│   # ... (other src folders as in v0.6)
├── sdk/
│   # ... (as in v0.6 - no SDK changes for this alpha)
├── tests/
│   # ... (as in v0.6 - potentially new tests for monitoring agent if complex)
└── ui/ # ... (as in v0.6 - no UI changes for this alpha)
```

**Key File Descriptions/Changes for Alpha v0.7:**

- `deployment/kubernetes/network-policy.yaml`: A basic Kubernetes NetworkPolicy manifest restricting ingress/egress for the zkVote backend pods.
- `deployment/kubernetes/pod-security.yaml`: A manifest defining basic Pod Security Standards (e.g., restricted profile or custom policies like disallowing privileged containers, specific volume types).
- `security/runtime_monitoring/ebpf_probes/basic_syscall_monitor.bpf.c`: A simple eBPF program written in C that hooks into a specific syscall (e.g., execve, connect) and logs its usage, potentially filtering for suspicious patterns.
- `scripts/deploy_monitoring_probe.sh`: A script to compile (if needed, e.g., using BCC or libbpf-bootstrap) and load the eBPF program into the kernel.
- `src/runtime_security_agent/` (Optional): If the eBPF probe sends data to user-space, this Rust application would receive it (e.g., via a perf buffer or ring buffer) and perform basic logging or alerting. For a very simple alpha, the eBPF probe might just bpf_printk to the kernel trace log.

---

# Testnet Alpha v0.8: Basic Regulatory Compliance (Mocked OFAC & GDPR Stubs)

**Sprint Goal:** Introduce foundational stubs for regulatory compliance. This includes a mocked OFAC screening check for a specific action (e.g., new user registration if applicable, or proposal creation) and a basic mechanism to flag data for GDPR-compliant erasure (without full cryptographic deletion yet).  
**Release Window:** Weeks 15-16

**Key Features Introduced/Demoed (on top of v0.7):**

**Mocked OFAC Screening:**

- When an admin creates a proposal (or a user registers, if applicable), their identifier (e.g., wallet address) is checked against a small, static, mocked OFAC SDN list.
- If a match is found, the action is flagged or prevented (for alpha).
- This is a conceptual demonstration; no real-time API calls to actual OFAC lists.

**GDPR Erasure Stub:**

- A mechanism (e.g., an admin function) to mark a specific piece of data (e.g., a vote commitment or a user record, identified by its hash or ID) as "pending erasure."
- This doesn't perform cryptographic deletion yet but demonstrates the intent and a basic state change.
- A ZK proof might be used to prove authorization for flagging data for erasure.

**Focus Areas from Technical Deep-Dive Documents:**

- zkVote Regulatory Compliance Technical Framework.md: OFAC screening, GDPR compliance (Right to Erasure). This alpha implements very basic, conceptual stubs.
- smartContractInterfaceSpecs.md: Potentially new functions in admin or core contracts for these compliance actions.

**Project Directory Structure (`zkVote_Alpha_v0.8/`):**

```plaintext
zkVote_Alpha_v0.8/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.8
├── circuits/
│   └── compliance/ # New Folder (optional, if ZKP used for erasure auth)
│       └── erasure_authorization.circom # New: ZK circuit for authorizing erasure flagging
├── compliance/ # New Folder
│   ├── fatf_travel_rule/
│   │   └── travel_rule_notes_alpha.md
│   ├── gdpr/
│   │   ├── data_erasure_protocol_alpha.md
│   │   └── gdpr_notes_alpha.md
│   └── ofac_screening/
│       ├── mocked_sdn_list.json # New: Small static list of "sanctioned" addresses
│       └── ofac_notes_alpha.md
├── contracts/
│   ├── compliance/ # New Folder
│   │   ├── OFACScreeningMock.sol # New: Contract with mocked OFAC check logic
│   │   └── GDPRErasureStub.sol # New: Contract to flag data for erasure
│   ├── core/
│   │   ├── VoteFactory.sol # Modified: Potentially calls OFACScreeningMock
│   │   # ... (other core contracts as in v0.4)
│   # ... (other contract folders as in v0.6)
├── deployment/
│   # ... (as in v0.7)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   # ... (as in v0.7, deploy_contracts.ts modified for new compliance contracts)
├── security/
│   # ... (as in v0.7)
├── src/ # Rust backend
│   ├── compliance_logic/ # New Folder
│   │   ├── gdpr_service.rs # New: Logic for interacting with GDPRErasureStub
│   │   └── ofac_service.rs # New: Logic for checking against mocked_sdn_list.json
│   # ... (other src folders as in v0.7)
├── sdk/
│   └── typescript/
│       ├── package.json
│       ├── src/
│       │   ├── index.ts
│       │   └── zkvote_client.ts # Modified: Add functions for admin erasure flagging
│       └── tsconfig.json
├── tests/
│   ├── compliance/ # New Folder
│   │   ├── OFACScreeningMock.test.ts
│   │   └── GDPRErasureStub.test.ts
│   # ... (other test folders as in v0.6)
└── ui/
    ├── admin_app/ # Modified: UI for triggering erasure flagging
    │   └── src/
    │       └── ComplianceDashboard.tsx # New: Basic UI for compliance actions
    # ... (other UI folders as in v0.6)
```

**Key File Descriptions/Changes for Alpha v0.8:**

- `compliance/ofac_screening/mocked_sdn_list.json`: A simple JSON file containing a few addresses that will be treated as "sanctioned" for the demo.
- `contracts/compliance/OFACScreeningMock.sol`: A contract with a function that takes an address and checks if it's in the (hardcoded or admin-set) mocked SDN list. VoteFactory might call this.
- `contracts/compliance/GDPRErasureStub.sol`: A contract that allows an authorized admin to submit a data identifier (e.g., a vote commitment hash) and mark it as "pending erasure." It might store these identifiers in a list or mapping.
- `circuits/compliance/erasure_authorization.circom` (Optional): If ZKPs are used to prove an admin's right to flag data for erasure without revealing which admin, this circuit would be implemented.
- `src/compliance_logic/ofac_service.rs`: Backend logic (if needed) to load and query the mocked_sdn_list.json.
- `src/compliance_logic/gdpr_service.rs`: Backend logic to interact with the GDPRErasureStub.sol contract.
- SDK & UI: Admin UI updated to allow an admin to flag specific data for erasure. The proposal creation flow might show a warning/block if the creator's address is on the mocked SDN list.

---

# Testnet Alpha v0.9: Basic Data Availability (IPFS for Proposal Data & DA Layer Stub)

**Sprint Goal:** Introduce basic data availability concepts by storing larger proposal metadata (e.g., full description, supporting documents) on IPFS. Additionally, implement stubs for interacting with a Data Availability (DA) layer (like Celestia or EigenDA) for posting vote commitments or proofs, without full DA layer integration yet.  
**Release Window:** Weeks 17-18

**Key Features Introduced/Demoed (on top of v0.8):**

**IPFS for Proposal Metadata:**

- When an admin creates a new voting instance, larger proposal details (beyond a simple title or hash) are uploaded to IPFS.
- The IPFS CID (Content Identifier) is then stored on-chain in the VoteFactory or VoteProcessor contract.
- The UI can fetch and display this metadata from IPFS.

**DA Layer Interaction Stub:**

- When a vote is cast, the system (backend or SDK) simulates posting the vote commitment (or a batch of commitments) to a DA layer.
- This involves calling a stub function that logs the intent to post to DA, perhaps returning a mock DA attestation/pointer.
- No actual interaction with a live DA testnet is strictly required for this alpha, but the interfaces are defined.

**Focus Areas from Technical Deep-Dive Documents:**

- zkVote Data Availability & Storage Architecture.md: IPFS pinning, EigenDA/Celestia integration concepts. This alpha implements IPFS for metadata and stubs for DA layer interaction.
- smartContractInterfaceSpecs.md: VoteFactory might store IPFS CIDs.

**Project Directory Structure (`zkVote_Alpha_v0.9/`):**

```plaintext
zkVote_Alpha_v0.9/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.9
├── circuits/
│   # ... (as in v0.8)
├── compliance/
│   # ... (as in v0.8)
├── contracts/
│   ├── core/
│   │   ├── VoteFactory.sol # Modified: To store IPFS CID for proposal data
│   │   └── VoteProcessor.sol # Modified: Potentially store mock DA pointer
│   │   # ...
│   ├── data_availability/ # New Folder
│   │   └── DALayerInterfaceStub.sol # New: Stub interface for DA layer interactions
│   # ... (other contract folders as in v0.8)
├── data_management/ # New Folder
│   ├── ipfs_integration/
│   │   └── ipfs_notes_alpha.md
│   └── tbchain_client/ # (If TBchain is a distinct component, placeholder for now)
│       └── tbchain_notes_alpha.md
├── deployment/
│   # ... (as in v0.7)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   # ... (as in v0.8)
├── security/
│   # ... (as in v0.7)
├── src/ # Rust backend
│   ├── compliance_logic/
│   │   # ... (as in v0.8)
│   ├── integrations/ # New or enhanced folder
│   │   ├── data_availability/ # New Subfolder
│   │   │   ├── celestia_client_stub.rs # New: Stub for Celestia interaction
│   │   │   ├── eigen_da_client_stub.rs # New: Stub for EigenDA interaction
│   │   │   └── mod.rs
│   │   └── ipfs_service.rs # New: Service for uploading/fetching data from IPFS
│   # ... (other src folders as in v0.8)
├── sdk/
│   └── typescript/
│       ├── package.json
│       ├── src/
│       │   ├── index.ts
│       │   └── zkvote_client.ts # Modified: To handle IPFS uploads and DA stub calls
│       └── tsconfig.json
├── tests/
│   # ... (as in v0.8)
│   └── integrations/ # New Folder
│       └── ipfs_service.test.ts # New: Test IPFS interaction logic
└── ui/
    ├── admin_app/
    │   └── src/
    │       └── CreateVoteForm.tsx # Modified: To upload proposal data to IPFS
    ├── voter_app/
    │   └── src/
    │       └── ProposalDetails.tsx # New or Modified: To fetch and display data from IPFS
    # ... (other UI folders as in v0.6)
```

**Key File Descriptions/Changes for Alpha v0.9:**

- `contracts/core/VoteFactory.sol`: Modified to store an IPFS CID alongside other proposal parameters.
- `contracts/data_availability/DALayerInterfaceStub.sol`: A very simple interface defining functions like postData(bytes calldata data) that would, in a real scenario, interact with a DA layer. For alpha, it might just emit an event or log.
- `src/integrations/ipfs_service.rs`: Backend (or SDK) logic to handle uploading data to an IPFS node (could be a local node or a service like Pinata for alpha) and retrieving data by CID.
- `src/integrations/data_availability/celestia_client_stub.rs` / `eigen_da_client_stub.rs`: Stub implementations that simulate posting data to Celestia/EigenDA. They would log the action and return a mock pointer/attestation.
- SDK & UI:
  - **Admin UI:** When creating a vote, allows uploading detailed proposal documents, which are then sent to IPFS by the SDK/backend.
  - **Voter UI:** Fetches and displays proposal metadata from IPFS using the CID stored on-chain.
  - **SDK:** When casting a vote, calls the DA layer stub functions.

---

# Testnet Alpha v0.10: Basic Threshold Cryptography (FROST - Key Generation & Signing Stub)

**Sprint Goal:** Introduce foundational concepts of threshold cryptography using FROST. This involves implementing Distributed Key Generation (DKG) for a small, fixed set of (mocked) coordinator nodes and demonstrating a threshold signature on a simple message. The signing process can be off-chain for this alpha.  
**Release Window:** Weeks 19-20

**Key Features Introduced/Demoed (on top of v0.9):**

**FROST DKG:**

- A script or backend process simulates a DKG among a small number of participants (e.g., 3 coordinators).
- Each participant generates their key share and the group public key is derived.
- This is primarily an off-chain demonstration of the DKG protocol.

**FROST Threshold Signing Stub:**

- The coordinators (or a script simulating them) can collectively sign a simple message using their FROST key shares.
- A function/script verifies this threshold signature against the group public key.
- The focus is on the cryptographic primitives, not yet on integrating this into on-chain governance actions.

**Focus Areas from Technical Deep-Dive Documents:**

- zkVote Threshold Cryptography & MPC Architecture.md: FROST protocol, DKG. This alpha implements basic DKG and signing.
- architecture.md: Touches upon MPC-enhanced key management and threshold signature infrastructure.

**Project Directory Structure (`zkVote_Alpha_v0.10/`):**

```plaintext
zkVote_Alpha_v0.10/
├── .gitignore
├── Cargo.toml # Dependencies for FROST libraries (e.g., frost-core, frost-secp256k1)
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.10
├── circuits/
│   # ... (as in v0.8)
├── compliance/
│   # ... (as in v0.8)
├── contracts/
│   ├── utils/
│   │   └── BLSVerifier.sol # (If BLS is used for FROST, or Schnorr verifier if that's the FROST output)
│   # ... (other contract folders as in v0.9)
├── data_management/
│   # ... (as in v0.9)
├── deployment/
│   # ... (as in v0.7)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   ├── frost_dkg_simulation.rs # New: Rust script to simulate FROST DKG
│   └── frost_sign_simulation.rs # New: Rust script to simulate FROST signing
│   # ... (other scripts as in v0.9)
├── security/
│   # ... (as in v0.7)
├── src/ # Rust backend
│   ├── crypto/
│   │   ├── post_quantum/
│   │   │   # ... (as in v0.6)
│   │   └── threshold_crypto/ # New Folder
│   │       ├── frost/ # New Subfolder
│   │       │   ├── dkg_impl.rs # New: FROST DKG logic
│   │       │   └── sign_impl.rs # New: FROST signing logic
│   │       └── mod.rs
│   ├── compliance_logic/
│   │   # ... (as in v0.8)
│   ├── integrations/
│   │   # ... (as in v0.9)
│   # ... (other src folders as in v0.8)
├── sdk/
│   # ... (as in v0.9 - SDK might not directly interact with FROST yet)
├── tests/
│   └── unit/
│       └── src/
│           └── crypto/
│               └── threshold_crypto/ # New Folder
│                   └── frost_dkg_sign.test.rs # New: Tests for FROST DKG and signing
│   # ... (other test folders as in v0.9)
└── ui/ # ... (as in v0.9 - UI likely not interacting with FROST directly yet)
```

**Key File Descriptions/Changes for Alpha v0.10:**

- `Cargo.toml`: Will include dependencies for Rust-based FROST libraries (e.g., frost-core, frost-secp256k1, rand, sha2).
- `scripts/frost_dkg_simulation.rs`: A command-line Rust application that simulates the multi-round DKG process for FROST among a specified number of participants and threshold. It would output the generated key shares and the group public key.
- `scripts/frost_sign_simulation.rs`: A command-line Rust application that takes a message, the group public key, and the required number of key shares (from the DKG simulation) to produce a threshold signature. It would also verify this signature.
- `src/crypto/threshold_crypto/frost/dkg_impl.rs`: Contains the core Rust logic for implementing the FROST Distributed Key Generation protocol.
- `src/crypto/threshold_crypto/frost/sign_impl.rs`: Contains the core Rust logic for implementing FROST signing and verification.
- `contracts/utils/BLSVerifier.sol` or `SchnorrVerifier.sol`: If the FROST implementation outputs BLS or Schnorr signatures, a corresponding Solidity verifier might be included, though on-chain verification isn't the primary goal of this alpha.
- **Tests:** Unit tests for the DKG and signing logic in Rust.

---

# Testnet Alpha v0.11: Enhanced Cross-Chain Bridge (ZK Light Client Stub / More Robust Bridge)

**Sprint Goal:** Upgrade the basic cross-chain bridge infrastructure. This involves either implementing stubs for a ZK Light Client bridge to demonstrate the architectural pattern or integrating with a more robust, existing third-party bridge protocol on their testnet (e.g., a testnet version of CCIP, Hyperlane, Axelar if feasible for alpha). The aim is to move beyond the simple multisig bridge towards a more trust-minimized or feature-rich cross-chain communication.  
**Release Window:** Weeks 21-22

**Key Features Introduced/Demoed (on top of v0.10):**

**Option A (ZK Light Client Stub):**

- Smart contracts on source and destination chains representing the ZK Light Client.
- A (mocked) relayer service that simulates generating ZK proofs of source chain block headers and submitting them to the destination chain's ZK Light Client contract.
- The destination chain contract simulates verifying these ZK proofs to update its view of the source chain's state.
- Demonstrate relaying a simple message (e.g., a vote commitment hash) using this stubbed ZK Light Client bridge.

**Option B (Third-Party Bridge Integration):**

- Integration with a testnet version of a selected third-party bridge protocol (e.g., CCIP, Hyperlane, Axelar, Wormhole).
- Contracts on source and destination chains that interact with the chosen bridge's endpoints.
- Relayer (if required by the bridge, or using their provided relayers) to pass messages.
- Demonstrate relaying a simple zkVote-related message (e.g., vote commitment) via this bridge.
- Updated SDK to interact with the new bridge mechanism.

**Focus Areas from Technical Deep-Dive Documents:**

- cross-chain_and_aggregation.md: ZK Light Client bridges, Universal Messaging Layer concepts.
- smartContractInterfaceSpecs.md: ICrossChainBridge (potentially a new version or implementation), IUniversalMessenger stubs.
- architecture.md: Enhancements to the Integration Layer, specifically Cross-Chain Bridge components.

**Project Directory Structure (`zkVote_Alpha_v0.11/`):**

```plaintext
zkVote_Alpha_v0.11/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.11
├── circuits/
│   ├── cross_chain/ # New Folder (if ZK Light Client stubs involve new circuits)
│   │   └── zk_light_client_stub.circom # Mock circuit for header verification
│   # ... (other circuits as in v0.10)
├── contracts/
│   ├── core/
│   │   # ... (as in v0.4)
│   ├── cross_chain/
│   │   ├── ICrossChainBridge.sol
│   │   ├── CrossChainBridge_SimpleMultisig.sol # (Kept for comparison or fallback)
│   │   ├── ZKLightClientBridgeStub.sol # New (Option A): Stub for ZK Light Client
│   │   ├── ThirdPartyBridgeAdapter.sol # New (Option B): Adapter for a specific 3rd party bridge
│   │   ├── IUniversalMessenger.sol # New: Interface for UML
│   │   └── UniversalMessengerStub.sol # New: Basic stub for UML
│   │   # ... (other cross_chain contracts as in v0.4)
│   ├── delegation/
│   │   # ... (as in v0.2)
│   ├── identity/
│   │   # ... (as in v0.2)
│   ├── utils/
│   │   # ... (as in v0.10)
│   └── zk_verification/
│       # ... (as in v0.2, potentially new verifier for zk_light_client_stub.circom)
├── data_management/
│   # ... (as in v0.9)
├── deployment/
│   # ... (as in v0.7)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   ├── compile_circuits.sh # Modified if new ZK Light Client stub circuit
│   ├── deploy_contracts.ts # Modified: To deploy new bridge contracts
│   ├── deploy_bridge.ts # Modified or new script for ZKLCS/3rd party bridge
│   ├── relayer_alpha.ts # Modified: To interact with the new bridge
│   └── trusted_setup_alpha.sh # Modified if new ZK Light Client stub circuit
├── security/
│   # ... (as in v0.8)
├── src/ # Rust backend
│   ├── crypto/
│   │   # ... (as in v0.10)
│   ├── compliance_logic/
│   │   # ... (as in v0.8)
│   ├── integrations/
│   │   ├── data_availability/
│   │   │   # ... (as in v0.9)
│   │   └── messaging_protocols/ # New Folder (Option B)
│   │       ├── ccip_adapter_logic.rs
│   │       ├── hyperlane_adapter_logic.rs
│   │       └── mod.rs
│   ├── relayer_service/ # Modified to support new bridge logic
│   │   └── main.rs
│   # ... (other src folders as in v0.10)
├── sdk/
│   └── typescript/
│       ├── package.json
│       ├── src/
│       │   ├── index.ts
│       │   └── zkvote_client.ts # Modified: To use the new bridge mechanism
│       └── tsconfig.json
├── tests/
│   ├── contracts/
│   │   ├── cross_chain/
│   │   │   ├── ZKLightClientBridgeStub.test.ts # New (Option A)
│   │   │   └── ThirdPartyBridgeAdapter.test.ts # New (Option B)
│   │   # ... (other contract tests as in v0.4)
│   # ... (other test folders as in v0.10)
└── ui/
    ├── bridge_monitor_app/ # Potentially updated to reflect new bridge type
    │   # ... (as in v0.3)
    └── voter_app/ # ... (as in v0.4)
```

**Key File Descriptions/Changes for Alpha v0.11:**

- `circuits/cross_chain/zk_light_client_stub.circom` (Option A): A highly simplified Circom circuit that mocks the verification of a block header. For alpha, it might just check a hash or a signature without full cryptographic rigor.
- `contracts/cross_chain/ZKLightClientBridgeStub.sol` (Option A): Smart contract on the destination chain that includes a verifier for zk_light_client_stub.circom. It would have functions to updateHeader(proof, publicSignals) and verifyMessageInclusion(message, inclusionProof, headerId).
- `contracts/cross_chain/ThirdPartyBridgeAdapter.sol` (Option B): An adapter contract that interfaces with the chosen third-party bridge's smart contracts (e.g., CCIP Router, Hyperlane Mailbox).
- `contracts/cross_chain/IUniversalMessenger.sol` & `UniversalMessengerStub.sol`: Introduction of the Universal Messaging Layer interface and a basic stub. The chosen bridge (ZKLightClientStub or ThirdPartyBridgeAdapter) would be one implementation of this.
- `scripts/relayer_alpha.ts`: Significantly modified.
  - For Option A: Simulates fetching block headers, generating (mock) ZK proofs, and submitting them to ZKLightClientBridgeStub.sol.
  - For Option B: Interacts with the third-party bridge's SDK or API to relay messages, or relies on their existing relayer network.
- `src/integrations/messaging_protocols/` (Option B, Rust backend): If the backend needs to directly interact with third-party bridge SDKs (e.g., for message formatting or direct submission if not using their relayers).
- **SDK (zkvote_client.ts):** Updated to abstract the interaction with the new bridge, whether it's the ZK Light Client stub or a third-party bridge.
- **UI (bridge_monitor_app/):** May be updated to show messages being relayed via the new bridge type, or to select different bridge options if multiple are being experimented with.

---

# Testnet Alpha v0.12: Advanced Private Delegation (Revocation & Time-bounds)

**Sprint Goal:** Enhance the private delegation mechanism by introducing the ability for delegators to privately revoke their delegations and to set time-bounds (start/end times) for delegations.  
**Release Window:** Weeks 23-24

**Key Features Introduced/Demoed (on top of v0.11):**

**Private Revocation:**

- Delegators can generate a ZK proof to revoke an existing private delegation without revealing their identity or the specific delegation being revoked to the public.
- The DelegationRegistry contract is updated to process these revocation proofs, marking the corresponding delegation commitment as invalid (e.g., by adding its nullifier to a "revoked" list or updating its state).

**Time-Bounded Delegations:**

- Delegators can specify a start time and/or an end time when creating a delegation.
- The ZK circuits for delegation authorization and voting with delegation are updated to enforce these time constraints.
- The DelegationRegistry and DelegationVoter (or VoteProcessor) contracts check these time-bounds.
- Updated SDK and UI to support creating time-bounded delegations and initiating revocations.

**Focus Areas from Technical Deep-Dive Documents:**

- delegationPrivacyDeepDive.md: Private revocation protocols, temporal constraints in delegation.
- zk-SNARK_circuitDesignSpecs.md: New/updated circuits for delegation_revocation.circom and modifications to delegation_authorization.circom and vote_with_delegation.circom to handle time-bounds.
- smartContractInterfaceSpecs.md: Updates to IDelegationRegistry and IDelegationVoter.

**Project Directory Structure (`zkVote_Alpha_v0.12/`):**

```plaintext
zkVote_Alpha_v0.12/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.12
├── circuits/
│   ├── compliance/
│   │   # ... (as in v0.8)
│   ├── cross_chain/
│   │   # ... (as in v0.11)
│   ├── delegation/ # Enhanced Folder
│   │   ├── delegation_authorization.circom # Modified: To include time-bound inputs/checks
│   │   ├── delegation_revocation.circom # New: ZK circuit for revoking a delegation
│   │   └── vote_with_delegation.circom # Modified: To check time-bounds of delegation
│   └── vote_casting.circom
├── contracts/
│   ├── core/
│   │   ├── VoteProcessor.sol # Modified: If it handles delegated votes, to check time-bounds
│   │   # ... (as in v0.4)
│   ├── cross_chain/
│   │   # ... (as in v0.11)
│   ├── delegation/
│   │   ├── IDelegationRegistry.sol # Modified: Add revokeDelegation, handle time-bounds
│   │   ├── DelegationRegistry.sol # Modified: Implement revocation logic, store/check time-bounds
│   │   ├── IDelegationVoter.sol # Modified: To consider time-bounds
│   │   └── DelegationVoter.sol # Modified: To enforce time-bounds during voting
│   ├── identity/
│   │   # ... (as in v0.2)
│   ├── utils/
│   │   # ... (as in v0.10)
│   └── zk_verification/
│       ├── Groth16Verifier_DelegationAuth.sol # Potentially re-generated
│       ├── Groth16Verifier_DelegationRevoke.sol # New: Verifier for delegation_revocation.circom
│       ├── Groth16Verifier_VoteCast.sol
│       └── Groth16Verifier_VoteWithDeleg.sol # Potentially re-generated
├── data_management/
│   # ... (as in v0.9)
├── deployment/
│   # ... (as in v0.7)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   ├── compile_circuits.sh # Modified: To compile new/updated delegation circuits
│   ├── deploy_contracts.ts # Modified: To deploy updated delegation contracts
│   ├── deploy_bridge.ts
│   ├── relayer_alpha.ts
│   └── trusted_setup_alpha.sh # Modified: For new/updated circuits
├── security/
│   # ... (as in v0.8)
├── src/
│   # ... (as in v0.11, core proof_utils might be updated for new circuits)
├── sdk/
│   └── typescript/
│       ├── package.json
│       ├── src/
│       │   ├── index.ts
│       │   └── zkvote_client.ts # Modified: Add functions for time-bounded delegation and revocation
│       └── tsconfig.json
├── tests/
│   ├── contracts/
│   │   ├── delegation/
│   │   │   └── DelegationRegistry.test.ts # Modified: Test revocation and time-bounds
│   │   # ... (other contract tests as in v0.11)
│   └── unit/
│       └── circuits/
│           ├── delegation_authorization.test.js # Modified: Test time-bounds
│           ├── delegation_revocation.test.js # New
│           └── vote_with_delegation.test.js # Modified: Test time-bounds
│   # ... (other circuit tests as in v0.2)
└── ui/
    └── voter_app/
        ├── package.json
        ├── public/
        │   └── index.html
        └── src/
            ├── App.tsx
            ├── components/
            │   ├── DelegateForm.tsx # Modified: Add fields for start/end time
            │   └── RevokeDelegationForm.tsx # New: UI for revoking a delegation
            │   └── VoteForm.tsx
            └── services/
                └── zkvote.service.ts # Modified
```

**Key File Descriptions/Changes for Alpha v0.12:**

- `circuits/delegation/delegation_authorization.circom`: Modified to take startTime and endTime as public inputs (or incorporate them into the commitment) and add constraints to ensure the current block time (passed as a private input, but constrained against a public oracle/timestamp) is within these bounds if they are set.
- `circuits/delegation/delegation_revocation.circom`: New circuit. Takes as private input the delegator's secret and the original delegation commitment's details. Public inputs would be the revocation nullifier and the original delegation commitment (or its hash). It proves that the revoker is the original delegator and correctly computes the revocation nullifier (e.g., H(delegator_secret, "revoke", original_delegation_commitment_hash)).
- `circuits/delegation/vote_with_delegation.circom`: Modified to check the startTime and endTime of the delegation being used against the current block time.
- `contracts/delegation/DelegationRegistry.sol`:
  - `registerDelegation`: Modified to store startTime and endTime along with the delegation commitment.
  - `revokeDelegation(revocationProof, publicSignals)`: New function to process revocation. Verifies the delegation_revocation proof, checks the revocation nullifier, and marks the original delegation commitment as revoked.
- `contracts/delegation/DelegationVoter.sol` (or VoteProcessor.sol): When processing a vote with delegated power, it must now also check if the current block time is within the startTime and endTime of the delegation (if set and not already enforced by the ZK circuit, though circuit enforcement is preferred).
- **SDK & UI:**
  - Delegation creation flow updated to allow setting optional start and end times.
  - New UI and SDK functions for a delegator to select one of their existing delegations and initiate a private revocation. This involves the SDK generating the delegation_revocation proof.

# Testnet Alpha v0.13: Full TEE Integration for Tallying (SGX/TrustZone)

**Sprint Goal:** Implement a functional Trusted Execution Environment (TEE) for private vote tallying, moving beyond the mocked TEE from Alpha v0.5. This involves deploying a real (though potentially simplified for alpha) SGX enclave or TrustZone Trusted Application.  
**Release Window:** Weeks 25-26

**Key Features Introduced/Demoed (on top of v0.12):**

- Deployment of a basic SGX enclave (or TrustZone TA) that can receive encrypted vote commitments.
- The TEE decrypts votes (using keys provisioned securely or derived within the TEE) and performs the tally.
- The TEE generates a signed attestation of the tally result and potentially a proof of correct execution.
- A backend service interacts with the TEE, submitting encrypted votes and retrieving attested results.
- Basic remote attestation flow to verify the TEE's integrity before sending it sensitive data.

**Focus Areas from Technical Deep-Dive Documents:**

- Confidential Computing & TEE Integration for zkVot.md: Full TEE-enabled vote processing, SGX/TrustZone implementation details, remote attestation protocols.
- architecture.md: Implementation of the Confidential Computing Layer.
- smartContractInterfaceSpecs.md: IVoteResultManager might interact with TEE-attested results.

**Project Directory Structure (`zkVote_Alpha_v0.13/`):**

```plaintext
zkVote_Alpha_v0.13/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.13
├── circuits/
│   # ... (as in v0.12)
├── contracts/
│   ├── core/
│   │   ├── VoteResultManager.sol # Modified: To handle TEE-attested results
│   │   # ... (other core contracts as in v0.4)
│   # ... (other contract folders as in v0.12)
├── data_management/
│   # ... (as in v0.9)
├── deployment/
│   └── kubernetes/
│       # ... (as in v0.7, potentially new deployment for TEE components)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   # ... (as in v0.12)
│   └── provision_tee_keys.sh # New: Script for (mocked/test) TEE key provisioning
├── security/
│   ├── confidential_computing/
│   │   ├── sgx_enclave/ # Enhanced: Actual SGX enclave code
│   │   │   ├── enclave.c
│   │   │   ├── enclave.edl
│   │   │   └── Makefile
│   │   ├── trustzone_app/ # New (Alternative to SGX): TrustZone TA code
│   │   │   ├── ta.c
│   │   │   └── ta_dev_kit/
│   │   ├── attestation_protocols/
│   │   │   ├── sgx_attestation_client.rs # Client logic for SGX attestation
│   │   │   └── trustzone_attestation_client.rs # Client logic for TZ attestation
│   │   └── secure_communication/
│   │       └── enclave_channel_setup_logic.rs # Logic for secure channel to TEE
│   ├── post_quantum/
│   │   # ... (as in v0.6)
│   └── runtime_monitoring/
│       # ... (as in v0.7)
├── src/ # Rust backend
│   ├── aggregator_service/
│   │   ├── main.rs
│   │   └── tee_connector.rs # Modified: To interact with actual TEE & attestation
│   # ... (other src folders as in v0.11)
├── sdk/
│   # ... (as in v0.12)
├── tests/
│   ├── security/
│   │   └── confidential_computing/
│   │       └── test_tee_tallying_flow.rs # Modified: Test with actual TEE interaction
│   # ... (other test folders as in v0.12)
└── ui/
    # ... (as in v0.12, UI might display TEE attestation status for results)
```

**Key File Descriptions/Changes for Alpha v0.13:**

- `security/confidential_computing/sgx_enclave/enclave.c`: Actual C code for the SGX enclave performing decryption and tallying. This would use the SGX SDK.
- `security/confidential_computing/trustzone_app/ta.c` (Alternative): Actual C code for a TrustZone Trusted Application.
- `security/confidential_computing/attestation_protocols/`: Client-side logic in Rust (or another language) to perform remote attestation with the SGX enclave (e.g., using DCAP) or TrustZone TA.
- `src/aggregator_service/tee_connector.rs`: Backend Rust code now interacts with a real TEE. This includes:
  - Performing remote attestation.
  - Establishing a secure channel (e.g., TLS) with the attested TEE.
  - Sending encrypted vote data to the TEE.
  - Receiving the attested tally result from the TEE and verifying the attestation.
- `contracts/core/VoteResultManager.sol`: May be updated to store/verify TEE attestations alongside results.
- **Testing:** Focus on the secure deployment of the TEE, the remote attestation process, and the secure communication channel.

---

# Testnet Alpha v0.14: Advanced Data Availability (EigenDA/Celestia Integration)

**Sprint Goal:** Implement functional integration with a chosen Data Availability (DA) layer's testnet (e.g., EigenDA Holesky testnet, Celestia Mocha testnet), moving beyond the DA stubs from Alpha v0.9. This involves posting actual vote commitments or proofs to the DA layer and retrieving DA attestations.  
**Release Window:** Weeks 27-28

**Key Features Introduced/Demoed (on top of v0.13):**

- zkVote backend service can connect to an EigenDA or Celestia testnet.
- Vote commitments (or batches of them, or ZK proofs of votes) are formatted and submitted as blobs to the chosen DA layer.
- The system retrieves DA attestations (e.g., EigenDA quorum signatures, Celestia Merkle proofs of inclusion) confirming data availability.
- Smart contracts on the L1/L2 can verify these DA attestations (either directly or via a bridge/oracle that checks DA).
- Demonstrate posting vote data to the DA layer and verifying its availability.

**Focus Areas from Technical Deep-Dive Documents:**

- zkVote Data Availability & Storage Architecture.md: EigenDA/Celestia integration details, DA attestations, namespace management.
- architecture.md: Implementation of the Data Availability Layer.
- smartContractInterfaceSpecs.md: Contracts might store DA pointers/attestations.

**Project Directory Structure (`zkVote_Alpha_v0.14/`):**

```plaintext
zkVote_Alpha_v0.14/
├── .gitignore
├── Cargo.toml # May add DA client libraries (e.g., for Celestia)
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.14
├── circuits/
│   # ... (as in v0.12)
├── compliance/
│   # ... (as in v0.8)
├── contracts/
│   ├── core/
│   │   ├── VoteProcessor.sol # Modified: To store DA pointers/attestations
│   │   # ...
│   ├── data_availability/
│   │   ├── DALayerInterfaceStub.sol # (Kept or replaced by actual verifier)
│   │   ├── EigenDAAttestationVerifier.sol # New: Contract to verify EigenDA attestations (simplified)
│   │   └── CelestiaDASVerifier.sol # New: Contract to verify Celestia DAS proofs (simplified)
│   # ... (other contract folders as in v0.13)
├── data_management/
│   ├── ipfs_integration/
│   │   # ... (as in v0.9)
│   └── tbchain_client/
│       # ... (as in v0.9)
├── deployment/
│   # ... (as in v0.13)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   # ... (as in v0.13)
├── security/
│   # ... (as in v0.13)
├── src/ # Rust backend
│   ├── compliance_logic/
│   │   # ... (as in v0.8)
│   ├── integrations/
│   │   ├── data_availability/
│   │   │   ├── celestia_client.rs # New/Enhanced: Actual Celestia client logic
│   │   │   ├── eigen_da_client.rs # New/Enhanced: Actual EigenDA client logic
│   │   │   └── mod.rs
│   │   ├── ipfs_service.rs
│   │   └── messaging_protocols/
│   │       # ... (as in v0.11)
│   # ... (other src folders as in v0.13)
├── sdk/
│   └── typescript/
│       # ... (as in v0.12, SDK might expose DA pointers)
├── tests/
│   ├── contracts/
│   │   └── data_availability/ # New Folder
│   │       ├── EigenDAAttestationVerifier.test.ts
│   │       └── CelestiaDASVerifier.test.ts
│   ├── integrations/
│   │   ├── ipfs_service.test.ts
│   │   └── data_availability.test.rs # New: Test DA layer interactions
│   # ... (other test folders as in v0.13)
└── ui/
    # ... (as in v0.13, UI might display DA status/pointers)
```

**Key File Descriptions/Changes for Alpha v0.14:**

- `contracts/data_availability/EigenDAAttestationVerifier.sol` / `CelestiaDASVerifier.sol`: Smart contracts (can be simplified for alpha) on the L1/L2 that can verify attestations from the respective DA layers. This might involve checking signatures from an EigenDA quorum or verifying Merkle proofs against a Celestia data root relayed by an oracle.
- `src/integrations/data_availability/celestia_client.rs` / `eigen_da_client.rs`: Backend Rust code that now contains actual client logic to:
  - Connect to the Celestia or EigenDA testnet nodes/APIs.
  - Prepare data blobs (e.g., vote commitments, proofs) according to the DA layer's specifications (including namespace usage for Celestia).
  - Submit these blobs to the DA layer.
  - Retrieve and store the DA attestations.
- `contracts/core/VoteProcessor.sol`: Modified to store DA pointers (e.g., EigenDA blob ID, Celestia block height and namespace) and potentially the DA attestation itself, or a hash of it.
- **SDK & UI:** May be updated to show DA pointers or allow users/admins to verify data availability through an external DA explorer or a simplified in-app checker.

---

# Testnet Alpha v0.15: Full FATF Travel Rule Implementation (Conceptual)

**Sprint Goal:** Implement a more comprehensive, though still conceptual for an alpha, version of the FATF Travel Rule compliance mechanism. This involves simulating the exchange of originator/beneficiary information between two mock VASPs (Virtual Asset Service Providers) using a standardized protocol like TRISA or OpenVASP, potentially with ZKPs for data minimization.  
**Release Window:** Weeks 29-30

**Key Features Introduced/Demoed (on top of v0.14):**

- Two mock VASP services (can be simple backend applications).
- When a "regulated" action occurs (e.g., a large delegation or a specific type of vote participation), the originating mock VASP prepares Travel Rule information.
- This information is (conceptually) exchanged with the beneficiary mock VASP using a simplified version of a Travel Rule protocol (e.g., TRP - Travel Rule Protocol by OpenVASP, or TRISA IVMS101 message format).
- ZKPs can be used to prove certain attributes of the Travel Rule data (e.g., "originator's jurisdiction is X") without revealing the full data to an intermediary or the zkVote protocol itself.
- Demonstrate the flow of information exchange and compliance checks between the mock VASPs.

**Focus Areas from Technical Deep-Dive Documents:**

- zkVote Regulatory Compliance Technical Framework.md: FATF Travel Rule implementation architecture, data flow, verification mechanisms, cross-border considerations.
- smartContractInterfaceSpecs.md: Contracts might interact with compliance attestations.

**Project Directory Structure (`zkVote_Alpha_v0.15/`):**

```plaintext
zkVote_Alpha_v0.15/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.15
├── circuits/
│   ├── compliance/
│   │   ├── erasure_authorization.circom
│   │   └── travel_rule_attribute_proof.circom # New: ZKP for proving attributes of TR data
│   # ... (other circuits as in v0.12)
├── compliance/
│   ├── fatf_travel_rule/
│   │   ├── travel_rule_implementation_notes_alpha.md # Enhanced
│   │   ├── trisa_ivms101_stub.json # Example message format
│   │   └── vasp_directory_interface_logic_stub.rs # Mock VASP directory
│   ├── gdpr/
│   │   # ... (as in v0.8)
│   └── ofac_screening/
│       # ... (as in v0.8)
├── contracts/
│   ├── compliance/
│   │   ├── OFACScreeningMock.sol
│   │   ├── GDPRErasureStub.sol
│   │   └── TravelRuleComplianceOracle.sol # New: Mock oracle for TR compliance status
│   # ... (other contract folders as in v0.14)
├── data_management/
│   # ... (as in v0.14)
├── deployment/
│   # ... (as in v0.13)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   # ... (as in v0.13)
├── security/
│   # ... (as in v0.13)
├── src/ # Rust backend
│   ├── compliance_logic/
│   │   ├── gdpr_service.rs
│   │   ├── ofac_service.rs
│   │   └── travel_rule_service.rs # New: Logic for TR data prep & mock exchange
│   ├── mock_vasp_service_a/ # New: Mock VASP A
│   │   └── main.rs
│   ├── mock_vasp_service_b/ # New: Mock VASP B
│   │   └── main.rs
│   # ... (other src folders as in v0.14)
├── sdk/
│   # ... (as in v0.14)
├── tests/
│   ├── compliance/
│   │   ├── OFACScreeningMock.test.ts
│   │   ├── GDPRErasureStub.test.ts
│   │   └── TravelRuleFlow.test.rs # New: Test for TR data exchange flow
│   # ... (other test folders as in v0.14)
└── ui/
    # ... (as in v0.13, admin UI might show TR compliance status for certain actions)
```

**Key File Descriptions/Changes for Alpha v0.15:**

- `circuits/compliance/travel_rule_attribute_proof.circom`: A ZK circuit that allows a VASP to prove certain attributes about Travel Rule data (e.g., "originator name matches KYC record," "transaction amount is below threshold X") without revealing the raw data.
- `compliance/fatf_travel_rule/trisa_ivms101_stub.json`: An example of the IVMS101 message format, used as a template for the mock exchange.
- `contracts/compliance/TravelRuleComplianceOracle.sol`: A mock smart contract that can be queried to check the conceptual Travel Rule compliance status of a transaction or address. In a real system, this might be updated by off-chain compliance services.
- `src/compliance_logic/travel_rule_service.rs`: Backend logic within zkVote (or a simulated VASP) to prepare Travel Rule data, potentially generate ZKPs about it, and simulate sending/receiving it.
- `src/mock_vasp_service_a/` & `src/mock_vasp_service_b/`: Simple backend applications (e.g., Rust Actix/Axum servers) that simulate two VASPs exchanging Travel Rule information. They would have APIs to send/receive this data.
- **Testing:** Focus on the simulated data exchange flow, the generation and verification of ZKPs for Travel Rule attributes, and the interaction with the mock TravelRuleComplianceOracle.

---

# Testnet Alpha v0.16: Full GDPR Compliance (Merkle Proof-Based Deletion)

**Sprint Goal:** Implement the Merkle proof-based deletion mechanism for GDPR's "Right to Erasure," moving beyond the basic stub from Alpha v0.8. This involves allowing users (or authorized entities) to request deletion of their specific data, and the system verifiably removes or obfuscates it from the active dataset using Merkle tree manipulations.  
**Release Window:** Weeks 31-32

**Key Features Introduced/Demoed (on top of v0.15):**

- A data structure (e.g., Merkle Mountain Range or similar append-only authenticated structure) that supports verifiable deletion.
- Users can request deletion of their specific data (e.g., their vote commitment, identity link).
- The system processes the deletion request by updating the Merkle tree (e.g., replacing the leaf with a zero hash or a tombstone value) and providing a proof of this update.
- The overall Merkle root changes, proving the dataset was modified.
- Verification mechanisms to ensure that only authorized requests lead to deletion and that the deletion is correctly performed without compromising the integrity of other data.
- ZKPs can be used to prove authorization for deletion without revealing the requester's identity directly to the deletion processing mechanism.

**Focus Areas from Technical Deep-Dive Documents:**

- zkVote Regulatory Compliance Technical Framework.md: Merkle proof-based deletion architecture, deletion verification mechanisms.
- smartContractInterfaceSpecs.md: GDPRErasureStub.sol would be replaced or enhanced with verifiable deletion logic.
- architecture.md: Data Architecture, specifically how data is structured to allow verifiable deletion.

**Project Directory Structure (`zkVote_Alpha_v0.16/`):**

```plaintext
zkVote_Alpha_v0.16/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.16
├── circuits/
│   ├── compliance/
│   │   ├── erasure_authorization.circom # Enhanced: For authorizing verifiable deletion
│   │   └── travel_rule_attribute_proof.circom
│   # ... (other circuits as in v0.12)
├── compliance/
│   ├── fatf_travel_rule/
│   │   # ... (as in v0.15)
│   ├── gdpr/
│   │   ├── data_erasure_protocol.md # Enhanced: Details of verifiable deletion
│   │   └── gdpr_notes_alpha.md
│   └── ofac_screening/
│       # ... (as in v0.8)
├── contracts/
│   ├── compliance/
│   │   ├── OFACScreeningMock.sol
│   │   ├── MerkleDeleteVerifier.sol # New: Contract to verify deletion proofs
│   │   └── TravelRuleComplianceOracle.sol
│   ├── core/
│   │   ├── VoteProcessor.sol # Modified: To interact with MerkleDeleteVerifier for data erasure
│   │   # ...
│   # ... (other contract folders as in v0.15)
├── data_management/
│   ├── merkle_delete_tree/ # New: Logic for the append-only Merkle tree with deletion
│   │   └── tree_logic.rs
│   # ... (as in v0.14)
├── deployment/
│   # ... (as in v0.13)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   # ... (as in v0.13)
├── security/
│   # ... (as in v0.13)
├── src/ # Rust backend
│   ├── compliance_logic/
│   │   ├── gdpr_service.rs # Modified: To handle verifiable deletion requests
│   │   ├── ofac_service.rs
│   │   └── travel_rule_service.rs
│   # ... (other src folders as in v0.15)
├── sdk/
│   └── typescript/
│       ├── package.json
│       ├── src/
│       │   ├── index.ts
│       │   └── zkvote_client.ts # Modified: Add functions for requesting verifiable deletion
│       └── tsconfig.json
├── tests/
│   ├── compliance/
│   │   ├── OFACScreeningMock.test.ts
│   │   ├── MerkleDeleteVerifier.test.ts # New
│   │   └── TravelRuleFlow.test.rs
│   └── unit/
│       └── data_management/ # New
│           └── merkle_delete_tree.test.rs
│   # ... (other test folders as in v0.15)
└── ui/
    ├── admin_app/
    │   └── src/
    │       └── ComplianceDashboard.tsx # Modified: To show verifiable deletion status
    └── voter_app/ # Modified: UI for users to request data deletion
        └── src/
            └── UserProfile.tsx # Example: Section for data management & deletion requests
```

**Key File Descriptions/Changes for Alpha v0.16:**

- `circuits/compliance/erasure_authorization.circom`: Enhanced or new ZK circuit to prove that a user (or an authorized entity) has the right to request deletion of specific data linked to their identity, without revealing the identity itself during the authorization check.
- `contracts/compliance/MerkleDeleteVerifier.sol`: A smart contract that stores the root of the Merkle tree containing user data. It would have functions to:
  - Verify a proof that specific data exists.
  - Verify a proof that specific data was "deleted" (e.g., its leaf updated to a tombstone/zero value) and that the Merkle root was updated correctly.
- `data_management/merkle_delete_tree/tree_logic.rs`: Off-chain Rust logic for managing the append-only Merkle tree that supports verifiable deletion. This includes functions for adding data, "deleting" data (updating leaves), and generating proofs of inclusion/exclusion/update.
- `src/compliance_logic/gdpr_service.rs`: Backend service modified to:
  - Receive deletion requests.
  - Verify authorization (possibly using ZKPs from erasure_authorization.circom).
  - Instruct the merkle_delete_tree logic to perform the deletion.
  - Obtain a proof of deletion and potentially submit the new Merkle root to MerkleDeleteVerifier.sol.
- **SDK & UI:**
  - Voter UI: Allows users to request deletion of their data, potentially generating a ZKP for authorization.
  - Admin UI: Allows administrators/data controllers to process deletion requests and view the status of the Merkle tree/proofs.

---

# Testnet Alpha v0.17: Advanced Threshold Cryptography (FROST On-chain Integration)

**Sprint Goal:** Integrate the FROST threshold signature scheme (from Alpha v0.10) for a specific, critical on-chain governance action. This involves having a set of distributed key holders (coordinators) collectively authorize an action by generating a FROST signature that is then verified by a smart contract.  
**Release Window:** Weeks 33-34

**Key Features Introduced/Demoed (on top of v0.16):**

- A smart contract function that requires a FROST threshold signature for execution (e.g., pausing the protocol, upgrading a contract, changing a critical parameter).
- A set of (mocked or actual) coordinator nodes, each holding a share of a FROST key.
- An off-chain process/tool for these coordinators to:
  - Agree on a message/action to sign.
  - Participate in the FROST signing rounds (commitment and signature share generation).
  - Aggregate the signature shares into a final FROST threshold signature.
- The aggregated FROST signature is submitted to the smart contract.
- The smart contract verifies the FROST signature against the group public key before allowing the action.

**Focus Areas from Technical Deep-Dive Documents:**

- zkVote Threshold Cryptography & MPC Architecture.md: FROST v2 implementation, DKG, HSM integration (HSM part might be simplified for this alpha).
- smartContractInterfaceSpecs.md: Contracts requiring threshold signatures for sensitive operations.
- architecture.md: MPC-enhanced key management, Threshold Signature Infrastructure.

**Project Directory Structure (`zkVote_Alpha_v0.17/`):**

```plaintext
zkVote_Alpha_v0.17/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.17
├── circuits/
│   # ... (as in v0.16)
├── compliance/
│   # ... (as in v0.16)
├── contracts/
│   ├── core/
│   │   ├── ProtocolSettingsAdmin.sol # New: Contract managing settings via threshold sigs
│   │   # ...
│   ├── utils/
│   │   ├── BLSVerifier.sol
│   │   └── FROSTSchnorrVerifier.sol # New: Verifier for FROST (Schnorr) signatures
│   # ... (other contract folders as in v0.16)
├── data_management/
│   # ... (as in v0.16)
├── deployment/
│   # ... (as in v0.13)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   ├── frost_dkg_simulation.rs
│   ├── frost_sign_simulation.rs # Modified: To output signature for on-chain use
│   └── deploy_contracts.ts # Modified: To deploy ProtocolSettingsAdmin & verifier
│   # ... (other scripts as in v0.13)
├── security/
│   # ... (as in v0.13)
├── src/ # Rust backend
│   ├── crypto/
│   │   ├── post_quantum/
│   │   │   # ... (as in v0.6)
│   │   └── threshold_crypto/
│   │       ├── frost/
│   │       │   ├── dkg_impl.rs
│   │       │   └── sign_impl.rs # Modified: To be callable as a library/service
│   │       └── mod.rs
│   ├── coordinator_service/ # New: Service for coordinators to participate in FROST signing
│   │   └── main.rs
│   # ... (other src folders as in v0.16)
├── sdk/
│   └── typescript/
│       # ... (as in v0.16, SDK might have tools for submitting threshold-signed txs)
├── tests/
│   ├── contracts/
│   │   └── core/
│   │       └── ProtocolSettingsAdmin.test.ts # New
│   └── unit/
│       └── src/
│           └── crypto/
│               └── threshold_crypto/
│                   └── frost_onchain_flow.test.rs # New: Test FROST signing for on-chain action
│   # ... (other test folders as in v0.16)
└── ui/
    ├── admin_app/ # Modified: UI for initiating actions requiring threshold sigs
    │   # ...
    └── coordinator_app/ # New: Simple UI for coordinators to approve/sign actions
        └── src/ App.tsx
```

**Key File Descriptions/Changes for Alpha v0.17:**

- `contracts/core/ProtocolSettingsAdmin.sol`: A new smart contract (or an existing admin contract modified) that has functions (e.g., changeParameter(paramId, newValue, frostSignature)) which require a valid FROST threshold signature to execute. It would store the FROST group public key and threshold.
- `contracts/utils/FROSTSchnorrVerifier.sol`: A Solidity library or contract capable of verifying Schnorr signatures (as produced by FROST) against a given public key and message.
- `src/crypto/threshold_crypto/frost/sign_impl.rs`: The FROST signing logic might be refactored to be callable as part of a service or library, rather than just a simulation script.
- `src/coordinator_service/main.rs`: A backend service (or a set of CLI tools) that allows simulated coordinator nodes to:
  - Receive a request to sign a message (e.g., the hash of a proposed parameter change).
  - Perform the two rounds of FROST signing (commitment exchange, signature share generation).
  - One coordinator (or the service) aggregates the shares into the final threshold signature.
- `scripts/frost_sign_simulation.rs`: Modified to output the signature in a format suitable for submission to the smart contract.
- **UI (coordinator_app/):** A very basic UI where mock coordinators can see pending signature requests and "approve" them, triggering their participation in the FROST signing protocol.
- **Testing:** Focus on the end-to-end flow: initiating an action, coordinators generating a FROST signature, submitting it to the smart contract, and the contract verifying it and executing the action.

---

# Testnet Alpha v0.18: Advanced Post-Quantum Cryptography (Lattice-based ZKP for a Small Component)

**Sprint Goal:** Introduce a functional, albeit simple, lattice-based ZK proof system for a small, non-critical component of zkVote. This moves beyond just PQ signatures (Alpha v0.6) and demonstrates the feasibility of PQ ZKPs within the protocol.  
**Release Window:** Weeks 35-36

**Key Features Introduced/Demoed (on top of v0.17):**

- Selection of a simple statement to prove using a lattice-based ZKP scheme (e.g., proving knowledge of a pre-image to a hash using a lattice-based commitment, or a very simple eligibility check).
- Implementation of a basic prover and verifier for this lattice-based ZKP scheme (e.g., using a library that supports SIS/LWE-based proofs).
- A smart contract that can verify these lattice-based ZK proofs (may require a highly optimized verifier or off-chain pre-verification with on-chain attestation for alpha due to gas costs).
- Demonstrate generating and verifying a lattice-based ZK proof for the chosen simple component.

**Focus Areas from Technical Deep-Dive Documents:**

- zkVote Post-Quantum Cryptography Implementation Gu.md: Lattice-based ZKPs, circuit design for lattice operations.
- zk-SNARK_circuitDesignSpecs.md: Adapting circuit design principles for lattice-based schemes.
- architecture.md: Integrating PQ ZKPs into the Zero-Knowledge Proof Engine.

**Project Directory Structure (`zkVote_Alpha_v0.18/`):**

```plaintext
zkVote_Alpha_v0.18/
├── .gitignore
├── Cargo.toml # May add lattice crypto libraries
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.18
├── circuits/
│   ├── post_quantum/ # New Folder
│   │   └── simple_lattice_proof.circom # Or other representation if not Circom
│   # ... (other circuits as in v0.16)
├── compliance/
│   # ... (as in v0.16)
├── contracts/
│   ├── utils/
│   │   ├── DilithiumVerifier.sol
│   │   ├── FROSTSchnorrVerifier.sol
│   │   └── LatticeZKPVerifier.sol # New: Solidity verifier for the simple lattice ZKP
│   ├── zk_verification/ # Potentially new verifier contract
│   │   # ...
│   # ... (other contract folders as in v0.17)
├── data_management/
│   # ... (as in v0.16)
├── deployment/
│   # ... (as in v0.13)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   # ... (as in v0.17)
├── security/
│   ├── post_quantum/
│   │   ├── pq_risk_assessment_alpha.md
│   │   ├── pq_transition_plan_alpha.md
│   │   └── lattice_zkp_notes.md # New: Notes on the chosen lattice ZKP scheme
│   # ... (other security folders as in v0.13)
├── src/ # Rust backend
│   ├── crypto/
│   │   ├── post_quantum/
│   │   │   ├── dilithium_lib.rs
│   │   │   ├── hybrid_signature.rs
│   │   │   └── lattice_zkp_prover.rs # New: Rust logic for generating lattice ZKPs
│   │   └── threshold_crypto/
│   │       # ... (as in v0.17)
│   # ... (other src folders as in v0.17)
├── sdk/
│   └── typescript/
│       # ... (as in v0.17, SDK might support generating/submitting lattice ZKPs)
├── tests/
│   ├── contracts/
│   │   └── utils/
│   │       └── LatticeZKPVerifier.test.ts # New
│   └── unit/
│       └── src/
│           └── crypto/
│               └── post_quantum/
│                   ├── hybrid_signature.test.rs
│                   └── lattice_zkp.test.rs # New
│   # ... (other test folders as in v0.17)
└── ui/
    # ... (as in v0.17, UI might demo the component using lattice ZKP)
```

**Key File Descriptions/Changes for Alpha v0.18:**

- `circuits/post_quantum/simple_lattice_proof.circom`: The representation of the simple ZK proof. If not Circom (as lattice schemes often use different formalisms), this might be a specification file or code in a language like Rust that defines the arithmetic circuit or relation for the proof.
- `contracts/utils/LatticeZKPVerifier.sol`: A Solidity contract (likely highly optimized or simplified for alpha) that can verify the chosen lattice-based ZK proofs. Verifying lattice proofs on-chain can be very gas-intensive, so this might involve significant simplifications or focus on a very small proof.
- `src/crypto/post_quantum/lattice_zkp_prover.rs`: Rust code containing the logic to generate proofs for the chosen lattice-based ZKP scheme. This would likely use a specialized lattice cryptography library.
- **Testing:** Focus on the correctness of the lattice-based prover and verifier. Benchmarking on-chain verification gas costs will be crucial.

---

# Testnet Alpha v0.19: Advanced Runtime Security Monitoring (Basic Anomaly Detection Engine)

**Sprint Goal:** Implement a basic anomaly detection engine that processes logs/telemetry from the eBPF probes (introduced in Alpha v0.7) and other system components. This engine will use simple heuristics or a basic machine learning model to flag potentially suspicious patterns.  
**Release Window:** Weeks 37-38

**Key Features Introduced/Demoed (on top of v0.18):**

- A backend service (the anomaly detection engine) that ingests logs/telemetry (e.g., from eBPF probes, application logs, Kubernetes events).
- Implementation of basic anomaly detection rules or a simple ML model (e.g., trained on a small, labeled dataset of "normal" vs. "anomalous" behavior).
- The engine identifies deviations from normal patterns (e.g., unusual number of network connections, unexpected process execution, abnormal resource usage).
- When an anomaly is detected, an alert is generated (e.g., logged to a specific file, sent to a mock alerting system).
- Demonstrate the engine detecting a manually triggered anomalous event and generating an alert.

**Focus Areas from Technical Deep-Dive Documents:**

- Runtime Security Monitoring Framework for zkVote.md: Anomaly detection algorithms (BiLSTM, RBN, Decision Trees - simplified for alpha), alert classification.
- architecture.md: Runtime Security Monitoring components within the Security Architecture.

**Project Directory Structure (`zkVote_Alpha_v0.19/`):**

```plaintext
zkVote_Alpha_v0.19/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.19
├── circuits/
│   # ... (as in v0.18)
├── compliance/
│   # ... (as in v0.16)
├── contracts/
│   # ... (as in v0.18)
├── data_management/
│   # ... (as in v0.16)
├── deployment/
│   # ... (as in v0.13)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   # ... (as in v0.17)
├── security/
│   ├── confidential_computing/
│   │   # ... (as in v0.13)
│   ├── post_quantum/
│   │   # ... (as in v0.18)
│   └── runtime_monitoring/
│       ├── ebpf_probes/
│       │   # ... (as in v0.7)
│       ├── analysis_engine/ # New Folder
│       │   ├── anomaly_detector.py # Or .rs - ML model or heuristic logic
│       │   └── rule_engine_alpha.json # Simple rules for detection
│       ├── alerting/ # New Folder
│       │   └── alert_manager_stub.py # Mock alert manager
│       └── kubernetes_hardening/
│           # ... (as in v0.7)
├── src/ # Rust backend
│   ├── runtime_security_agent/
│   │   └── main.rs # Modified: To forward logs to analysis_engine
│   ├── anomaly_detection_service/ # New: Service hosting the analysis_engine
│   │   └── main.rs
│   # ... (other src folders as in v0.18)
├── sdk/
│   # ... (as in v0.18)
├── tests/
│   ├── security/
│   │   └── runtime_monitoring/ # New Folder or Enhanced
│   │       └── test_anomaly_detection.py # Test anomaly detection logic
│   # ... (other test folders as in v0.18)
└── ui/
    ├── admin_app/ # Modified: Basic dashboard to show security alerts
    │   └── src/
    │       └── SecurityAlertsDashboard.tsx # New
    # ... (other UI folders as in v0.17)
```

**Key File Descriptions/Changes for Alpha v0.19:**

- `security/runtime_monitoring/analysis_engine/anomaly_detector.py` (or .rs): Contains the core logic for anomaly detection. For alpha, this could be:
  - A set of predefined rules (e.g., "if process X makes more than Y network calls in Z seconds, flag as anomaly").
  - A simple statistical model (e.g., flagging deviations from a moving average of certain metrics).
  - A very basic pre-trained ML model (e.g., a decision tree or logistic regression).
- `security/runtime_monitoring/analysis_engine/rule_engine_alpha.json`: If rule-based, this file would store the detection rules.
- `security/runtime_monitoring/alerting/alert_manager_stub.py`: A mock service that receives alerts from the anomaly_detector and logs them or sends a basic notification.
- `src/runtime_security_agent/main.rs`: Modified to collect telemetry (e.g., from eBPF probes) and forward it to the anomaly_detection_service.
- `src/anomaly_detection_service/main.rs`: A new backend service that hosts the anomaly_detector, ingests telemetry, and triggers alerts via alert_manager_stub.
- **UI (admin_app/SecurityAlertsDashboard.tsx):** A new section in the admin UI to display any generated security alerts.
- **Testing:** Focus on feeding various telemetry patterns (normal and anomalous) to the anomaly_detector and verifying that it correctly identifies anomalies and generates alerts.

---

# Testnet Alpha v0.20: Account Abstraction (EIP-4337/7702) for Vote Casting

**Sprint Goal:** Implement basic Account Abstraction (AA) for vote casting. This allows users to submit votes using smart accounts (compliant with EIP-4337 or the upcoming EIP-7702 concepts), potentially enabling features like gas sponsoring via Paymasters or batched operations.  
**Release Window:** Weeks 39-40

**Key Features Introduced/Demoed (on top of v0.19):**

- Deployment of core EIP-4337 contracts (EntryPoint, simple Wallet, simple Paymaster) or stubs representing EIP-7702 capabilities on the testnet.
- Users can create a UserOperation that bundles a zkVote castVote transaction.
- This UserOperation is sent to the EntryPoint contract (or equivalent AA infrastructure).
- The EntryPoint contract validates the UserOperation (via the Wallet contract) and executes the vote.
- A simple Paymaster contract can be used to sponsor gas fees for vote casting UserOperations (demonstrating gasless voting for the user).
- Demonstrate casting a vote through the AA infrastructure, potentially with gas sponsorship.

**Focus Areas from Technical Deep-Dive Documents:**

- smartContractInterfaceSpecs.md: Mentions EIP-4337/7702 for Account Abstraction.
- architecture.md: Application Layer interactions, potentially how AA wallets interact with zkVote.
- requirements.md: Usability improvements that AA can bring.

**Project Directory Structure (`zkVote_Alpha_v0.20/`):**

```plaintext
zkVote_Alpha_v0.20/
├── .gitignore
├── Cargo.toml
├── LICENSE
├── package.json
├── README.md # Updated for Alpha v0.20 (Feature Complete Alpha / RC1)
├── circuits/
│   # ... (as in v0.18)
├── compliance/
│   # ... (as in v0.16)
├── contracts/
│   ├── account_abstraction/ # New Folder
│   │   ├── EntryPoint.sol # Standard EIP-4337 EntryPoint (or reference)
│   │   ├── SimpleWallet.sol # Basic AA wallet contract
│   │   └── SimplePaymaster.sol # Basic paymaster for gas sponsoring
│   ├── core/
│   │   ├── VoteProcessor.sol # May need minor adjustments if called by AA wallets
│   │   # ...
│   # ... (other contract folders as in v0.18)
├── data_management/
│   # ... (as in v0.16)
├── deployment/
│   └── kubernetes/
│       # ... (as in v0.13, potentially bundler service deployment)
├── docs/
│   └── Technical Deep-Dive/
├── scripts/
│   ├── deploy_contracts.ts # Modified: To deploy AA contracts
│   └── deploy_aa_infra.ts # New: Script specifically for AA core contracts
│   # ... (other scripts as in v0.17)
├── security/
│   # ... (as in v0.19)
├── src/ # Rust backend
│   ├── bundler_service_stub/ # New (Optional): Mock EIP-4337 bundler
│   │   └── main.rs
│   # ... (other src folders as in v0.19)
├── sdk/
│   └── typescript/
│       ├── package.json
│       ├── src/
│       │   ├── index.ts
│       │   └── zkvote_client.ts # Modified: To support creating UserOperations for voting
│       └── tsconfig.json
├── tests/
│   ├── contracts/
│   │   └── account_abstraction/ # New Folder
│   │       ├── SimpleWallet.test.ts
│   │       └── SimplePaymaster.test.ts
│   └── e2e/ # New or Enhanced
│       └── test_aa_vote_casting.ts # End-to-end test for AA voting flow
│   # ... (other test folders as in v0.19)
└── ui/
    └── voter_app/ # Modified: UI to support AA wallets and UserOps
        └── src/
            └── services/
                └── aa_zkvote.service.ts # New: Service for AA interactions
```

**Key File Descriptions/Changes for Alpha v0.20:**

- `contracts/account_abstraction/EntryPoint.sol`: The standard EIP-4337 EntryPoint contract. For alpha, you might use an existing, audited implementation.
- `contracts/account_abstraction/SimpleWallet.sol`: A basic smart contract wallet that can validate UserOperations and execute calls (like calling zkVote's VoteProcessor.submitVote).
- `contracts/account_abstraction/SimplePaymaster.sol`: A basic paymaster contract that agrees to sponsor gas for UserOperations that meet certain criteria (e.g., UserOps calling the zkVote contract).
- `src/bundler_service_stub/main.rs` (Optional): A mock EIP-4337 bundler. For alpha, you might rely on existing public bundlers on testnets or simplify this by having the SDK send UserOps directly to the EntryPoint if the testnet setup allows.
- **SDK (zkvote_client.ts):** Significantly updated to:
  - Help users construct UserOperations for casting votes.
  - Interact with the EntryPoint contract to submit UserOperations.
  - Potentially interact with a Paymaster to get gas sponsorship.
- **UI (voter_app/):** Updated to allow users to vote using an AA wallet. This might involve a different connection flow and showing if gas is sponsored.
- **Testing:** Focus on the end-to-end flow of creating a UserOperation for a vote, submitting it through the EntryPoint, having the Wallet validate it, the Paymaster sponsor gas, and the zkVote contract successfully process the vote.
