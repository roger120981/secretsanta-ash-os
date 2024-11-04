defmodule SecretSanta.Accounts.Account do
  @moduledoc """
  The account resource.
  """

  use Ash.Resource,
    domain: SecretSanta.Accounts,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshAuthentication,
    ],
    notifiers: [
      Ash.Notifier.PubSub,
    ]

  use Repeated.GetBy
  use Repeated.GetById
  use Repeated.NanoId
  use Repeated.ListActions
  use Repeated.SoftDelete
  use Repeated.Timestamps

  require Logger
  require Ecto.Query

  import Ecto.Query

  alias SecretSanta.Accounts.Secrets
  alias SecretSanta.Accounts.Senders.SendMagicLink
  alias SecretSanta.Accounts.Token
  alias SecretSanta.Checks.ActorIsNil
  alias SecretSanta.Users.UserProfile

  @repo_table_name "accounts"

  actions do
    # Repeated-provided actions
    get_by_id prepare: [load: [:user_profile]]
    get_by :email, prepare: [load: [:user_profile]]
    list_actions prepare: [load: [:user_profile]]
    soft_delete()

    create :create_by_sign_up do
      primary? true
      accept [:email]

      argument :user_profile, :map do
        allow_nil? true
      end

      # prepare AshAuthentication.Strategy.MagicLink.RequestPreparation

      # change set_context(%{
      #   strategy_name: :magic_link,
      #   private: %{ash_authentication?: true}
      # })
      change manage_relationship(:user_profile, type: :create)
    end

    create :create_by_invitation do
      primary? false
      accept [:email]
    end

    read :read do
      primary? true

      prepare build(load: [:user_profile])
    end

    read :request_magic_link do
      argument :email, :ci_string do
        allow_nil? false
      end

      prepare AshAuthentication.Strategy.MagicLink.RequestPreparation
      prepare build(load: [:user_profile])

      filter expr(email == ^arg(:email))
    end

    update :update do
      primary? true
      accept [:*]
    end

    destroy :destroy do
      primary? false
    end

    action :destroy_by_emails do
      argument :emails, {:array, :string}, allow_nil?: false

      run fn input, _ ->
        emails = input.arguments.emails

        {_, nil} =
          from(a in @repo_table_name, where: a.email in ^emails)
          |> SecretSanta.Repo.delete_all()

        :ok
      end
    end
  end

  attributes do
    nanoid()

    timestamps()
    deleted_at()

    attribute :email, :ci_string do
      allow_nil? false
      public? true
      sensitive? true
    end
  end

  authentication do
    strategies do
      # https://hexdocs.pm/ash_authentication/dsl-ashauthentication-strategy-magiclink.html#authentication-strategies-magic_link
      magic_link do
        identity_field :email
        registration_enabled? true
        # request_action_name :request_magic_link

        sender SendMagicLink
      end
    end

    tokens do
      enabled? true
      token_resource Token
      signing_secret Secrets
    end
  end

  identities do
    identity :email, [:email]
  end

  relationships do
    has_one :user_profile, UserProfile do
      allow_nil? true
    end
  end

  policies do
    # AshAuthentication itself
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    # Admin will bypass anything
    bypass actor_attribute_equals(:admin, true) do
      authorize_if always()
    end

    # Admin will bypass anything
    bypass actor_attribute_equals(:system, true) do
      authorize_if always()
    end

    policy action(:create_by_invitation) do
      authorize_if actor_present()
    end

    policy action(:create_by_sign_up) do
      authorize_if ActorIsNil
    end

    policy action_type(:read) do
      authorize_if action(:invite_participants)
      authorize_if expr(id == ^actor(:id))
    end
  end

  postgres do
    repo SecretSanta.Repo

    table @repo_table_name
    base_filter_sql "deleted_at IS NULL"
  end
end
