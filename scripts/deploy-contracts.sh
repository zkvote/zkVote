#!/bin/bash
# -----------------------------------------------------------------------------
# Script Name: deploy-contracts.sh
#
# Description:
#   This script automates the deployment of smart contracts using Hardhat.
#   It supports multiple environments (development, staging, production) and
#   can optionally verify quantum-resistant (PQC) signatures before deployment.
#   After deployment, it verifies contracts on Etherscan for non-local networks.
#
# Environment Variables:
#   - PQC_VERIFY: Set to "true" to enable quantum-resistant signature verification.
#   - ENVIRONMENT: Specifies the deployment environment. Accepted values are:
#       - "development": Deploys to localhost.
#       - "staging": Deploys to Sepolia testnet.
#       - "production": Deploys to Ethereum mainnet.
#
# Usage:
#   ENVIRONMENT=staging PQC_VERIFY=true ./deploy-contracts.sh
#
# Requirements:
#   - Node.js and npm installed.
#   - Hardhat and required dependencies installed.
#   - pqc-verify.js script present for PQC verification.
#
# -----------------------------------------------------------------------------
set -e

# Verify PQC signatures if enabled
if [ "$PQC_VERIFY" = "true" ]; then
  echo "Verifying quantum-resistant signatures..."
  node pqc-verify.js
fi

# This script sets the NETWORK variable based on the value of the ENVIRONMENT variable.
# Supported ENVIRONMENT values:
#   - "development": sets NETWORK to "localhost"
#   - "staging": sets NETWORK to "sepolia"
#   - "production": sets NETWORK to "mainnet"
# If ENVIRONMENT is not one of the above, the script prints an error and exits.
NETWORK="localhost"
case "$ENVIRONMENT" in
  "development")
    NETWORK="localhost"
    ;;
  "staging")
    NETWORK="sepolia"
    ;;
  "production")
    NETWORK="mainnet"
    ;;
  *)
    echo "Unknown environment: $ENVIRONMENT"
    exit 1
    ;;
esac

# This script deploys smart contracts to the specified blockchain network.
# Usage:
#   Set the NETWORK environment variable to the desired network name.
#   Then run this script to deploy contracts using Hardhat.
#   Example:
#     NETWORK=goerli ./deploy-contracts.sh
#
# The script performs the following steps:
#   1. Prints a message indicating the target deployment network.
#   2. Executes the Hardhat deployment script (deploy.js) on the specified network.
echo "Deploying contracts to $NETWORK..."
npx hardhat run scripts/deploy.js --network "$NETWORK"

# Verify contracts on Etherscan if not local network
if [ "$NETWORK" != "localhost" ]; then
  echo "Verifying contracts on Etherscan..."
  npx hardhat verify-contracts --network "$NETWORK"
fi

echo "Deployment completed successfully."
