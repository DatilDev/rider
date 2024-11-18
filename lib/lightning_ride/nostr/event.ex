# lib/lightning_ride/nostr/event.ex
defmodule LightningRide.Nostr.Event do
  @derive Jason.Encoder
  defstruct [:id, :pubkey, :created_at, :kind, :tags, :content, :sig]

  def new(private_key, kind, content, tags \\ []) do
    event = %__MODULE__{
      pubkey: get_public_key(private_key),
      created_at: System.system_time(:second),
      kind: kind,
      tags: tags,
      content: content
    }

    id = calculate_id(event)
    sig = sign_event(id, private_key)

    %{event | id: id, sig: sig}
  end

  defp calculate_id(event) do
    # Calculate event ID according to NIP-01
    data = [
      0,
      event.pubkey,
      event.created_at,
      event.kind,
      event.tags,
      event.content
    ]

    :crypto.hash(:sha256, Jason.encode!(data))
    |> Base.encode16(case: :lower)
  end

  defp sign_event(id, private_key) do
    K256.sign(id, private_key)
    |> Base.encode16(case: :lower)
  end

  defp get_public_key(private_key) do
    K256.public_key(private_key)
    |> Base.encode16(case: :lower)
  end
end
