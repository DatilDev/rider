# config/dev.exs
import Config

config :lightning_ride, LightningRide.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "lightning_ride_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
