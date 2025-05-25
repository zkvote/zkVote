/**
 * Validates the presence of required environment variables for application configuration.
 *
 * Loads environment variables from a file based on the current NODE_ENV, or falls back to process.env.
 * Checks for the existence of all variables listed in `requiredVariables`.
 * If any required variable is missing, logs an error and exits the process.
 * Otherwise, logs a success message.
 *
 * @module validate-config
 *
 * @requires dotenv
 * @requires fs
 * @requires path
 *
 * @example
 * // Run this script before starting the application to ensure all configuration is present.
 * node scripts/validate-config.js
 */
const dotenv = require("dotenv");
const fs = require("fs");
const path = require("path");

// Load environment variables
const envFile = `.env.${process.env.NODE_ENV || "development"}`;
const envPath = path.resolve(process.cwd(), envFile);

if (fs.existsSync(envPath)) {
  dotenv.config({ path: envPath });
} else {
  console.warn(
    `Warning: Environment file ${envFile} not found, using process.env`
  );
}

// Define required environment variables
/**
 * An array of environment variable names required for application configuration.
 *
 * @type {string[]}
 * @property {string} DATABASE_URL - The URL for the database connection.
 * @property {string} REDIS_URL - The URL for the Redis instance.
 * @property {string} JWT_SECRET - The secret key used for JWT authentication.
 * @property {string} INFURA_API_KEY - The API key for Infura blockchain access.
 * @property {string} BLOCKCHAIN_RPC - The RPC endpoint for blockchain communication.
 */
const requiredVariables = [
  "DATABASE_URL",
  "REDIS_URL",
  "JWT_SECRET",
  "INFURA_API_KEY",
  "BLOCKCHAIN_RPC",
];

// Validate required environment variables
const missingVariables = requiredVariables.filter(
  (varName) => !process.env[varName]
);

if (missingVariables.length > 0) {
  console.error("Error: Missing required environment variables:");
  missingVariables.forEach((varName) => console.error(`- ${varName}`));
  process.exit(1);
} else {
  console.log(
    "Configuration validation passed. All required environment variables are set."
  );
}
