# zkVote Threshold Cryptography \& MPC Architecture

Document ID: ZKV-THCR-2025-002
Version: 1.0
Date: May 17, 2025

## Table of Contents

1. Introduction
2. FROST v2 Implementation Details
3. Distributed Key Generation Protocols
4. HSM Integration Specifications
5. Cross-Device Recovery Protocol
6. Security Considerations
7. Performance Analysis
8. Implementation Roadmap
9. Appendices

## 1. Introduction

This document specifies the threshold cryptography and multi-party computation (MPC) architecture for the zkVote protocol. As a privacy-preserving governance infrastructure, zkVote leverages advanced threshold cryptography to distribute trust across multiple participants while maintaining the highest security standards.

The architecture described herein enables critical security features:

- Key management without single points of failure
- Distributed signature generation without exposing private key material
- Threshold-based authorization for governance operations
- Secure key recovery mechanisms

This implementation is designed to complement zkVote's zero-knowledge proof system while providing additional security guarantees for critical governance operations.

## 2. FROST v2 Implementation Details

### 2.1 Overview

zkVote implements the FROST (Flexible Round-Optimized Schnorr Threshold signatures) protocol v2.1.0 as its primary threshold signature scheme. FROST enables efficient, secure distributed signing with minimal communication rounds, making it ideal for governance applications where participants may be geographically dispersed and operating asynchronously.

### 2.2 Core Functionality

The FROST implementation in zkVote includes:

- **Two-round signing protocol** - Optimized for network efficiency while preventing forgery attacks
- **Threshold capabilities** - Support for t-of-n threshold policies (requires t participants to sign from a total of n key holders)
- **Schnorr signature compatibility** - Output signatures are standard Schnorr signatures, indistinguishable from single-party signatures
- **Multiple curve support** - Implementations on secp256k1, secp256k1-tr (Taproot), ed25519, p256, and ristretto255

### 2.3 Implementation Components

zkVote integrates the following FROST v2.1.0 components:

```
Component            Purpose                                        Integration Point
---------------      -------------------------------------         ------------------
frost-core           Core cryptographic primitives                 Protocol foundation
frost-secp256k1      Main signature implementation                 Ethereum compatibility
frost-secp256k1-tr   Taproot-compatible signatures                 Cross-chain signatures
frost-ristretto255   Alternative curve implementation              Enhanced privacy features
frost-rerandomized   Rerandomized signature variant               Advanced security features
```

### 2.4 Key Features from FROST v2.1.0

The implementation incorporates the following capabilities from the latest FROST release:

#### 2.4.1 Participant Identification

The system can identify the specific participant who sent an invalid secret share during the third DKG round using the `frost_core::Error<C>::culprit()` functionality, enhancing accountability in the key generation process.

#### 2.4.2 Taproot Compatibility

Support for Bitcoin Taproot (BIP340/BIP341) compatible signatures through the frost-secp256k1-tr crate, enabling cross-chain verification and compatibility with zero-knowledge asset protocols.

#### 2.4.3 Share Refreshing

Implementation of the share refreshing protocol that allows participants to refresh their key shares periodically or remove participants without regenerating the entire key, using `frost_core::keys::refresh::refresh_dkg_{part1,part2,shares}()` functions.

#### 2.4.4 Serializable Secret Packages

The `frost_core::keys::dkg::part{1,2}::SecretPackage` objects are serializable, enabling asynchronous distributed key generation across participants with intermittent connectivity.

### 2.5 Integration Architecture

```solidity
// Sample integration with zkVote protocol
contract ThresholdVoteVerifier {
    // FROST signature verification for governance proposals
    function verifyThresholdSignature(
        bytes32 messageHash,
        bytes memory signature,
        bytes32 aggregatePublicKey
    ) public view returns (bool) {
        // Signature verification using the appropriate curve
        return FROSTVerifier.verify(messageHash, signature, aggregatePublicKey);
    }
}
```

## 3. Distributed Key Generation Protocols

### 3.1 Protocol Selection

zkVote implements multiple distributed key generation (DKG) approaches to accommodate different security models and operational requirements:

1. **FROST DKG** - Primary protocol based on the FROST paper
2. **Trusted Dealer** - Optional simplified setup for initial deployments
3. **Pedersen DKG** - Alternative with different security guarantees

### 3.2 FROST DKG Implementation

The primary DKG protocol follows a three-round process:

#### 3.2.1 Round 1: Secret Sharing

```
function dkg_part1(
    num_participants: u16,
    threshold: u16,
    participant_index: u16,
    randomness_source: &mut R
) -> (SecretPackage, Vec<EncryptedSecretShare>)
```

In this round:

- Each participant generates a random polynomial of degree threshold - 1
- Participant computes encrypted secret shares for all other participants
- Participant broadcasts commitment to their polynomial coefficients

#### 3.2.2 Round 2: Share Verification

```
function dkg_part2(
    secret_package: SecretPackage,
    encrypted_secret_shares: Vec<Vec<EncryptedSecretShare>>
) -> (SecretPackage, Vec<SecretShare>)
```

In this round:

- Each participant verifies received shares against published commitments
- Participants decrypt their received shares
- Invalid shares are identified using zero-knowledge proofs

