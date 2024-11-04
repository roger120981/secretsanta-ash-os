defmodule SecretSantaWeb.PageController do
  use SecretSantaWeb, :controller

  def home(conn, _params) do
    if conn.assigns[:current_account] do
      redirect(conn, to: ~p"/groups")
    else
      render(conn, :home, layout: false)
    end
  end
end
