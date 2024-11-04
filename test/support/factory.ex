# defmodule SecretSantaTest.Factory do
#   @moduledoc false

#   require Logger

#   alias SecretSanta.Api
#   alias SecretSanta.Groups
#   alias SecretSanta.Groups.Group
#   alias SecretSanta.Groups.UserGroups
#   alias SecretSanta.Accounts
#   alias SecretSanta.Accounts.Account

#   @bulk_opts [
#     return_records?: true,
#     return_errors?: true,
#   ]

#   def create_user() do
#     random_user_params()
#     |> Accounts.create_account!()
#   end

#   def create_users(n) do
#     %Ash.BulkResult{records: records, errors: errors} =
#       1..n
#       |> Enum.map(fn _ -> random_user_params() end)
#       |> Api.bulk_create!(User, :create, @bulk_opts)
#     unless Enum.count(errors) == 0 do
#       raise RuntimeError,
#           message: """
#           we got some errors when trying to prepare a test:
#           #{inspect errors, pretty: true}
#           """
#     end
#     records
#   end

#   def prepare_test_context(context, tags) do
#     context
#     |> add_lead?(tags[:lead])
#     |> add_group?(tags[:group])
#     |> add_guests?(tags[:guests])
#     |> add_people?(tags[:people])
#   end

#   # ! private functions

#   defp make_sure_exists(context, key, fun) do
#     case Keyword.has_key?(context, key) do
#       true -> context
#       false -> fun.(context, true)
#     end
#   end

#   # no deps
#   defp add_lead?(context, true) do
#     context
#     |> Keyword.put_new(:lead, create_user())
#   end
#   defp add_lead?(context, _) do
#     context
#   end

#   # this implies the existence of a lead, so it'll create
#   # one if it doesn't already exist.
#   defp add_group?(context, nil) do
#     context
#   end
#   defp add_group?(context, settings) do
#     budget =
#       case settings do
#         %{amount: _, currency: _} -> settings
#         true -> nil
#       end

#     context = make_sure_exists(context, :lead, &add_lead?/2)

#     group =
#       context
#       |> Keyword.fetch!(:lead)
#       |> create_group(budget)

#     context
#     |> Keyword.put_new(:group, group)
#   end

#   # this implies the existence of a group, so it'll create
#   # one if it doesn't already exist.
#   defp add_guests?(context, count) when is_integer(count) and count > 0 do
#     context = make_sure_exists(context, :group, &add_group?/2)
#     lead = Keyword.fetch!(context, :lead)
#     group = Keyword.fetch!(context, :group)

#     guests = create_users(count)
#     guest_ids = guests |> Enum.map(& &1.id)

#     updated_group = %Group{
#       id: group_id,
#       participants: participants
#     } = Groups.invite_group_participants!(group, guest_ids, authorize?: false, actor: lead)

#     for participant <- participants do
#       Groups.get_by_group_and_user_id!(group_id, participant.id)
#       |> Groups.accept_invitation!()
#     end

#     context
#     |> Keyword.put(:group, updated_group)
#     |> Keyword.put(:guests, guests)
#   end
#   defp add_guests?(context, _) do
#     context
#   end

#   # no deps
#   defp add_people?(context, count) when is_integer(count) and count > 0 do
#     people = create_users(count)

#     context
#     |> Keyword.put(:people, people)
#   end
#   defp add_people?(context, _) do
#     context
#   end
# end
