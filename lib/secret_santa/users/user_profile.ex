defmodule SecretSanta.Users.UserProfile do
  @moduledoc """
  Our representation of a user's profile in the system/UI.
  """

  use Ash.Resource,
    domain: SecretSanta.Users,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [],
    notifiers: [
      Ash.Notifier.PubSub,
    ]

  use Repeated.GetBy
  use Repeated.GetById
  use Repeated.NanoId
  use Repeated.ListActions
  use Repeated.SoftDelete
  use Repeated.Timestamps

  alias SecretSanta.Accounts.Account
  alias SecretSanta.Groups.Group
  alias SecretSanta.Groups.UserGroup

  @manage_invitation_relationship [
    on_lookup: :relate,
    on_no_match: {:create, :create_by_invitation},
    on_match: :error,
    on_missing: :error,
  ]

  actions do
    get_by_id()
    list_actions()
    soft_delete()

    create :create do
      primary? true
      accept [:name]
    end

    create :create_by_sign_up do
      primary? false
      accept [:name]
    end

    create :create_by_invitation do
      primary? false
      accept [:name]

      argument :account, :map do
        allow_nil? false
      end

      change manage_relationship(:account, @manage_invitation_relationship)
    end

    read :read do
      primary? true
    end

    read :list_by_ids do
      primary? false

      argument :ids, {:array, :nanoid} do
        allow_nil? false
      end

      filter expr(id in ^arg(:ids))
    end

    update :update do
      primary? true
      accept [:name]
    end

    destroy :destroy do
      primary? false
    end
  end

  attributes do
    nanoid()

    timestamps public?: true

    deleted_at()

    attribute :name, :string do
      allow_nil? false
      public? true

      constraints max_length: 64
    end
  end

  relationships do
    belongs_to :account, Account do
      allow_nil? false
    end

    has_many :leading_groups, Group do
      public? true
      destination_attribute :lead_santa_id
    end

    has_many :group_memberships, UserGroup do
      public? true
      destination_attribute :user_id
    end

    many_to_many :groups, Group do
      public? true
      through UserGroup
      source_attribute_on_join_resource :user_id
      destination_attribute_on_join_resource :group_id
    end
  end

  policies do
    # # AshAuthentication itself
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    # Admin will bypass anything
    bypass actor_attribute_equals(:admin, true) do
      authorize_if always()
    end

    # System will bypass anything
    bypass actor_attribute_equals(:system, true) do
      authorize_if always()
    end

    policy action_type(:create) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if relates_to_actor_via([:groups, :lead_santa, :account])
      authorize_if relates_to_actor_via([:groups, :participants, :account])
    end

    policy action_type([:update, :destroy]) do
      authorize_if relates_to_actor_via([:groups, :lead_santa, :account])
    end
  end

  postgres do
    repo SecretSanta.Repo

    table "user_profiles"

    references do
      reference :account,
        on_delete: :delete,
        on_update: :update,
        name: "user_profile_account_fkey"
    end
  end
end
