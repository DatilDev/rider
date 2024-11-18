# lib/lightning_ride/rides.ex
defmodule LightningRide.Rides do
  import Ecto.Query
  alias LightningRide.{Repo, Rides.Ride, Payments.Escrow}

  def request_ride(attrs) do
    Repo.transaction(fn ->
      with {:ok, ride} <- create_ride(attrs),
           {:ok, escrow} <- Escrow.create_escrow(ride) do
        %{ride: ride, payment: escrow}
      else
        {:error, reason} -> Repo.rollback(reason)
      end
    end)
  end

  def complete_ride(ride_id) do
    with {:ok, ride} <- get_ride(ride_id),
         {:ok, _} <- Escrow.release_escrow(ride_id) do

      ride
      |> Ride.changeset(%{status: "completed"})
      |> Repo.update()
    end
  end

  def cancel_ride(ride_id) do
    with {:ok, ride} <- get_ride(ride_id),
         {:ok, _} <- Escrow.refund_escrow(ride_id) do

      ride
      |> Ride.changeset(%{status: "cancelled"})
      |> Repo.update()
    end
  end
end
