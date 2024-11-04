defmodule SecretSanta.Repo do
  @moduledoc """
  The main way to communicate with the database.
  """

  use AshPostgres.Repo, otp_app: :secret_santa

  def installed_extensions() do
    [
      "ash-functions",
      "citext",
      "pg_trgm",
      "uuid-ossp",
    ]
  end

  def min_pg_version() do
    %Version{major: 14, minor: 2, patch: 0}
  end
end
