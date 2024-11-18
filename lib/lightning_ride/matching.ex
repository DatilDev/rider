# lib/lightning_ride/matching.ex
defmodule LightningRide.Matching do
  import Ecto.Query
  alias LightningRide.{Repo, Accounts.User, Tracking.Location}

  @max_distance_km 10 # Maximum distance to match drivers

  def find_nearby_drivers(pickup_location) do
    # Find active drivers within radius
    query = from u in User,
      join: l in Location,
      on: l.user_id == u.id,
      where: u.role == "driver" and u.status == "available",
      where: fragment(
        "ST_Distance(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326)) <= ?",
        ^pickup_location.longitude,
        ^pickup_location.latitude,
        l.longitude,
        l.latitude,
        ^(@max_distance_km * 1000)
      ),
      order_by: fragment(
        "ST_Distance(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))",
        ^pickup_location.longitude,
        ^pickup_location.latitude,
        l.longitude,
        l.latitude
      ),
      select: %{
        driver: u,
        distance: fragment(
          "ST_Distance(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326)) / 1000",
          ^pickup_location.longitude,
          ^pickup_location.latitude,
          l.longitude,
          l.latitude
        ),
        location: l
      }

    Repo.all(query)
  end

  def calculate_ride_price(pickup_location, dropoff_location) do
    with {:ok, route} <- LightningRide.Routing.get_route(pickup_location, dropoff_location),
         {:ok, gas_price} <- LightningRide.Routing.get_gas_price(pickup_location) do

      # Calculate base price based on distance and duration
      distance_km = route.distance / 1000
      duration_minutes = route.duration / 60

      # Estimate gas consumption (assuming 10km/L average)
      gas_liters = distance_km / 10
      gas_cost = gas_liters * gas_price

      # Add operation costs and profit margin
      base_price = gas_cost * 1.05 # 5% markup

      # Add time-based cost ($0.20 per minute)
      time_cost = duration_minutes * 0.20

      # Add base fare
      total = base_price + time_cost + 5.00 # $5 base fare

      {:ok, %{
        total: Float.round(total, 2),
        breakdown: %{
          gas_cost: Float.round(gas_cost, 2),
          time_cost: Float.round(time_cost, 2),
          base_fare: 5.00,
          gas_price: gas_price
        }
      }}
    end
  end
end
