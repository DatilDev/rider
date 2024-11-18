# lib/lightning_ride/auth.ex
defmodule LightningRide.Auth do
  alias LightningRide.Accounts
  alias LightningRide.Nostr.Event

  def login_with_extension(pubkey, signed_event) do
    with {:ok, valid} <- verify_signed_event(signed_event),
         true <- valid,
         {:ok, user} <- get_or_create_user(pubkey) do
      {:ok, user}
    else
      _ -> {:error, :invalid_signature}
    end
  end

  def login_with_nsec(nsec) do
    with {:ok, private_key} <- decode_nsec(nsec),
         pubkey = K256.public_key(private_key),
         {:ok, user} <- get_or_create_user(pubkey) do
      # Create authentication event
      auth_event = Event.new(private_key, 27235, "Login to LightningRide")
      {:ok, user, auth_event}
    end
  end

  defp decode_nsec(nsec) do
    case Base58.decode(nsec) do
      {:ok, <<0x01, private_key::binary-32>>} -> {:ok, private_key}
      _ -> {:error, :invalid_nsec}
    end
  end

  defp verify_signed_event(event) do
    # Verify the event signature according to NIP-01
    id = Event.calculate_id(event)
    K256.verify_signature(id, event.sig, event.pubkey)
  end

  defp get_or_create_user(pubkey) do
    case Accounts.get_user_by_pubkey(pubkey) do
      nil -> create_user(pubkey)
      user -> {:ok, user}
    end
  end

  defp create_user(pubkey) do
    Accounts.create_user(%{
      pubkey: pubkey,
      last_seen: DateTime.utc_now()
    })
  end
end
