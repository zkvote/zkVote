mod config;

use config::Settings;
use tracing::{info, instrument};
use tracing_subscriber::prelude::*;

/// The main entry point for the zkVote backend application.
#[tokio::main]
#[instrument]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let filter_layer = tracing_subscriber::EnvFilter::try_from_default_env()
        .unwrap_or_else(|_| tracing_subscriber::EnvFilter::new("info"));

    let fmt_layer = tracing_subscriber::fmt::layer()
        .with_target(true)
        .with_level(true);

    let registry = tracing_subscriber::registry()
        .with(filter_layer);


    // Choose compact or JSON log format based on whether output is a terminal, enabling better readability for humans or machines.
    if atty::is(atty::Stream::Stdout) {
        registry.with(fmt_layer.compact()).init();
    } else {
        registry.with(fmt_layer.json()).init();
    }

    info!("Logging initialized.");

    let settings = Settings::new().expect("Failed to load configuration");

    if let Err(e) = config::validate(&settings) {
        eprintln!("Configuration validation failed: {}", e);
        std::process::exit(1);
    }

    info!(
        port = settings.backend_port,
        rpc_url = %settings.testnet_rpc_url,
        db_url_host = settings.database_url.split('@').last().unwrap_or("unknown"),
        "Backend starting up with loaded configuration settings."
    );
    tracing::debug!(config = ?settings, "Full configuration settings loaded.");

    Ok(())
}
