efmodule LightningRide.MatchingTest do
  use LightningRide.DataCase
  alias LightningRide.{Matching, Accounts, Tracking}

  describe "driver matching" do
    setup do
      {:ok, driver} = Accounts.create_user(%{
        pubkey: "driver_pubkey",
        role: "driver",
        status: "available"
      })

      # Create driver location
      {:ok, location} = Tracking.track_location(%{
        user_id: driver.id,
        latitude: 40.0,
        longitude: -74.5
      })

      {:ok, %{driver: driver, location: location}}
    end

    test "find_nearby_drivers/1 returns drivers within radius", %{driver: driver} do
      pickup_location = %{latitude: 40.0, longitude: -74.5}
      drivers = Matching.find_nearby_drivers(pickup_location)

      assert length(drivers) == 1
      [found_driver] = drivers
      assert found_driver.driver.id == driver.id
    end

    test "find_nearby_drivers/1 excludes distant drivers" do
      pickup_location = %{latitude: 41.0, longitude: -75.5} # Far away
      drivers = Matching.find_nearby_drivers(pickup_location)
      assert Enum.empty?(drivers)
    end
  end
end
