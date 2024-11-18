# lib/lightning_ride_web/controllers/auth_controller.ex
defmodule LightningRideWeb.AuthController do
  use LightningRideWeb, :controller
  alias LightningRide.Auth

  def login(conn, %{"nsec" => nsec}) do
    case Auth.login_with_nsec(nsec) do
      {:ok, user, auth_event} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_session(:auth_event, auth_event)
        |> redirect(to: "/")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid nsec key")
        |> redirect(to: "/login")
    end
  end
end
