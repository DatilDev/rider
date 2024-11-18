# lib/lightning_ride/payments/escrow.ex
defmodule LightningRide.Payments.Escrow do
  alias LightningRide.{Repo, Payments.HTLC}
  alias LightningRide.LightningClient

  @expiry_blocks 144 # 24 hours worth of blocks

  def create_escrow(ride) do
    # Generate random preimage
    preimage = :crypto.strong_rand_bytes(32)
    payment_hash = :crypto.hash(:sha256, preimage)

    # Create HTLC record
    htlc_attrs = %{
      payment_hash: Base.encode16(payment_hash, case: :lower),
      preimage: Base.encode16(preimage, case: :lower),
      amount_sats: satoshi_amount(ride.price),
      expiry_time: expiry_time(),
      ride_id: ride.id
    }

    Repo.transaction(fn ->
      with {:ok, htlc} <- create_htlc(htlc_attrs),
           {:ok, invoice} <- create_lightning_invoice(htlc) do
        {:ok, %{htlc: htlc, invoice: invoice}}
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  def lock_escrow(payment_hash) do
    case Repo.get_by(HTLC, payment_hash: payment_hash) do
      nil ->
        {:error, :not_found}

      htlc ->
        htlc
        |> Ecto.Changeset.change(status: "locked")
        |> Repo.update()
    end
  end

  def release_escrow(ride_id) do
    with htlc <- Repo.get_by(HTLC, ride_id: ride_id),
         true <- valid_for_release?(htlc),
         {:ok, _} <- LightningClient.settle_invoice(htlc.payment_hash, htlc.preimage) do

      htlc
      |> Ecto.Changeset.change(status: "completed")
      |> Repo.update()
    else
      nil -> {:error, :not_found}
      false -> {:error, :invalid_state}
      error -> error
    end
  end

  def refund_escrow(ride_id) do
    with htlc <- Repo.get_by(HTLC, ride_id: ride_id),
         true <- valid_for_refund?(htlc),
         {:ok, _} <- LightningClient.cancel_invoice(htlc.payment_hash) do

      htlc
      |> Ecto.Changeset.change(status: "refunded")
      |> Repo.update()
    else
      nil -> {:error, :not_found}
      false -> {:error, :invalid_state}
      error -> error
    end
  end

  # Private functions

  defp create_htlc(attrs) do
    %HTLC{}
    |> HTLC.changeset(attrs)
    |> Repo.insert()
  end

  defp create_lightning_invoice(htlc) do
    LightningClient.create_hodl_invoice(
      amount_sats: htlc.amount_sats,
      payment_hash: htlc.payment_hash,
      expiry: @expiry_blocks,
      memo: "Ride payment escrow"
    )
  end

  defp valid_for_release?(htlc) do
    htlc.status == "locked" && DateTime.compare(htlc.expiry_time, DateTime.utc_now()) == :gt
  end

  defp valid_for_refund?(htlc) do
    htlc.status in ["pending", "locked"]
  end

  defp satoshi_amount(usd_price) do
    # Convert USD to sats using current exchange rate
    # This is a placeholder - implement actual rate conversion
    trunc(usd_price * 100_000) # Assuming 1 USD = 100k sats
  end

  defp expiry_time do
    DateTime.utc_now()
    |> DateTime.add(@expiry_blocks * 600, :second) # Assuming 10 minute block time
  end
end
