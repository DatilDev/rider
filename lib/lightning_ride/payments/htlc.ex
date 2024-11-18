# lib/lightning_ride/payments/htlc.ex
defmodule LightningRide.Payments.HTLC do
  use Ecto.Schema
  import Ecto.Changeset

  schema "htlcs" do
    field :payment_hash, :string
    field :preimage, :string
    field :amount_sats, :integer
    field :status, :string, default: "pending" # pending, locked, completed, refunded
    field :expiry_time, :utc_datetime

    belongs_to :ride, LightningRide.Rides.Ride

    timestamps()
  end

  def changeset(htlc, attrs) do
    htlc
    |> cast(attrs, [:payment_hash, :preimage, :amount_sats, :status, :expiry_time])
    |> validate_required([:payment_hash, :amount_sats, :expiry_time])
  end
end
