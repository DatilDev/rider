defmodule LightningRide.Payments.EscrowTest do
  use LightningRide.DataCase
  alias LightningRide.Payments.{Escrow, HTLC}

  describe "escrow" do
    setup do
      {:ok, ride} = create_test_ride()
      {:ok, %{ride: ride}}
    end

    test "create_escrow/1 creates HTLC", %{ride: ride} do
      assert {:ok, %{htlc: htlc, invoice: invoice}} = Escrow.create_escrow(ride)
      assert htlc.ride_id == ride.id
      assert htlc.status == "pending"
      assert invoice.payment_request
    end

    test "lock_escrow/1 updates HTLC status", %{ride: ride} do
      {:ok, %{htlc: htlc}} = Escrow.create_escrow(ride)
      assert {:ok, locked_htlc} = Escrow.lock_escrow(htlc.payment_hash)
      assert locked_htlc.status == "locked"
    end

    test "release_escrow/1 completes payment", %{ride: ride} do
      {:ok, %{htlc: htlc}} = Escrow.create_escrow(ride)
      {:ok, _} = Escrow.lock_escrow(htlc.payment_hash)

      assert {:ok, completed_htlc} = Escrow.release_escrow(ride.id)
      assert completed_htlc.status == "completed"
    end
  end
end
