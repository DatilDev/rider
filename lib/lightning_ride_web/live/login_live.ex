defmodule LightningRideWeb.LoginLive do
  use LightningRideWeb, :live_view
  alias LightningRide.Auth
  alias LightningRide.Nostr.Event

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       loading: false,
       extension_available: false,
       login_method: nil
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div class="max-w-md w-full space-y-8">
        <div>
          <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Sign in to LightningRide
          </h2>
        </div>

        <div class="mt-8 space-y-6">
          <!-- Extension Login Button -->
          <div>
            <button phx-click="check_extension" phx-hook="NostrExtension"
              class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500">
              Sign in with Nostr Extension
            </button>
          </div>

          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-300"></div>
            </div>
            <div class="relative flex justify-center text-sm">
              <span class="px-2 bg-gray-50 text-gray-500">Or continue with</span>
            </div>
          </div>

          <!-- NSEC Login Form -->
          <form phx-submit="login_nsec" class="space-y-6">
            <div>
              <label for="nsec" class="sr-only">nsec key</label>
              <input type="password" name="nsec" id="nsec" required
                class="appearance-none rounded-md relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                placeholder="Enter your nsec key">
            </div>
            <div>
              <button type="submit"
                class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                disabled={@loading}>
                <%= if @loading, do: "Signing in...", else: "Sign in with nsec" %>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("check_extension", _params, socket) do
    {:noreply, push_event(socket, "checkNostrExtension", %{})}
  end

  def handle_event("extension_found", _params, socket) do
    {:noreply, push_event(socket, "requestPublicKey", %{})}
  end

  def handle_event("extension_not_found", _params, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Nostr extension not found. Please install Amber or another NIP-07 compatible extension.")
     |> assign(extension_available: false)}
  end

  def handle_event("public_key_received", %{"pubkey" => pubkey}, socket) do
    # Create authentication event
    event = %Event{
      kind: 27235,
      pubkey: pubkey,
      created_at: System.system_time(:second),
      content: "Login to LightningRide",
      tags: []
    }

    {:noreply, push_event(socket, "signEvent", %{event: event})}
  end

  def handle_event("event_signed", %{"event" => signed_event}, socket) do
    case Auth.login_with_extension(signed_event.pubkey, signed_event) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_session(:user_id, user.id)
         |> put_flash(:info, "Successfully logged in!")
         |> redirect(to: "/")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid signature")
         |> assign(loading: false)}
    end
  end

  def handle_event("login_nsec", %{"nsec" => nsec}, socket) do
    socket = assign(socket, loading: true)

    case Auth.login_with_nsec(nsec) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_session(:user_id, user.id)
         |> put_flash(:info, "Successfully logged in!")
         |> redirect(to: "/")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> assign(loading: false)
         |> put_flash(:error, "Invalid nsec key")}
    end
  end
end
