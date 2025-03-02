# zkVote

A private voting system which uses ZKP to prove that vote is valid without revealing the vote or voter's identity.

## Executive Summary

### Project Overview

zkVote is a private voting system that leverages zero-knowledge proofs (zk-SNARKs) to ensure vote validity without revealing the vote or the voter's identity. The project aims to provide a secure, verifiable, and privacy-preserving voting mechanism suitable for various use cases, including elections and surveys.

### Key Features

- **Vote Casting & Validation**: Ensures that each vote is valid and adheres to predefined constraints without revealing the vote's content.
- **Key Management**: Implements a trusted setup for generating and securely storing proving and verification keys.
- **Zero-Knowledge Proof Generation**: Utilizes the Groth16 proof system to create zk-SNARK proofs.
- **On-Chain Verification**: Deploys smart contracts to verify proofs on a blockchain.
- **Frontend Interface**: Provides a user-friendly interface for voters to cast their votes and view verification results.

### Goals

- **Privacy**: Protect voter anonymity and prevent vote content from being disclosed.
- **Security**: Ensure the integrity of the voting process and prevent fraudulent activities.
- **Scalability**: Design the system to handle a large number of voters efficiently.
- **Transparency**: Allow public auditing of the voting process while maintaining privacy.

### Conclusion

zkVote represents a significant advancement in secure and private voting systems, combining cutting-edge cryptographic techniques with practical implementation. The project documentation provides a comprehensive guide to understanding and utilizing the system, making it an excellent addition to any portfolio or resume.

## User Guide

### Requirements

- Docker
- Docker Compose

### Installation

1. Clone the repository:

   ```sh
   git clone https://github.com/Cass402/zkVote.git
   cd zkVote
   ```

2. Build the Docker images:

   ```sh
   docker-compose build
   ```

3. Start the containers:
   ```sh
   docker-compose up
   ```

### Usage

1. Access the frontend:

   ```sh
   http://localhost:3000
   ```

2. Interact with the application to cast and verify votes.

### Docker Setup

- The `Dockerfile` defines the image for the application.
- The `docker-compose.yml` file sets up the necessary services including the frontend, backend, and any other dependencies.

## Examples and Use Cases

### Example 1: Basic Voting

1. Access the voting interface.
2. Select a candidate.
3. Submit the vote.
4. View the proof verification result.

### Example 2: Verifying a Vote

1. After submitting a vote, a zero-knowledge proof is generated.
2. The proof is verified on-chain using a smart contract.
3. The vote remains private while the proof ensures its validity.

### Use Case: Secure Elections

zkVote can be used in secure elections where voter anonymity and vote integrity are crucial. By leveraging zero-knowledge proofs, the system ensures that votes are valid without revealing their content, providing a secure and private voting experience.

## Additional Documentation

- [Project Requirements](docs/requirements_threatModel.md)
- [Circuit Design](docs/circuit_design.md)
- [Architecture Overview](docs/architecture.md)
- [Technical Specifications](docs/technical_specifications.md)

## Testing and Coverage

_Documentation for testing and coverage will be added upon project completion._
