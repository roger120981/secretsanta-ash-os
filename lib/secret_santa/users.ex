defmodule SecretSanta.Users do
  @moduledoc false

  use Ash.Domain

  alias SecretSanta.Users.UserProfile

  resources do
    resource UserProfile do
      define :get_user_profile_by_id,
        action: :get_by_id,
        args: [:id]

      define :list_user_profiles,
        action: :list

      define :list_user_profiles_by_ids,
        action: :list_by_ids,
        args: [:ids]
    end
  end
end
