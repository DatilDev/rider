# lib/lightning_ride/nostr/client.ex
defmodule LightningRide.Nostr.Client do
  use WebSockex
  alias LightningRide.Nostr.Event

  @relays [
    "wss://relay.damus.io",
    "wss://relay.nostr.band",
    "wss://nos.lol"
  ]

  def start_link do
    # Connect to multiple relays
    Enum.map(@relays, fn relay_url ->
      WebSockex.start_link(relay_url, __MODULE__, %{})
    end)
  end

  def handle_frame({:text, msg}, state) do
    case Jason.decode(msg) do
      {:ok, ["EVENT", _, event]} ->
        handle_event(event, state)
      _ ->
        {:ok, state}
    end
  end

  def publish_event(event) do
    json = Jason.encode!(["EVENT", event])
    Enum.each(@relays, fn relay ->
      WebSockex.send_frame(relay, {:text, json})
    end)
  end
end
