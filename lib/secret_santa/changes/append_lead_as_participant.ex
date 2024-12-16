defmodule SecretSanta.Changes.AppendLeadAsParticipant do
  @moduledoc false

  use Ash.Resource.Change

  require Logger

  alias SecretSanta.Accounts.Account
  alias SecretSanta.Groups
  alias SecretSanta.Groups.Group

  @impl true
  def atomic?() do
    false
  end

  @impl true
  def change(changeset, _opts, _context = %{actor: actor}) do
    changeset
    |> Ash.Changeset.after_action(&hook(&1, &2, actor))
  end

  # ! private functions

  defp hook(_changeset, _record = %Group{id: group_id}, actor) do
    with {:ok, _lead_user_group} <-
           Groups.create_accepted_user_group(
             user_group_args(actor, group_id),
             actor: actor
           ) do
      Groups.get_group_by_id(group_id, actor: actor)
    end
  end

  defp user_group_args(%Account{user_profile: %_{id: user_id}}, group_id) do
    %{group_id: group_id, user_id: user_id}
  end
end
