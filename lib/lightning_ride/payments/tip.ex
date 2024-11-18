defmodule LightningRide.Payments.Tip do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tips" do
    field :amount_sats, :integer
    field :payment_hash, :string
    field :status, :string, default: "pending"

    belongs_to :ride, LightningRide.Rides.Ride
    belongs_to :driver, LightningRide.Accounts.User
    belongs_to :passenger, LightningRide.Accounts.User

    timestamps()
  end

  def changeset(tip, attrs) do
    tip
    |> cast(attrs, [:amount_sats, :payment_hash, :status, :ride_id, :driver_id, :passenger_id])
    |> validate_required([:amount_sats, :payment_hash, :ride_id, :driver_id, :passenger_id])
  end
end
