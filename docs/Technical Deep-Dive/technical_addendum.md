**zkVote Technical Addendum**  
_Delegation‑Privacy & Cross‑Chain‑Privacy Architecture_  
**April 2025 | Ecosystem Support Program submission**

---

## 1 Purpose & scope

This addendum distils **how** zkVote implements (a) *privacy‑preserving delegation* and (b) *privacy‑preserving cross‑chain voting*, then positions those capabilities against the current state of the art.The goal is to let ESP reviewers quickly verify that zkVote’s approach is both **practical** and **differentiated**.

---

## 2 Delegation privacy – implementation details

| Layer                   | Key mechanisms                                                                                                                                 | Source                    |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| **Identity layer**      | Delegator & delegate identities are Poseidon‑hashed commitments held in a global Merkle tree (Semaphore‑style)                                 | DelegationPrivacyDeepDive |
| **Stealth addressing**  | Delegate receives voting power via a one‑time “stealth” address: `H(pk_delegate‖rand)·G` – unlinkable on‑chain                                 | DelegationPrivacyDeepDive |
| **Weight concealment**  | Voting power is a Pedersen commitment `g^w · h^r`; range checked inside the SNARK so the amount stays hidden                                   | DelegationPrivacyDeepDive |
| **Proving system**      | Groth16 (bn254) circuits: **Delegation Validity**, **Vote with Delegated Power**, **Revocation** – each ≈ 20 k–25 k constraints; proof ≈ 200 B | DelegationPrivacyDeepDive |
| **Nullifier logic**     | A delegation produces a nullifier `N = H(delegationCommitment‖voteId)`; any attempt to double‑delegate or double‑vote is rejected on‑chain     | DelegationPrivacyDeepDive |
| **Revocation & expiry** | ZK proofs for unilateral, conditional & emergency revocation; temporal constraints enforced in‑circuit                                         | DelegationPrivacyDeepDive |
| **Security model**      | UC‑style proofs of relationship/amount privacy and integrity under DDH                                                                         | DelegationPrivacyDeepDive |

### Delegation flow

1. **Create delegation** → delegator signs parameters, generates commitment + ZK proof, submits to `DelegationRegistry`.
2. **Delegate discovery** → delegate scans logs for _stealth‑address hint_, proves ownership off‑chain.
3. **Vote cast** → delegate proves _(a)_ ownership of aggregated power _(b)_ compliance with constraints, without revealing delegators or weights.
4. **Revocation / expiry** → delegator posts revocation proof; registry nullifies commitment.

---

## 3 Cross‑chain privacy – implementation details

| Component                  | Function                                                                                                                   | Implementation choice                      | Source                      |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ | --------------------------- |
| **ZK Light‑Client bridge** | Verifies remote chain block header & message commitment in‑SNARK; on‑chain verifier cost ≈ 400 k gas (L2 friendly)         | Succinct–style zkHeader → Groth16 verifier | cross-chain and aggregation |
| **Message format**         | `BridgeMessage{payload, ZK‑proof, sigs, nonce}` – opaque `payload` contains vote/delegation commitments only               |                                            | cross-chain and aggregation |
| **Global nullifier sync**  | Bridge contract relays `NULLIFIER_UPDATE` messages so a voter cannot cast on multiple chains                               |                                            | cross-chain and aggregation |
| **Result aggregation**     | Votes tallied per‑chain → batch proof → recursive proof → single final proof posted to all chains                          |                                            | cross-chain and aggregation |
| **Fallback v1 bridge**     | Threshold‑BLS multisig bridge (starknet‑style) for early deployments; privacy still preserved because payload is encrypted |                                            | cross-chain and aggregation |
| **Security properties**    | Inclusion, double‑vote prevention, bridge integrity, cross‑chain privacy theorems                                          |                                            | cross-chain and aggregation |

---

## 4 Feature‑matrix comparison

### 4.1 Delegation‑privacy matrix

| Feature                                                 | **zkVote**                        | Semaphore v4      | MACI v2 | Snapshot                                  | Snapshot + Shutter |
| ------------------------------------------------------- | --------------------------------- | ----------------- | ------- | ----------------------------------------- | ------------------ |
| Supports delegation                                     | ✔                                 | ✖ (no delegation) | ✖       | ✔ (public)                                | ✔ (public)         |
| **Relationship privacy** (hide “who delegated to whom”) | ✔ Stealth addr + ZK proof         | —                 | —       | ✖ ENS/address visible citeturn0search2 | ✖ Same             |
| **Weight privacy** (hide voting power)                  | ✔ Pedersen commitment             | —                 | —       | ✖                                         | ✖                  |
| Multi‑level delegation                                  | ✔ with depth limit & cyclic‑check | —                 | —       | ✖                                         | ✖                  |
| Private revocation / expiry                             | ✔ ZK proofs                       | —                 | —       | ✖                                         | ✖                  |
| Formal privacy proofs                                   | ✔ UC / game‑based                 | —                 | —       | —                                         | —                  |

### 4.2 Cross‑chain‑privacy matrix

| Capability                         | **zkVote**                    | LayerZero OApps     | Axelar / SnapshotX | Shutter Network (single chain) | Semaphore / MACI  |
| ---------------------------------- | ----------------------------- | ------------------- | ------------------ | ------------------------------ | ----------------- |
| Privacy‑preserving message payload | ✔ Commitments only, encrypted | ✖ Data in plaintext | ✖                  | ✔ (but single chain)           | —                 |
| Trust‑minimised bridge             | ✔ ZK light‑client (opt‑in)    | ✖ Validator set     | ✖ Validator set    | n/a                            | —                 |
| Global double‑vote prevention      | ✔ Cross‑chain nullifier sync  | ✖                   | ✖                  | —                              | —                 |
| Recursive proof aggregation        | ✔                             | ✖                   | ✖                  | ✖                              | —                 |
| Production path today              | Threshold multisig fallback   | Shipping            | Shipping           | Mainnet                        | Single‑chain only |

---

## 5 Practicality & roadmap (high‑level)

| Phase            | Deliverable                                                       | Timeframe (est.) |
| ---------------- | ----------------------------------------------------------------- | ---------------- |
| **0 (May 2025)** | MVP on Optimism: private delegation + single‑chain voting         | 3 mos            |
| **1 (Aug 2025)** | Multisig privacy bridge for Optimism ↔ Arbitrum ↔ Mainnet         | +2 mos           |
| **2 (Dec 2025)** | ZK light‑client upgrade, recursive tally proof, support 5+ chains | +4 mos           |
| **3 (2026)**     | Post‑quantum hash curves, mobile prover, DAO framework plug‑ins   | —                |

---

## 6 Key take‑aways for ESP reviewers

- **Technically feasible today** – all primitives (Poseidon, Groth16, ZK light‑clients, BLS multisig) are production‑ready.
- **Truly novel** – no existing governance system offers _both_ private delegation _and_ privacy‑preserving cross‑chain voting.
- **Public‑good alignment** – zkVote libraries, circuits & contracts will be MIT/Apache‑2 licensed from day 1, enabling downstream reuse.

We hope this clarification helps the committee evaluate zkVote’s distinct contribution to Ethereum’s privacy and governance stack.
