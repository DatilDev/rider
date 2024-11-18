defmodule LightningRide.Accounts do
  import Ecto.Query
  alias LightningRide.Repo
  alias LightningRide.Accounts.User

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_pubkey(pubkey) do
    Repo.get_by(User, pubkey: pubkey)
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def set_user_status(user_id, status) do
    from(u in User, where: u.id == ^user_id)
    |> Repo.update_all(set: [status: status, last_seen: DateTime.utc_now()])
  end
end
