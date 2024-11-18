# lib/lightning_ride_web/live/ride_live.ex
defmodule LightningRideWeb.RideLive do
  use LightningRideWeb, :live_view
  alias LightningRide.{Rides, Tracking, Matching}

  # ... previous mount and render functions ...

  def handle_event("request_ride", params, socket) do
    case Rides.request_ride(params) do
      {:ok, %{ride: ride, payment: %{invoice: invoice}}} ->
        {:noreply,
         socket
         |> assign(ride: ride)
         |> assign(payment_invoice: invoice)
         |> push_event("show_invoice", %{
           invoice: invoice.payment_request,
           amount_sats: invoice.amount_sats
         })}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not create ride")}
    end
  end

  def handle_event("complete_ride", _params, socket) do
    case Rides.complete_ride(socket.assigns.ride.id) do
      {:ok, updated_ride} ->
        {:noreply,
         socket
         |> assign(ride: updated_ride)
         |> put_flash(:info, "Ride completed successfully")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not complete ride")}
    end
  end

  def handle_event("cancel_ride", _params, socket) do
    case Rides.cancel_ride(socket.assigns.ride.id) do
      {:ok, updated_ride} ->
        {:noreply,
         socket
         |> assign(ride: updated_ride)
         |> put_flash(:info, "Ride cancelled successfully")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not cancel ride")}
    end
  end
end
