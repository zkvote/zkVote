// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; // Specify the Solidity version

// Mock verifier contract for testing purposes
contract MockVerifier {
    bool private verificationResult; // Variable to store verification result

    constructor() {
        verificationResult = true; // Initialize verification result to true
    }

    // Function to set the verification result
    function setVerificationResult(bool _result) external {
        verificationResult = _result;
    }

    // Function to verify a proof
    function verifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[1] calldata _pubSignals
    ) external view returns (bool) {
        return verificationResult;
    }
}