#### 3.2.3 Round 3: Key Finalization

```
function dkg_part3(
    secret_package: SecretPackage,
    secret_shares: Vec<SecretShare>
) -> KeyPackage
```

In this round:

- Participant key packages are finalized
- Each participant now holds a share of the distributed key
- Group public key is computed and verified by all participants

### 3.3 Share Refreshing Protocol

zkVote implements share refreshing to allow periodic security updates without changing the underlying key:

#### 3.3.1 Refresh Protocol Flow

1. **Initialization** - Participants agree to refresh with threshold t
2. **Share Generation** - Each participant generates update shares for others
3. **Share Distribution** - Encrypted shares are distributed with ZK proofs
4. **Share Aggregation** - Participants combine updates to form new shares
5. **Verification** - Group public key remains unchanged

#### 3.3.2 Participant Removal

The refresh protocol supports secure participant removal:

```
function refresh_dkg_part1(
    current_key_package: KeyPackage,
    target_participants: Vec<ParticipantId>,
    randomness_source: &mut R
) -> (RefreshSecretPackage, Vec<RefreshSecretShare>)
```

### 3.4 Security Properties

The DKG protocols provide the following security guarantees:

- **Secrecy** - The master secret remains unknown to any individual participant
- **Correctness** - The resulting distributed key is valid for the signature scheme
- **Robustness** - Protocol completes even if up to t-1 participants are malicious
- **Verifiability** - Participants can verify the correctness of all operations
- **Forward security** - Refreshed shares cannot be combined with old shares

## 4. HSM Integration Specifications

### 4.1 HSM Security Model

zkVote's threshold cryptography architecture supports integration with Hardware Security Modules (HSMs) to provide enhanced protection for key shares.

#### 4.1.1 Supported HSM Types

- **FIPS 140-2 Level 3+** certified hardware devices
- **Cloud HSMs** (AWS CloudHSM, Google Cloud HSM, Azure Key Vault)
- **Virtual HSMs** for development and testing environments

#### 4.1.2 Security Boundaries

```
+----------------------------+    +----------------------------+
|                            |    |                            |
|  zkVote Governance App     |    |  zkVote Protocol Contract |
|                            |    |                            |
+-----------+----------------+    +-------------+--------------+
            |                                   |
            |                                   |
            v                                   v
+----------------------------+    +----------------------------+
|                            |    |                            |
|  Threshold Signature       |    |  Signature Verification    |
|  Coordination Service      |    |  Module                    |
|                            |    |                            |
+-----------+----------------+    +----------------------------+
            |
            |
+-----------v----------------+
|                            |
|  HSM Interface Layer       |
|                            |
+--+-------------+----------+--+
   |             |             |
   v             v             v
+-----+       +-----+       +-----+
| HSM |       | HSM |       | HSM |
|  1  |       |  2  |       |  n  |
+-----+       +-----+       +-----+
```

### 4.2 Integration Interface

#### 4.2.1 PKCS\#11 Integration

The standard interface for HSM integration uses PKCS\#11 with the following requirements:

- **Minimum PKCS\#11 version**: 2.40
- **Required mechanisms**: CKM_ECDSA, CKM_EC_KEY_PAIR_GEN, CKM_SHA256
- **Key attributes**: CKA_SIGN, CKA_VERIFY, CKA_EXTRACTABLE=false

```rust
// Sample PKCS#11 interface for HSM operations
struct HSMThresholdSigner {
    session: Pkcs11Session,
    key_handle: ObjectHandle,

    fn sign_share(&self, message_hash: &[u8]) -> Result<Signature, HsmError>;
    fn get_public_key(&self) -> Result<PublicKey, HsmError>;
    fn generate_commitment(&self, nonce: &[u8]) -> Result<Commitment, HsmError>;
}
```

#### 4.2.2 Key Operations

The following operations are performed within the HSM boundary:

- **Key share generation** - During DKG, participant polynomial coefficients
- **Nonce generation** - Critical for FROST signature security
- **Commitment calculation** - First round of signing protocol
- **Share signature calculation** - Second round of signing protocol

### 4.3 Attestation Protocol

HSM attestation ensures the integrity of the threshold signing environment:

1. **Device attestation** - HSM provides signed firmware measurement
2. **Key attestation** - Proof that keys are generated and stored within HSM
3. **Operation attestation** - Evidence that signing occurred within HSM boundary

### 4.4 Performance Considerations

HSM integration introduces performance tradeoffs:

| Operation | Software (ms) | HSM (ms) | Overhead Factor |
| :-------- | :------------ | :------- | :-------------- |
| Key Gen   | 85            | 320      | 3.8x            |
| Commit    | 12            | 45       | 3.75x           |
| Sign      | 18            | 65       | 3.6x            |

## 5. Cross-Device Recovery Protocol

### 5.1 Recovery Model

zkVote implements a cross-device recovery protocol based on the Repairable Threshold Scheme (RTS) to allow participants to recover lost shares without compromising security.

### 5.2 Recovery Protocol Phases

#### 5.2.1 Setup Phase

During DKG, additional recovery data is generated:

