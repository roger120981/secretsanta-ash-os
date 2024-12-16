defmodule SecretSantaWeb.Plugs.RemoteIp do
  @moduledoc """
  Attaches the conn's remote IP address to [`Logger's`](`Logger`) metadata.
  """

  require Logger

  @behaviour Plug

  def init(_opts) do
    :ok
  end

  def call(conn, :ok) do
    Logger.metadata(remote_ip: :inet_parse.ntoa(conn.remote_ip))
    conn
  end
end
