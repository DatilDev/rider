# lib/lightning_ride/accounts/user.ex
defmodule LightningRide.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :pubkey, :string
    field :name, :string
    field :about, :string
    field :picture, :string
    field :last_seen, :utc_datetime

    has_many :rides_as_passenger, LightningRide.Rides.Ride, foreign_key: :passenger_id
    has_many :rides_as_driver, LightningRide.Rides.Ride, foreign_key: :driver_id

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:pubkey, :name, :about, :picture, :last_seen])
    |> validate_required([:pubkey])
    |> unique_constraint(:pubkey)
  end
end
