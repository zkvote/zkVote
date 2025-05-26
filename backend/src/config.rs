use serde::Deserialize;
use std::env;

#[derive(Debug, Deserialize, Clone)]
/// Configuration settings for the zkVote application.
///
/// # Fields
/// - `backend_port`: The port number on which the backend server will listen.
/// - `database_url`: The URL for connecting to the application's database.
/// - `testnet_rpc_url`: The RPC URL for connecting to the testnet blockchain.
/// - `deployer_private_key`: (Optional) The private key used for contract deployment. If not provided, deployment features may be disabled.
/// - `circuit_vkey_path`: The file path to the zero-knowledge circuit verification key.
/// - `circuit_wasm_path`: The file path to the zero-knowledge circuit WebAssembly binary.
///
/// Note: Logging configuration is handled directly by `tracing_subscriber` via the `RUST_LOG` environment variable.
pub struct Settings {
    // Logging - RUST_LOG will be handled by tracing_subscriber directly

    pub backend_port: u16, // Port for the backend server
    pub database_url: String, // Database connection URL
    pub testnet_rpc_url: String, // RPC URL for the testnet blockchain

    // Optional private key for contract deployment
    #[serde(default)] // Default to None if not provided
    pub deployer_private_key: Option<String>, // Private key for contract deployment

    // ZK circuit configuration
    pub circuit_vkey_path: String, // Path to the circuit verification key
    pub circuit_wasm_path: String, // Path to the circuit WebAssembly binary
}

/// Creates a new `Settings` instance by loading configuration from environment variables.
///
/// # Environment
/// - Determines the environment from the `RUST_ENV` variable, defaulting to `"development"` if not set.
/// - Loads configuration from environment variables with the `APP_` prefix and from default environment variables.
/// - Ignores empty environment variables.
impl Settings {
  pub fn new() -> Result<Self, config::ConfigError> {
    // Determine the environment. Default to "development" if not set.
    let environment = env::var("RUST_ENV").unwrap_or_else(|_| "development".into());

    // In a CI environment or for Docker, .env files might not be present.
    // dotenvy::dotenv().ok(); // Load .env file if present, ignore if not.

    let s = config::Config::builder()
      .add_source(config::Environment::with_prefix("APP").separator("_"))
      .add_source(config::Environment::default().separator("_").ignore_empty(true))
      .build()?;

    s.try_deserialize()
  }
}


/// Validates the application settings to ensure all required fields are properly set.
pub fn validate(settings: &Settings) -> Result<(), String> {
    if settings.backend_port == 0 {
        return Err("Invalid backend port".into());
    }
    if settings.database_url.is_empty() {
        return Err("Database URL is required".into());
    }
    if settings.testnet_rpc_url.is_empty() {
        return Err("Testnet RPC URL is required".into());
    }
    if settings.circuit_vkey_path.is_empty() {
        return Err("Circuit verification key path is required".into());
    }
    if settings.circuit_wasm_path.is_empty() {
        return Err("Circuit WASM path is required".into());
    }
    Ok(())
}
