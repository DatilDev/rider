# config/config.exs
import Config

config :lightning_ride,
  ecto_repos: [LightningRide.Repo]

config :lightning_ride, LightningRideWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: LightningRideWeb.ErrorView],
  pubsub_server: LightningRide.PubSub,
  live_view: [signing_salt: "your-live-view-salt"]

config :lightning_ride, :lightning,
  lnd_url: System.get_env("LND_URL") || "https://localhost:8080",
  macaroon: System.get_env("LND_MACAROON")

config :lightning_ride, :nostr,
  relays: [
    "wss://relay.damus.io",
    "wss://relay.nostr.band",
    "wss://nos.lol"
  ]
config :lightning_ride, :osrm_url, ["http://router.project-osrm.org"]
