defmodule SecretSanta.Groups do
  @moduledoc """
  Context module for all `Group` records.
  """

  use Ash.Domain

  alias SecretSanta.Groups.Group
  alias SecretSanta.Groups.UserGroup

  resources do
    resource Group do
      define :create_group, action: :create

      define :get_group_by_id,
        action: :get_by_id,
        args: [:id]

      define :list_groups,
        action: :list

      define :invite_participants,
        action: :invite_participants,
        args: [:participants]

      define :invite_participants_by_ids,
        action: :invite_participants_by_ids,
        args: [:ids]

      define :uninvite_participants,
        action: :uninvite_participants,
        args: [:participants]

      define :uninvite_participants_by_ids,
        action: :uninvite_participants_by_ids,
        args: [:ids]

      define :update_group, action: :update
      define :shuffle, action: :shuffle
      define :delete_group, action: :soft_delete
      define :destroy_group, action: :destroy
    end

    resource UserGroup do
      define :create_user_group, action: :create
      define :create_accepted_user_group, action: :create_accepted

      define :get_user_group_by_ids,
        action: :get_by_group_and_user_ids,
        args: [:group_id, :user_id]

      define :list_user_groups, action: :list

      define :list_user_groups_by_group_id,
        action: :list_by_group_id,
        args: [:group_id]

      define :list_user_groups_by_user_id,
        action: :list_by_user_id,
        args: [:user_id]

      define :accept_invitation, action: :accept
      define :reject_invitation, action: :reject
      define :set_hint, action: :set_hint_for_santa, args: [:hint]

      define :update_user_group, action: :update

      define :delete_user_group, action: :soft_delete
      define :destroy_user_group, action: :destroy
    end
  end

  @doc """
  Checks if the group is ready by checking that all
  participants have submitted their hints for their
  secret santa.
  """
  @spec group_ready?(Group.t() | String.t()) :: boolean() | {:error, any()}
  def group_ready?(group = %Group{}) do
    with {:ok, _hints} <- get_hints_of_group(group) do
      {:error, :not_implemented}
    end
  end

  def group_ready?(group_id) do
    with {:ok, group = %Group{}} <- get_group_by_id(group_id) do
      group_ready?(group)
    end
  end

  @doc """
  Loads all the hints of all the participants.
  """
  @spec get_hints_of_group(Group.t()) :: {:ok, map()} | {:error, any()}
  def get_hints_of_group(_group = %Group{}) do
    {:error, :not_implemented}
  end

  def get_hints_of_group(_) do
    {:error, :bad_argument}
  end
end
