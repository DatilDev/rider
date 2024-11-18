# lib/lightning_ride/tracking.ex
defmodule LightningRide.Tracking do
  alias LightningRide.Tracking.Location
  alias LightningRide.Repo
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
