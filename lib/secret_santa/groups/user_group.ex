defmodule SecretSanta.Groups.UserGroup do
  @moduledoc false

  use Ash.Resource,
    domain: SecretSanta.Groups,
    data_layer: AshPostgres.DataLayer

  use Repeated.GetBy
  use Repeated.NanoId
  use Repeated.ListActions
  use Repeated.SoftDelete
  use Repeated.Timestamps

  alias SecretSanta.Groups.Group
  alias SecretSanta.Users.UserProfile

  @accept_create [
    :group_id,
    :hint_for_santa,
    :user_id,
  ]

  # @manage_accepted [
  #   on_lookup: :relate,
  #   on_no_match: :error,
  #   on_match: :ignore,
  #   on_missing: :ignore
  # ]

  actions do
    defaults [:update]

    list_actions list_primary?: true
    soft_delete()

    create :create do
      primary? true
      accept @accept_create
    end

    create :create_accepted do
      accept [:group_id, :user_id]

      change set_attribute(:accepted_at, DateTime.utc_now())
    end

    read :get_by_group_and_user_ids do
      get_by [:group_id, :user_id]
    end

    read :get_latest_by_user_id do
      argument :user_id, :nanoid, allow_nil?: false

      prepare build(limit: 1, sort: [inserted_at: :asc])

      filter expr(user_id == ^arg(:user_id) && hint_requested? && is_nil(hint_for_santa))
    end

    read :list_by_group_id do
      argument :group_id, :nanoid, allow_nil?: false

      filter expr(group_id == ^arg(:group_id))
    end

    read :list_by_user_id do
      argument :user_id, :nanoid, allow_nil?: false

      filter expr(user_id == ^arg(:user_id))
    end

    update :set_hint_for_santa do
      accept []

      argument :hint, :string do
        allow_nil? false
      end

      change set_attribute(:hint_for_santa, arg(:hint))
    end

    update :accept do
      accept []

      change set_attribute(:accepted_at, DateTime.utc_now())
      change set_attribute(:rejected_at, nil)
    end

    update :reject do
      accept []

      change set_attribute(:accepted_at, nil)
      change set_attribute(:rejected_at, DateTime.utc_now())
    end

    destroy :destroy do
      primary? false
    end
  end

  attributes do
    attribute :user_id, :string do
      primary_key? true
      public? true
      allow_nil? false
      constraints max_length: 12
    end

    attribute :group_id, :string do
      primary_key? true
      public? true
      allow_nil? false
      constraints max_length: 12
    end

    attribute :hint_for_santa, :string do
      public? true
      allow_nil? true
      constraints max_length: 256
    end

    timestamp :invited_at,
      allow_nil?: true,
      public?: true,
      default: &DateTime.utc_now/0

    timestamp :accepted_at,
      allow_nil?: true,
      public?: true,
      default: nil

    timestamp :rejected_at,
      allow_nil?: true,
      public?: true,
      default: nil

    timestamp :hint_requested_at,
      allow_nil?: true,
      public?: true,
      default: nil
  end

  relationships do
    belongs_to :user, UserProfile,
      public?: true,
      define_attribute?: false,
      source_attribute: :user_id,
      destination_attribute: :id

    belongs_to :group, Group,
      public?: true,
      define_attribute?: false,
      source_attribute: :group_id,
      destination_attribute: :id
  end

  postgres do
    repo SecretSanta.Repo

    table "user_groups"

    references do
      reference :user, on_delete: :delete, name: "user_group_user_profile_fkey"
      reference :group, on_delete: :delete, name: "user_group_group_fkey"
    end
  end
end
