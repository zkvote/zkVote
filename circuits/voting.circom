pragma circom 2.2.1; //The circom circuit compiler version being used

// Including the necessary libraries
include "circomlib/circuits/poseidon.circom"; // for poseidon hash
include "circomlib/circuits/comparators.circom"; // for less than checker

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
    component eq = IsEqual();
    eq.in[0] <== voteCommitment;
    eq.in[1] <== poseidon.out;
    eq.out === 1;

    // Range check to ensure that the vote is a valid candidate number.
    // The valid votes are going to be in the range [1, nCandidates]
    // This also ensures that the vote is non-zero
    // We will first check whether the vote is greater than 0 by checking whether 0 is less than vote
    component minCheck = LessThan(32); // 32 bits is the size of integer we will checking
    minCheck.in[0] <== 0;
    minCheck.in[1] <== vote;
    minCheck.out === 1;

    // Now we will check whether the nCandidates is greater than vote by checking whether vote vote is less than nCandidates+1 (to include nCandidates as well)
    component maxCheck = LessThan(32);
    maxCheck.in[0] <== vote;
    maxCheck.in[1] <== nCandidates+1;
    maxCheck.out === 1;
}

component main {public [voteCommitment]} = Voting(3); // Assuming 3 candidates



