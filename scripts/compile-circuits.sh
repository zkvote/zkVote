#!/bin/bash
set -e

# Create output directory if it doesn't exist
mkdir -p build/circuits
mkdir -p build/verification_keys

: '
This script automates the compilation and setup process for all Circom circuits located in the "circuits" directory.

For each ".circom" file found, the script performs the following steps:
1. Compiles the circuit to generate R1CS, WASM, and SYM files, outputting them to "build/circuits".
2. Initializes a new Powers of Tau ceremony for the circuit using bn128 curve and a 12th power.
3. Contributes entropy to the Powers of Tau file for increased security.
4. Prepares the phase 2 Powers of Tau file required for Groth16 setup.
5. Runs the Groth16 setup to generate a proving key (zkey file) for the circuit.
6. Adds a second contribution of entropy to the zkey file.
7. Exports the verification key for the circuit to "build/verification_keys" as a JSON file.

Requirements:
- circom and snarkjs must be installed and available in the system PATH.
- The "build/circuits" and "build/verification_keys" directories must exist or be created before running the script.

Usage:
  bash compile-circuits.sh
'
for circuit in circuits/*.circom; do
  echo "Compiling $circuit..."

  # Get circuit name without path and extension
  CIRCUIT_NAME=$(basename "$circuit" .circom)

  # Compile the circuit
  circom "$circuit" --r1cs --wasm --sym --o build/circuits

  echo "Generating proving key for $CIRCUIT_NAME..."
  snarkjs powersoftau new bn128 12 build/circuits/"$CIRCUIT_NAME".ptau -v
  snarkjs powersoftau contribute /build/circuits/"$CIRCUIT_NAME".ptau build/circuits/"$CIRCUIT_NAME".ptau --name="First contribution" -v -e="random entropy"
  snarkjs powersoftau prepare phase2 build/circuits/"$CIRCUIT_NAME".ptau build/circuits/"$CIRCUIT_NAME".ptau2 -v
  snarkjs groth16 setup build/circuits/"$CIRCUIT_NAME".r1cs build/circuits/"$CIRCUIT_NAME".ptau2 build/circuits/"$CIRCUIT_NAME".zkey -v
  snarkjs zkey contribute build/circuits/"$CIRCUIT_NAME".zkey build/circuits/"$CIRCUIT_NAME".zkey --name="Second contribution" -v -e="more random entropy"

  # Export the verification key
  echo "Exporting verification key for $CIRCUIT_NAME..."
  snarkjs zkey export verificationkey build/circuits/"$CIRCUIT_NAME".zkey build/verification_keys/"$CIRCUIT_NAME".json
done

echo "All circuits compiled and verification keys generated successfully."
