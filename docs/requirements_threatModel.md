# Project Requirements

## Functional Requirements

- **Vote Casting & Validation:**

  - **Input Handling:** Each voter submits a vote along with any necessary secret data (e.g., randomness for commitments).
  - **Constraint Enforcement:** The circuit (written in Circom) must enforce that a vote is valid (e.g., ensuring the vote is within allowed options or candidate IDs).
  - **Zero-Knowledge Proof Generation:** Voters generate a Groth16 proof that they followed the rules without revealing their actual vote.
  - **On-Chain Verification:** A deployed smart contract (e.g., Verifier.sol) verifies the proof against a public verification key.

- **Key Management & Setup:**

  - **Trusted Setup:** Perform a powers-of-tau ceremony to generate a CRS, followed by the Groth16 setup to create proving and verification keys.
  - **Key Storage:** Securely store the proving and verification keys for both local and on-chain use.

- **Workflow Integration:**
  - **Witness Generation:** From user inputs, generate a witness file that is used for proof creation.
  - **Proof Verification:** Provide a mechanism (both off-chain via snarkjs and on-chain via a smart contract) to verify that each proof is valid.
  - **User Interaction (Optional Frontend):** Build a basic UI to allow voters to submit their vote and view verification results.

## Non-Functional Requirements

- **Privacy:**

  - Ensure that no sensitive vote information leaks through the proof. The zk-SNARKs should hide the vote content while proving its validity.

- **Security & Integrity:**

  - Prevent fraudulent or double voting.
  - Ensure that even if all on-chain data is public, the vote remains confidential.

- **Scalability & Performance:**

  - Design the system to handle the expected number of voters. Note that generating Groth16 proofs can be computationally heavy, so consider off-chain computation where feasible.
  - Smart contract verification should be optimized to reduce gas costs and avoid network congestion.

- **Transparency & Auditing:**

  - All public parameters, keys (as long as they are non-sensitive), and the process should be auditable.
  - Documentation of the design and processes for external reviews is important.

- **Interoperability:**
  - Ensure that the system can be deployed on a testnet (or mainnet later) with proper integration between the zero-knowledge proof components and the blockchain components.

# Threat Model

When building a private voting system with zk-SNARKs, you need to consider a variety of potential threats:

## Adversaries & Their Capabilities

- **Malicious Voters:**

  - Could try to submit multiple votes or malformed proofs.
  - May attempt to reverse-engineer the circuit to glean information about other votes.

- **Eavesdroppers / Network Adversaries:**

  - Since blockchain transactions are public, adversaries can see all the data on-chain. However, thanks to zero-knowledge, they should not learn any private vote details.
  - They might try to link on-chain proof submissions to specific voters if metadata isn’t carefully handled.

- **Compromised or Malicious Setup Participants:**

  - During the trusted setup phase (powers-of-tau and Groth16 setup), if any participant is malicious and the ceremony is not sufficiently robust, the entire system’s security could be compromised.
  - A compromised trusted setup can lead to the possibility of creating false proofs.

- **Smart Contract Vulnerabilities:**
  - Attackers might target bugs in the smart contract verification logic.
  - Denial of Service (DoS) attacks could be attempted to disrupt vote casting or tallying.

## Security Assumptions & Mitigations

- **Zero-Knowledge Assumptions:**

  - Rely on the cryptographic soundness of the Groth16 protocol.
  - Ensure that the circuit design doesn’t inadvertently leak any vote information.

- **Trusted Setup Integrity:**

  - Use a multi-party computation (MPC) for the trusted setup if possible to minimize the risk of a single point of failure.
  - Document and, if possible, make the setup process transparent.

- **Data Integrity & Non-Repudiation:**

  - Implement mechanisms to ensure that each vote can only be cast once (e.g., using unique identifiers or a registry of votes).
  - Use cryptographic signatures or other authentication methods to tie a vote to a legitimate voter (depending on your voter registration process).

- **Network & On-Chain Security:**

  - Harden your smart contracts against re-entrancy and other common vulnerabilities.
  - Consider using formal verification tools or audits to ensure the contract behaves as expected.

- **Operational Security:**
  - Securely manage and store cryptographic keys.
  - Ensure that the frontend does not leak any sensitive information during the vote casting process.
