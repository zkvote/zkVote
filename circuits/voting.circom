pragma circom 2.2.1; //The circom circuit compiler version being used

// Including the necessary libraries
include "circomlib/circuits/poseidon.circom"; // for poseidon hash
include "circomlib/circuits/less_than.circom"; // for less than checker

template Voting(nCandidates) {
    // Private inputs of the circuit
    signal input vote; // the candidate ID to vote for
    signal input randomness; // a secret random value to hide the actual vote in public commitment

    // Public input of the circuit
    signal input voteCommitment; // a public hash computed from the vote and randomness

    // compute Poseidon hash for commitment verification
    component poseidon = Poseidon(2);
    poseidon.inputs[0] <== vote;
    poseidon.inputs[1] <== randomness;

    // Checking that the computed Poseidon hash matches the public voteCommitment
    voteCommitment == poseidon.out;

    // Check if the vote is non-zero (no candidate has ID 0)
    vote != 0;

    // Range check to ensure that the vote is a valid candidate number.
    // The valid votes are going to be in the range [1, nCandidates]
    component rangeCheck = LessThan(32); // bit-length to be used
    rangeCheck.in[0] <== vote;
    rangeCheck.in[1] <== nCandidates+1; // this will check the range from [1, nCandidates]
    rangeCheck.out == 1; // Checking if the vote is in the range
}

component main = Voting(3); // Assuming 3 candidates



