# lib/lightning_ride_web/channels/ride_channel.ex
defmodule LightningRideWeb.RideChannel do
  use LightningRideWeb, :channel
  alias LightningRide.Tracking

  def join("ride:" <> ride_id, _params, socket) do
    if authorized?(socket, ride_id) do
      {:ok, assign(socket, :ride_id, ride_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("update_location", %{"location" => location_params}, socket) do
    params = Map.merge(location_params, %{
      "user_id" => socket.assigns.user_id,
      "ride_id" => socket.assigns.ride_id
    })

    case Tracking.track_location(params) do
      {:ok, _location} -> {:reply, :ok, socket}
      {:error, _changeset} -> {:reply, :error, socket}
    end
  end

  defp authorized?(socket, ride_id) do
    case LightningRide.Rides.get_ride(ride_id) do
      nil -> false
      ride ->
        socket.assigns.user_id in [ride.passenger_id, ride.driver_id]
    end
  end
end