```
function generate_recovery_data(
    key_share: KeyShare,
    recovery_threshold: u16,
    participant_indexes: Vec<u16>
) -> Vec<EncryptedRecoveryPackage>
```

This generates encrypted recovery packages that can later be used to reconstruct a lost share.

#### 5.2.2 Recovery Initiation

When a participant loses access to their key share:

```
function initiate_recovery(
    participant_id: u16,
    authentication_proof: AuthProof,
    recovery_coordinator: &Coordinator
) -> RecoverySession
```

The authentication proof ensures only the legitimate participant can initiate recovery.

#### 5.2.3 Share Reconstruction

Recovery proceeds through a secure MPC protocol:

1. **Recovery request** - Authenticated participant broadcasts recovery request
2. **Helper commitment** - t helpers commit to using their recovery packages
3. **Partial recovery generation** - Each helper generates a partial recovery share
4. **Share reconstruction** - Partial recoveries are combined to reconstruct the share

```rust
// Recovery share generation (performed by each helper)
fn generate_recovery_share(
    recovery_session: &RecoverySession,
    recovery_package: &EncryptedRecoveryPackage,
    helper_key: &HelperKey
) -> RecoveryShare
```

### 5.3 Device Migration Protocol

For secure migration of key shares between devices:

#### 5.3.1 Authorization

```
function authorize_device_migration(
    current_device_signature: Signature,
    new_device_public_key: PublicKey,
    expiry_time: Timestamp
) -> MigrationAuthorization
```

#### 5.3.2 Share Transfer

```
function execute_migration(
    migration_authorization: MigrationAuthorization,
    encrypted_key_package: EncryptedKeyPackage,
    new_device_proof: AuthProof
) -> Result<KeyPackage, MigrationError>
```

### 5.4 Security Analysis

The recovery protocol maintains these security properties:

- **Threshold security** - Requires t participants to cooperate for recovery
- **Forward security** - Recovery does not expose historical keys
- **Authentication** - Only legitimate share owners can initiate recovery
- **Auditability** - All recovery operations are logged and verifiable
- **Zero-knowledge** - Helpers learn nothing about the recovered share

## 6. Security Considerations

### 6.1 Threat Model

The threshold cryptography implementation considers the following threat vectors:

- **Participant compromise** - Up to t-1 participants may be compromised
- **Network adversaries** - Man-in-the-middle and eavesdropping attacks
- **Side-channel attacks** - Timing and power analysis against HSMs
- **Cryptanalytic advances** - Including quantum computing threats

### 6.2 Defense-in-Depth Measures

The architecture implements multiple layers of defense:

1. **Protocol-level security** - Threshold cryptography fundamentals
2. **Implementation security** - Constant-time operations, memory safety
3. **Operational security** - Key refresh, participant rotation
4. **Hardware security** - HSM integration and attestation
5. **Quantum readiness** - Migration path to post-quantum primitives

### 6.3 Formal Verification

Critical components have undergone formal verification:

- **Protocol verification** - Using symbolic verification tools
- **Implementation verification** - For constant-time operations
- **State machine verification** - For protocol transitions

## 7. Performance Analysis

### 7.1 Benchmarks

Performance metrics across different thresholds and participant counts:

| Configuration | Key Gen (s) | Sign Round 1 (ms) | Sign Round 2 (ms) | Verification (ms) |
| :------------ | :---------- | :---------------- | :---------------- | :---------------- |
| 2-of-3        | 1.2         | 45                | 65                | 4                 |
| 3-of-5        | 1.8         | 48                | 72                | 4                 |
| 5-of-9        | 3.2         | 52                | 85                | 4                 |
| 10-of-15      | 6.5         | 65                | 110               | 4                 |

### 7.2 Optimization Strategies

The implementation includes several optimizations:

- **Batch verification** - For validating multiple signatures
- **Precomputation** - For accelerating commitment generation
- **Hardware acceleration** - For compatible environments
- **Concurrent processing** - For distributed operations

## 8. Implementation Roadmap

The threshold cryptography components will be deployed according to the following roadmap:

### 8.1 Phase 1 (Q2-Q3 2025)

- Core FROST v2.1.0 integration with zkVote protocol
- Basic HSM support for enterprise deployments
- Initial DKG implementation for governance committees

### 8.2 Phase 2 (Q3-Q4 2025)

- Enhanced HSM integration with attestation
- Cross-device recovery protocol implementation
- Performance optimizations for scaling governance

### 8.3 Phase 3 (Q1-Q2 2026)

- Post-quantum migration for threshold cryptography
- Advanced recovery features with social verification
- Hardware wallet integrations for consumer governance

## 9. Appendices

### 9.1 FROST Protocol Specification

Detailed cryptographic specifications for the FROST protocol implementation.

### 9.2 HSM Compatibility Matrix

List of tested HSM models with compatibility notes and performance characteristics.

### 9.3 Reference Implementation

Links to reference code repositories and integration examples.

### 9.4 Cryptographic Primitives

Detailed specifications of the underlying cryptographic building blocks.

### 9.5 Formal Security Proofs

Mathematical security proofs for the threshold cryptography implementation.
