defmodule SecretSanta.Groups.Pair do
  @moduledoc false

  use Ash.Resource,
    data_layer: :embedded

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    attribute :id, :string do
      public? true
      allow_nil? false
      description "The ID of this pairing."
      default &SecretSanta.Id.generate/0
      constraints max_length: 12
    end

    timestamps()

    attribute :participant_id, :string do
      public? true
      allow_nil? false
      description "The ID of the participant in the group."
      constraints max_length: 12
    end

    attribute :target_id, :string do
      public? true
      allow_nil? false
      description "The ID of the target participant in the group."
      constraints max_length: 12
    end
  end

  code_interface do
    domain SecretSanta.Groups

    define :create, action: :create
    define :read, action: :read
    define :update, action: :update
    define :destroy, action: :destroy
  end
end
