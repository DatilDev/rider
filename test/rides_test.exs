defmodule LightningRide.RidesTest do
  use LightningRide.DataCase
  alias LightningRide.{Rides, Accounts, Payments}

  describe "rides" do
    setup do
      {:ok, passenger} = Accounts.create_user(%{
        pubkey: "passenger_pubkey",
        role: "passenger"
      })

      {:ok, driver} = Accounts.create_user(%{
        pubkey: "driver_pubkey",
        role: "driver",
        status: "available"
      })

      {:ok, %{passenger: passenger, driver: driver}}
    end

    test "request_ride/1 creates ride and escrow", %{passenger: passenger} do
      attrs = %{
        passenger_id: passenger.id,
        pickup_location: %Geo.Point{coordinates: {-74.5, 40.0}},
        dropoff_location: %Geo.Point{coordinates: {-74.6, 40.1}},
        price: Decimal.new("25.00")
      }

      assert {:ok, %{ride: ride, payment: payment}} = Rides.request_ride(attrs)
      assert ride.status == "requested"
      assert payment.htlc.status == "pending"
    end

    test "accept_ride/2 updates ride status", %{passenger: passenger, driver: driver} do
      {:ok, %{ride: ride}} = create_test_ride(passenger)
      assert {:ok, updated_ride} = Rides.accept_ride(ride.id, driver.id)
      assert updated_ride.status == "accepted"
      assert updated_ride.driver_id == driver.id
    end

    test "complete_ride/1 releases payment", %{passenger: passenger, driver: driver} do
      {:ok, %{ride: ride}} = create_test_ride(passenger)
      {:ok, _} = Rides.accept_ride(ride.id, driver.id)

      assert {:ok, completed_ride} = Rides.complete_ride(ride.id)
      assert completed_ride.status == "completed"

      htlc = Payments.get_htlc_by_ride_id(ride.id)
      assert htlc.status == "completed"
    end
  end

  defp create_test_ride(passenger) do
    Rides.request_ride(%{
      passenger_id: passenger.id,
      pickup_location: %Geo.Point{coordinates: {-74.5, 40.0}},
      dropoff_location: %Geo.Point{coordinates: {-74.6, 40.1}},
      price: Decimal.new("25.00")
    })
  end
end
