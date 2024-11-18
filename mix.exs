# mix.exs
defmodule LightningRide.MixProject do
  use Mix.Project

  def project do
    [
      app: :lightning_ride,
      version: "0.1.0",
      elixir: "~> 1.17.3",
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.6"},
      {:phoenix_live_view, "~> 0.17"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.7"},
      {:postgrex, ">= 0.0.0"},
      {:bitcoinex, "~> 0.1.7"}, # For Lightning invoice generation
      {:decimal, "~> 2.0"},
      {:geo_postgis, "~> 3.4"}, # For location handling
      {:websockex, "~> 0.4.3"}, # For Nostr relay connections
      {:jason, "~> 1.2"}, # JSON encoding/decoding
      {:k256, "~> 0.0.7"}, # For Nostr key operations
    ]
  end
end
