# lib/lightning_ride/lightning_client.ex
defmodule LightningRide.LightningClient do
  # This module interfaces with your Lightning Network node
  # Implementation will depend on your node software (LND, c-lightning, etc.)

  @lnd_url "https://your-lnd-node:8080"

  def create_hodl_invoice(opts) do
    # Create hold invoice using LND REST API
    headers = [
      {"Grpc-Metadata-macaroon", lnd_macaroon()},
      {"Content-Type", "application/json"}
    ]

    body = Jason.encode!(%{
      hash: opts[:payment_hash],
      value: opts[:amount_sats],
      expiry: opts[:expiry],
      memo: opts[:memo]
    })

    case HTTPoison.post("#{@lnd_url}/v2/invoices/hodl", body, headers) do
      {:ok, %{status_code: 200, body: response}} ->
        {:ok, Jason.decode!(response)}
      error ->
        {:error, error}
    end
  end

  def settle_invoice(payment_hash, preimage) do
    headers = [
      {"Grpc-Metadata-macaroon", lnd_macaroon()},
      {"Content-Type", "application/json"}
    ]

    body = Jason.encode!(%{
      preimage: preimage
    })

    case HTTPoison.post("#{@lnd_url}/v2/invoices/settle", body, headers) do
      {:ok, %{status_code: 200}} -> {:ok, :settled}
      error -> {:error, error}
    end
  end

  def cancel_invoice(payment_hash) do
    headers = [
      {"Grpc-Metadata-macaroon", lnd_macaroon()},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.delete("#{@lnd_url}/v2/invoices/#{payment_hash}", headers) do
      {:ok, %{status_code: 200}} -> {:ok, :cancelled}
      error -> {:error, error}
    end
  end

  defp lnd_macaroon do
    System.get_env("LND_MACAROON")
  end
end
