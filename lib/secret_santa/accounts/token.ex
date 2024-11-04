defmodule SecretSanta.Accounts.Token do
  @moduledoc """
  Authentication tokens.
  """

  use Ash.Resource,
    domain: SecretSanta.Accounts,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshAuthentication.TokenResource,
    ]

  postgres do
    repo SecretSanta.Repo
    table "account_tokens"
  end

  # If using policies, add the following bypass:
  policies do
    # AshAuthentication itself
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end
  end
end
