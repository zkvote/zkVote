# Circuit Design

## 1. What Inputs Do We Need?

### Private Inputs:

- **vote**: This is the candidate ID the voter chooses. We assume it’s a number (say, 1 for candidate A, 2 for candidate B, etc.).
- **randomness**: A secret random value used to hide the actual vote in the public commitment.

### Public Inputs:

- **voteCommitment**: A public hash (or commitment) that is computed from the vote and the randomness. This lets others verify that the vote meets the constraints without revealing the vote itself.

## 2. Core Components of the Circuit

### a. Commitment Component:

- **Use a cryptographic hash function** (like Poseidon) to compute a commitment from the private inputs.
- **Constraint**: The circuit will enforce that the computed hash equals the provided voteCommitment.
- **Purpose**: This hides the actual vote while still committing to it, ensuring privacy.

### b. Range Check Component:

- **Goal**: Ensure that the vote is a valid candidate (e.g., if you have 3 candidates, the vote should be 1, 2, or 3).
- **How**:
  - You can use a component like LessThan from circomlib to check that vote is less than or equal to the number of candidates. For example, if there are 3 candidates, check that vote < 4.
  - Also enforce that vote isn’t zero (ensuring it’s at least 1).

## 3. Enforcing the Security and Validity Constraints

### Commitment Equality:

The circuit computes `hash(vote, randomness)` and then enforces that:

```
publicVoteCommitment === computedHash
```

This prevents any tampering with the vote after it’s committed.

### Vote Range Validation:

Using a range-check, you ensure that:

```
vote < nCandidates + 1
```

This way, if a voter tries to input a number outside the allowed candidates, the proof will fail.

### Non-Zero Vote:

Implicitly, by ensuring `vote < nCandidates + 1` and knowing that votes are positive integers, you enforce that the vote isn’t zero. You can also add an explicit check if needed.

## How This Circuit Meets Our Requirements & Mitigates Threats

- **Privacy**: The use of a hash (with randomness) means that even though the voteCommitment is public, no one can deduce the vote itself.
- **Correctness & Validity**: The range check ensures that only valid candidate IDs (e.g., 1 to 3) are accepted. Any invalid vote will break the proof, stopping any malicious vote manipulation.
- **Integrity**: Tying the commitment to both the vote and the randomness ensures that once the vote is committed, it cannot be altered without invalidating the proof.
- **Defense Against Malicious Activity**: By enforcing strict constraints on inputs, we mitigate risks like double-voting or submitting out-of-range candidate IDs.
