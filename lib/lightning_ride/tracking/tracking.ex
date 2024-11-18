defmodule LightningRide.Tracking do
  import Ecto.Query
  alias LightningRide.{Repo, Tracking.Location}
  alias Phoenix.PubSub

  def track_location(attrs) do
    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
    |> broadcast_location_update()
  end

  def get_latest_location(user_id) do
    Location
    |> where(user_id: ^user_id)
    |> order_by(desc: :inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  def list_ride_locations(ride_id) do
    Location
    |> where(ride_id: ^ride_id)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
  end

  defp broadcast_location_update({:ok, location} = result) do
    PubSub.broadcast(
      LightningRide.PubSub,
      "location:#{location.ride_id}",
      {:location_updated, location}
    )
    result
  end

  defp broadcast_location_update(error), do: error
end
