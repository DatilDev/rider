# lib/lightning_ride_web/live/ride_live.ex
defmodule LightningRideWeb.RideLive do
  use LightningRideWeb, :live_view
  alias LightningRide.{Rides, Tracking, Matching, Routing}

  def mount(_params, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(LightningRide.PubSub, "location:#{socket.assigns.ride_id}")
    end

    {:ok,
     assign(socket,
       ride: nil,
       driver_location: nil,
       passenger_location: nil,
       route: nil,
       available_drivers: [],
       price_estimate: nil,
       current_user_id: session["user_id"],
       tracking_enabled: false
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="h-screen flex flex-col">
      <div class="flex-1 relative">
        <!-- Map Container -->
        <div id="map" phx-hook="MapHook" class="absolute inset-0"
          data-ride-id={@ride_id}
          data-driver-location={Jason.encode!(@driver_location)}
          data-passenger-location={Jason.encode!(@passenger_location)}
          data-route={Jason.encode!(@route)}>
        </div>
      </div>

      <!-- Ride Status Panel -->
      <div class="bg-white p-4 shadow-lg">
        <%= if @ride do %>
          <div class="flex justify-between items-center">
            <div>
              <p class="text-lg font-semibold">Status: <%= @ride.status %></p>
              <%= if @driver_location do %>
                <p class="text-sm text-gray-600">
                  ETA: <%= calculate_eta(@driver_location, @passenger_location) %>
                </p>
              <% end %>

              <%= if @price_estimate do %>
                <div class="mt-2">
                  <p class="font-semibold">Estimated Price: $<%= @price_estimate.total %></p>
                  <div class="text-sm text-gray-600">
                    <p>Gas Cost: $<%= @price_estimate.breakdown.gas_cost %></p>
                    <p>Time Cost: $<%= @price_estimate.breakdown.time_cost %></p>
                    <p>Base Fare: $<%= @price_estimate.breakdown.base_fare %></p>
                    <p>Current Gas Price: $<%= @price_estimate.breakdown.gas_price %>/gallon</p>
                  </div>
                </div>
              <% end %>
            </div>

            <%= if @available_drivers != [] and @ride.status == "requested" do %>
              <div class="ml-4">
                <h3 class="font-semibold mb-2">Available Drivers</h3>
                <div class="space-y-2">
                  <%= for driver <- @available_drivers do %>
                    <div class="flex items-center justify-between border p-2 rounded">
                      <div>
                        <p class="font-medium"><%= driver.driver.name %></p>
                        <p class="text-sm text-gray-600"><%= Float.round(driver.distance, 1) %>km away</p>
                      </div>
                      <button phx-click="select_driver" phx-value-driver={driver.driver.id}
                        class="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600">
                        Select
                      </button>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("request_ride", %{"pickup" => pickup, "dropoff" => dropoff}, socket) do
    pickup_coords = parse_location(pickup)
    dropoff_coords = parse_location(dropoff)

    with {:ok, price_estimate} <- Matching.calculate_ride_price(pickup_coords, dropoff_coords),
         {:ok, nearby_drivers} <- {:ok, Matching.find_nearby_drivers(pickup_coords)},
         {:ok, route} <- Routing.get_route(pickup_coords, dropoff_coords) do

      {:noreply,
       socket
       |> assign(
         available_drivers: nearby_drivers,
         price_estimate: price_estimate,
         route: route
       )}
    else
      error ->
        {:noreply, put_flash(socket, :error, "Could not process ride request")}
    end
  end

  def handle_event("select_driver", %{"driver" => driver_id}, socket) do
    case Rides.assign_driver(socket.assigns.ride.id, driver_id) do
      {:ok, updated_ride} ->
        {:noreply,
         socket
         |> assign(ride: updated_ride)
         |> put_flash(:info, "Driver assigned successfully")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not assign driver")}
    end
  end
end
