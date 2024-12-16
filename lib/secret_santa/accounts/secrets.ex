defmodule SecretSanta.Accounts.Secrets do
  @moduledoc """
  Secret resolving module for `AshAuthentication`.
  """

  use AshAuthentication.Secret

  @doc false
  def secret_for([:authentication, :tokens, :signing_secret], SecretSanta.Accounts.Account, _) do
    case Application.fetch_env(:secret_santa, SecretSantaWeb.Endpoint) do
      {:ok, endpoint_config} ->
        Keyword.fetch(endpoint_config, :secret_key_base)

      :error ->
        :error
    end
  end
end
