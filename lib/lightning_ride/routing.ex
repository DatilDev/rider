# lib/lightning_ride/routing.ex
defmodule LightningRide.Routing do
  use GenServer
  alias LightningRide.Repo

  @osrm_api "http://router.project-osrm.org/route/v1/driving/"
  @gas_api "https://api.collectapi.com/gasPrice/fromCoordinates"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_route(origin, destination) do
    url = "#{@osrm_api}#{origin.longitude},#{origin.latitude};#{destination.longitude},#{destination.latitude}?overview=full&geometries=geojson"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        route = Jason.decode!(body)
        {:ok, %{
          geometry: get_in(route, ["routes", 0, "geometry"]),
          distance: get_in(route, ["routes", 0, "distance"]),
          duration: get_in(route, ["routes", 0, "duration"])
        }}
      _ ->
        {:error, :route_not_found}
    end
  end

  def get_gas_price(coordinates) do
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "apikey #{System.get_env("COLLECT_API_KEY")}"}
    ]

    body = Jason.encode!(%{
      latitude: coordinates.latitude,
      longitude: coordinates.longitude
    })

    case HTTPoison.post(@gas_api, body, headers) do
      {:ok, %{status_code: 200, body: response}} ->
        data = Jason.decode!(response)
        {:ok, get_in(data, ["result", "gasoline"])}
      _ ->
        {:ok, 3.50} # Fallback average price if API fails
    end
  end
end
