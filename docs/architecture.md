# High-Level Architecture Overview

## 1. Introduction

The zkVote project leverages zero-knowledge proofs (zk-SNARKs) with the Groth16 proof system to provide a private, verifiable voting system. This document outlines the overall architecture, key components, and data flows that ensure the system meets its functional, security, and privacy requirements.

## 2. System Overview

At a high level, zkVote consists of three major layers:

- **Frontend/User Interface**: Provides an accessible way for voters to cast their votes and view the verification status.
- **Zero-Knowledge Proof Infrastructure**: Encompasses the Circom circuits, witness generation, proof creation (using snarkjs), and key management. This layer ensures that each vote is valid and private.
- **Blockchain & Smart Contracts**: Deployed on a testnet (or mainnet later) to enable on-chain verification of zk-SNARK proofs. Smart contracts enforce vote integrity and prevent fraud.

## 3. Key Components

### 3.1 Frontend

- **Purpose**:
  - Enables users to input their vote.
  - Interacts with the backend to trigger the generation of the witness and proof.
  - Displays feedback on whether the vote was successfully cast and verified.
- **Technology Stack**:
  - Next.js
  - Integration with web3 libraries to interact with smart contracts.

### 3.2 Zero-Knowledge Proof Infrastructure

- **Circom Circuit**:
  - **Function**: Encodes the vote validation logic (e.g., range checks, commitment validation).
  - **Inputs**:
    - Private: Vote, randomness.
    - Public: Vote commitment.
  - **Output**: A valid proof that the vote was cast correctly without revealing its content.
- **Witness Generation & Proof Creation (snarkjs)**:
  - **Process**:
    1. Compile the Circom circuit.
    2. Generate a witness based on user inputs.
    3. Create a Groth16 proof using the proving key.
- **Key Management**:
  - Involves a trusted setup (using a powers-of-tau ceremony) to generate proving and verification keys.

### 3.3 Blockchain & Smart Contracts

- **Smart Contracts (e.g., Verifier.sol)**:
  - **Purpose**:
    - Accept the zk-SNARK proof.
    - Use the verification key to confirm the proof’s validity.
    - Ensure that each vote meets the required constraints.
  - **Deployment**:
    - Initially deployed on a testnet for thorough testing before any mainnet deployment.
- **On-Chain Data Flow**:
  - Once a vote is verified, the smart contract records the vote in a decentralized manner while preserving voter privacy.

## 4. Data Flow & Interaction

### 4.1 Vote Casting Process

1. **User Action**:
   - The voter selects their candidate via the frontend.
2. **Witness Generation**:
   - The vote and a secret randomness value are used to compute a public vote commitment.
   - A witness is generated from these inputs using the Circom circuit.
3. **Proof Generation**:
   - Using the witness and the proving key, snarkjs generates a Groth16 proof.
4. **Local Verification**:
   - The proof is verified locally to ensure correctness before on-chain submission.
5. **On-Chain Submission**:
   - The proof, along with the public vote commitment, is sent to the deployed smart contract.
6. **Smart Contract Verification**:
   - The smart contract uses the verification key to confirm the proof’s validity.
   - Once verified, the vote is recorded, ensuring integrity and preventing fraud.

### 4.2 Architectural Diagram (Conceptual)

```
                +----------------------+
                |      Frontend        |
                | (Vote Casting UI)    |
                +----------+-----------+
                                     |
                                     v
                +----------------------+
                |  Off-chain Processing |
                |                      |
                |  - Circom Circuit    |
                |  - Witness Generation|
                |  - Proof Generation  |
                +----------+-----------+
                                     |
                                     v
                +----------------------+
                |  Smart Contract      |
                | (Proof Verification) |
                +----------+-----------+
                                     |
                                     v
                +----------------------+
                |    Blockchain        |
                |   (Testnet/Mainnet)  |
                +----------------------+
```

## 5. Summary

- **Modularity**: Each layer is designed to operate independently, allowing for easier debugging, updates, and potential component upgrades.
- **Security & Privacy**: The combination of zero-knowledge proofs and on-chain verification ensures that votes remain private while still being verifiable by anyone.
- **Scalability**: By offloading the heavy cryptographic computations off-chain and only verifying proofs on-chain, the system aims to be both efficient and scalable.
