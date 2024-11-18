# lib/lightning_ride/tracking/location.ex
defmodule LightningRide.Tracking.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :latitude, :float
    field :longitude, :float
    field :heading, :float
    field :speed, :float
    field :accuracy, :float
    field :user_id, :id
    field :ride_id, :id

    timestamps()
  end

  def changeset(location, attrs) do
    location
    |> cast(attrs, [:latitude, :longitude, :heading, :speed, :accuracy, :user_id, :ride_id])
    |> validate_required([:latitude, :longitude, :user_id])
    |> validate_number(:latitude, greater_than_or_equal_to: -90, less_than_or_equal_to: 90)
    |> validate_number(:longitude, greater_than_or_equal_to: -180, less_than_or_equal_to: 180)
  end
end
