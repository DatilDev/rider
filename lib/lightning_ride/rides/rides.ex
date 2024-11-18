# lib/lightning_ride/rides.ex
defmodule LightningRide.Rides do
  import Ecto.Query
  alias LightningRide.Repo
  alias LightningRide.Rides.Ride
  alias LightningRide.Payments

  def request_ride(attrs) do
    price = calculate_price(attrs.pickup_location, attrs.dropoff_location)

    %Ride{}
    |> Ride.changeset(Map.put(attrs, :price, price))
    |> Repo.insert()
    |> case do
      {:ok, ride} ->
        # Generate Lightning invoice
        with {:ok, invoice} <- Payments.generate_invoice(ride.price) do
          Ride.changeset(ride, %{lightning_invoice: invoice})
          |> Repo.update()
        end
      error -> error
    end
  end

  def accept_ride(ride_id, driver_id) do
    Repo.get(Ride, ride_id)
    |> Ride.changeset(%{
      status: "accepted",
      driver_id: driver_id
    })
    |> Repo.update()
  end

  def complete_ride(ride_id) do
    Repo.get(Ride, ride_id)
    |> Ride.changeset(%{status: "completed"})
    |> Repo.update()
  end

  defp calculate_price(pickup, dropoff) do
    # Simple price calculation based on distance
    distance = Geo.Utils.distance(pickup, dropoff)
    Decimal.new(distance * 2) # $2 per kilometer
  end
end
