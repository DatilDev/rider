# lib/lightning_ride/rides/ride.ex
defmodule LightningRide.Rides.Ride do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rides" do
    field :pickup_location, Geo.PostGIS.Geometry
    field :dropoff_location, Geo.PostGIS.Geometry
    field :status, :string, default: "requested" # requested, accepted, completed, cancelled
    field :payment_status, :string, default: "pending"
    field :price, :decimal
    field :lightning_invoice, :string

    belongs_to :passenger, LightningRide.Accounts.User
    belongs_to :driver, LightningRide.Accounts.User

    timestamps()
  end

  def changeset(ride, attrs) do
    ride
    |> cast(attrs, [:pickup_location, :dropoff_location, :status, :payment_status, :price, :lightning_invoice, :passenger_id, :driver_id])
    |> validate_required([:pickup_location, :dropoff_location, :passenger_id])
  end
end
