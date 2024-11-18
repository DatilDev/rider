defmodule LightningRide.Payments.Tips do
  alias LightningRide.{Repo, Payments.Tip, LightningClient}
  import Ecto.Query

  def create_tip(attrs) do
    with {:ok, invoice} <- LightningClient.create_invoice(attrs.amount_sats, "Driver tip"),
         tip_attrs = Map.merge(attrs, %{payment_hash: invoice.payment_hash}),
         {:ok, tip} <- %Tip{} |> Tip.changeset(tip_attrs) |> Repo.insert() do
      {:ok, %{tip: tip, invoice: invoice}}
    end
  end

  def confirm_tip(payment_hash) do
    case Repo.get_by(Tip, payment_hash: payment_hash) do
      nil ->
        {:error, :not_found}
      tip ->
        tip
        |> Tip.changeset(%{status: "completed"})
        |> Repo.update()
    end
  end

  def get_driver_tips(driver_id) do
    Tip
    |> where([t], t.driver_id == ^driver_id and t.status == "completed")
    |> preload([:ride, :passenger])
    |> Repo.all()
  end
end
