defmodule SecretSantaWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in liveviews
  """

  use SecretSantaWeb, :verified_routes

  import Phoenix.Component

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_account] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_account, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_account] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/a/sign-in")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_account] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/groups")}
    else
      {:cont, assign(socket, :current_account, nil)}
    end
  end
end
