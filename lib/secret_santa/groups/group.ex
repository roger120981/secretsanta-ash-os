defmodule SecretSanta.Groups.Group do
  @moduledoc """
  A group of people playing Secret Santa.
  """

  use Ash.Resource,
    domain: SecretSanta.Groups,
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

  # alias SecretSanta.Changes.AppendLeadAsParticipant
  alias SecretSanta.Changes.ShuffleGroup
  alias SecretSanta.Groups.Budget
  alias SecretSanta.Groups.UserGroup
  alias SecretSanta.Groups.Pair
  alias SecretSanta.Users.UserProfile

  @accept_create [
    :budget,
    :desc,
    :name,
    :starts_on,
  ]

  @manage_participants_relationship [
      on_lookup: :relate,
      on_no_match: {:create, :create_by_invitation},
      on_match: :ignore,
      on_missing: :ignore
    ]

  actions do
    get_by_id prepare: [
      load: [:lead_santa, :all_users, :participants]
    ]

    list_actions prepare: [
      load: [:lead_santa, :all_users, :participants, :rejections]
    ]

    soft_delete()

    create :create do
      primary? true
      accept @accept_create

      argument :invited_users, {:array, :map} do
        allow_nil? false
        default []
      end

      change relate_actor(:lead_santa, allow_nil?: false, field: :user_profile)
      change manage_relationship(:invited_users, :participants, @manage_participants_relationship)
      # change AppendLeadToParticipants

      change load [:lead_santa, :all_users, :participants, :rejections, :group_size]
    end

    read :read do
      primary? true
    end

    update :update do
      require_atomic? true
      accept [:budget, :desc]
    end

    update :invite_participants do
      require_atomic? false

      argument :participants, {:array, :map}, allow_nil?: false

      change manage_relationship(:participants, :all_users, @manage_participants_relationship)
    end

    update :invite_participants_by_ids do
      require_atomic? false

      argument :ids, {:array, :nanoid}, allow_nil?: false

      change manage_relationship(:ids, :all_users, @manage_participants_relationship)
    end

    update :uninvite_participants do
      require_atomic? false

      argument :participants, {:array, :map}, allow_nil?: false

      change manage_relationship(:participants, :all_users, type: :remove)
    end

    update :uninvite_participants_by_ids do
      require_atomic? false

      argument :ids, {:array, :nanoid}, allow_nil?: false

      change manage_relationship(:ids, :all_users, type: :remove)
    end

    update :shuffle do
      primary? false
      accept []
      change ShuffleGroup
    end

    destroy :destroy do
      primary? false
    end
  end

  attributes do
    nanoid()

    timestamps()

    deleted_at()

    attribute :name, :string do
      allow_nil? false
      public? true

      constraints [max_length: 64]
    end

    attribute :desc, :string do
      allow_nil? true
      public? true

      constraints [min_length: 32, max_length: 2048]
    end

    attribute :budget, Budget do
      allow_nil? true
      public? true

      default nil
    end

    attribute :budget_desc, :string do
      allow_nil? true
      public? true

      constraints [max_length: 512]
    end

    attribute :starts_on, :date do
      allow_nil? true
      public? true
    end

    attribute :pairs, {:array, Pair} do
      allow_nil? false
      public? true

      default []
    end
  end

  aggregates do
    count :group_size, :participants
  end

  relationships do
    belongs_to :lead_santa, UserProfile do
      public? true
      allow_nil? false
    end

    has_many :all_users, UserGroup do
      public? true
      description """
        The user-association relationship underlying all many-to-many
        relationships between groups and users.
        """

      destination_attribute :group_id
    end

    many_to_many :participants, UserProfile do
      public? true
      join_relationship :all_users

      source_attribute_on_join_resource :group_id
      destination_attribute_on_join_resource :user_id

      filter expr(not is_nil(parent(all_users.accepted_at)))
    end

    many_to_many :rejections, UserProfile do
      public? true
      join_relationship :all_users

      source_attribute_on_join_resource :group_id
      destination_attribute_on_join_resource :user_id
      filter expr(not is_nil(parent(all_users.rejected_at)))
    end
  end

  policies do
    # Admin will bypass anything
    bypass actor_attribute_equals(:admin, true) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if relates_to_actor_via(:lead_santa, field: :user_profile)
      authorize_if relates_to_actor_via(:participants, field: :user_profile)
    end

    policy action_type([:update, :destroy]) do
      authorize_if relates_to_actor_via(:lead_santa, field: :user_profile)
    end

    policy action_type(:create) do
      authorize_if always()
    end
  end

  postgres do
    repo SecretSanta.Repo

    table "groups"
    # base_filter_sql "deleted_at IS NULL"

    references do
      reference :lead_santa, on_delete: :delete, on_update: :update, name: "group_to_lead_santa_fkey"
    end
  end

  resource do
    description "A resource representing a group of people that are playing Secret Santa."
    # base_filter is_nil: :deleted_at

    short_name :group
    plural_name :groups
  end
end
