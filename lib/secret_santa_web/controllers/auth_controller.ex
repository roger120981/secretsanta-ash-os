defmodule SecretSantaWeb.AuthController do
  @moduledoc """
  Callback module for `AshAuthenticationPhoenix`.
  """

  use SecretSantaWeb, :controller
  use AshAuthentication.Phoenix.Controller

  require Logger

  def success(conn, _activity, user, _token) do
    Logger.debug("Successfully authenticated #{user.id}", account_id: user.id)

    return_to = get_session(conn, :return_to) || ~p"/groups"

    conn
    |> delete_session(:return_to)
    |> store_in_session(user)
    |> assign(:current_account, user)
    |> redirect(to: return_to)
  end

  def failure(conn, _activity, _reason) do
    conn
    |> put_status(401)
    |> render("failure.html")
  end

  def sign_out(conn, _params) do
    return_to = get_session(conn, :return_to) || ~p"/"

    conn
    |> clear_session()
    |> redirect(to: return_to)
  end
end
