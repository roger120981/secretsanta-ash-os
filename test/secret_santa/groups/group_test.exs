defmodule SecretSanta.Groups.GroupTest do
  @moduledoc false

  use SecretSanta.DataCase, async: true
  use SecretSantaTest.Factory

  alias SecretSanta.Accounts
  alias SecretSanta.Accounts.Account
  alias SecretSanta.Actors
  alias SecretSanta.Groups
  alias SecretSanta.Groups.Group
  alias SecretSanta.Groups.UserGroup
  alias SecretSanta.Users
  alias SecretSanta.Users.UserProfile

  setup ctx do
    SecretSantaTest.Factory.prepare_test_context([], ctx)
  end

  defp assert_empty(list, name) do
    assert Enum.empty?(list) == true,
           "expected #{inspect(name)} to be empty, but it is: #{inspect(list, pretty: true)}"
  end

  describe "Groups.create!" do
    @tag feature: :groups, lead?: true
    test "create works without inviting", %{
      lead: user = %Account{user_profile: _profile = %{id: profile_id}},
    } do
      args = %{name: Faker.Team.creature()}

      created_group =
        %Group{id: group_id, participant_count: participant_count, participants: participants} =
        Groups.create_group!(args, actor: user)

      actual_participant_count = Enum.count(participants)
      assert created_group.name == args[:name]
      assert created_group.lead_santa_id == profile_id

      assert actual_participant_count == participant_count,
             "the number of participants and participant_count are not equal: #{actual_participant_count} != #{participant_count}"

      assert participant_count == 1,
             "expected lead and only lead to be a participant, but got #{participant_count} participants"

      refetched_group = Groups.get_group_by_id!(group_id, actor: user)

      assert {:ok, _group} = Groups.get_group_by_id(group_id, actor: user)
      assert {:ok, [%Group{id: ^group_id}]} = Groups.list_groups(actor: user)
    end

    @tag feature: :groups, lead?: true, people: 3
    test "create! works with inviting", %{
      lead: user = %Account{user_profile: profile},
      people: people,
    } do
      args = %{
        name: Faker.Team.creature(),
        invited_users: people,
      }

      group = %Group{name: group_name} = Groups.create_group!(args, actor: user)

      assert group_name == args[:name]
      assert group.lead_santa_id == profile.id
      assert {:ok, _group} = Groups.get_group_by_id(group.id, actor: user)
      assert [_group] = Groups.list_groups!(authorize?: false)
    end

    @people_count 5

    @tag feature: :groups, group?: true, people: @people_count
    test "invite unregistered people to existing group",
         %{lead: lead_acc = %Account{}, group: group = %Group{id: group_id}, people: people} do
      %Group{
        all_users: all_users,
        participant_count: participant_count,
        participants: participants,
      } = group

      expected_user_count = @people_count + 1

      user_count = Enum.count(all_users)
      participant_count = Enum.count(participants)

      assert Enum.count(people) == @people_count,
             "did not get the expected amount of people: #{@people_count} != #{Enum.count(people)}"

      assert user_count == 1,
             "expected lead (and only lead) to be a all_users at this time, but got #{Enum.count(all_users)} users"

      assert participant_count == 1,
             "expected lead (and only lead) to be a participant at this time, but got #{Enum.count(participants)} participants"

      assert participant_count == participant_count

      updated_group =
        %Group{
          all_users: all_users,
          participant_count: participant_count,
          invitees: invitees,
          participants: participants,
        } =
        Groups.invite_participants!(group, people, actor: lead_acc, load: [all_users: [:account]])

      accounts = Accounts.list_accounts!(actor: Actors.admin())
      user_profiles = Users.list_user_profiles!(actor: Actors.admin())

      assert Enum.count(accounts) == expected_user_count
      assert Enum.count(user_profiles) == expected_user_count

      for user <- all_users do
        assert {:ok, %Account{}} =
                 Accounts.get_by_id(user.account_id, actor: Actors.admin()) |> dbg()
      end

      # Lead can read Group
      %Group{id: ^group_id} =
        Groups.get_group_by_id!(group_id, actor: lead_acc, load: [all_users: :account])

      assert Enum.count(all_users) == expected_user_count
      refute Enum.empty?(invitees), ":invitees is empty when it ought to be #{@people_count}"

      invitee_ids = Enum.map(invitees, & &1.id)
      invitees = Enum.filter(all_users, &(&1.id in invitee_ids))

      # All guests can read Group
      for invitee = %UserProfile{account: invitee_account, id: invitee_id} <- invitees do
        invitee = %{invitee | account: nil}
        actor = %Account{invitee_account | user_profile: invitee}

        %Group{
          id: ^group_id,
          invitees: invitees,
          participants: participants,
        } = Groups.get_group_by_id!(group_id, actor: actor)

        [%Group{id: ^group_id}] = Groups.list_groups!(actor: actor)

        %UserGroup{group_id: ^group_id, user_id: invitee_id, accepted_at: accepted_at} =
          Groups.get_user_group_by_ids!(group_id, invitee_id)
          |> Groups.accept_invitation!()

        %Group{participant_count: participant_count, participants: participants} =
          Groups.get_group_by_id!(group_id, actor: actor)

        assert not is_nil(accepted_at), "the field :accepted_at is still nil after accepting!"
        assert Enum.count(participants) == participant_count
      end

      final_group =
        %Group{
          id: ^group_id,
          all_users: users,
          invitees: invitees,
          user_count: user_count,
          participants: participants,
          rejections: rejections,
        } = Groups.get_group_by_id!(group.id, actor: lead_acc)

      dbg(final_group.all_user_assocs)

      assert_empty(invitees, :invitees)
      assert_empty(rejections, :rejections)
      # assert Enum.count(users) == Enum.count(participants) == user_count == expected_user_count
    end

    @tag feature: :groups, group?: true, people: 1
    test "can accept an invitation",
         %{
           lead: lead = %_{},
           group: group = %Group{id: group_id},
           people: [guest],
         } do
      %Group{participants: participants} =
        Groups.invite_participants!(group, [guest], actor: lead)

      _lead_participation =
        %UserProfile{id: lead_id} =
        Enum.find(participants, &(&1.id == lead.user_profile.id))

      [%UserProfile{id: participant_id}] =
        Enum.reject(participants, &(&1.id == lead_id))

      assert Enum.count(participants) == 1, """
      still expecting only the lead to be a participant, guest has not yet accepted:
      #{inspect(participants, pretty: true)}
      """

      assert Enum.count(Groups.list_user_groups_by_group_id!(group_id)) == 2

      _lead_groups = Groups.list_user_groups_by_user_id!(lead_id)

      participant_groups = Groups.list_user_groups_by_user_id!(participant_id)

      assert Enum.count(participant_groups) == 1

      %UserGroup{
        accepted_at: accepted_at,
        user_id: ^participant_id,
        group_id: ^group_id,
      } =
        Groups.get_user_group_by_ids!(group_id, participant_id)
        |> Groups.accept_invitation!(actor: guest)

      assert not is_nil(accepted_at) == true, "expected :accepted_at to not be nil!"
    end

    @tag feature: :groups, group?: true, guests: 2
    test "lead can read guests, and guests can read each other and lead",
         %{
           lead: lead = %_{},
           group: %Group{},
           guests: guests,
         } do
      [
        lhs = %Account{},
        rhs = %Account{},
      ] = guests

      guests
      |> Enum.map(& &1.id)
      |> Users.list_user_profiles_by_ids!(actor: lead)

      Users.get_user_profile_by_id!(lhs.user_profile.id, actor: rhs)
      Users.get_user_profile_by_id!(rhs.user_profile.id, actor: lhs)
    end

    @tag feature: :groups, group?: true, people: 1
    test "cannot read if not lead_santa and not guest",
         %{lead: lead = %Account{}, group: %Group{id: group_id}, people: [person = %{}]} do
      assert Enum.empty?(Groups.list_groups!(actor: person)),
             "expected person's list_groups! result to be empty!"

      assert Enum.count(Groups.list_groups!(actor: lead)) == 1,
             "expected lead's list_groups! result to have exactly one element!"

      assert_raise Ash.Error.Query.NotFound, fn ->
        Groups.get_group_by_id!(group_id, actor: person)
      end
    end
  end

  describe "Groups.Budgets" do
    alias SecretSanta.Groups

    @tag feature: :groups, lead?: true
    test "can set a valid budget", %{lead: lead} do
      amount = Decimal.new("1000.00")

      args =
        %{
          name: "Budget Santa",
          budget: %{max: amount, currency: "SEK"},
        }

      group = %Group{budget: budget} = Groups.create_group!(args, actor: lead)

      assert group.name == args[:name]
      assert group.lead_santa_id == lead.user_profile.id

      refute is_nil(budget)
      assert to_string(budget) == "1 000 kr"

      assert Decimal.eq?(budget.max, amount)
    end

    @tag feature: :groups, lead?: true, group?: %{max: 1000, currency: :sek}
    test "can update a valid budget", %{lead: lead = %Account{}, group: group = %Group{}} do
      refute is_nil(group.budget), "budget was expected to not be nil!"
      assert to_string(group.budget) == "1 000 kr"

      first_budget = group.budget

      new_amount = Decimal.new("10.00")

      args =
        %{
          budget: %{max: new_amount, currency: "EUR"},
        }

      %Group{budget: budget} = Groups.update_group!(group, args, actor: lead)

      refute first_budget == budget,
             "the budget is still the same as before! #{first_budget} == #{budget}"

      refute is_nil(budget)
      assert Decimal.eq?(budget.max, new_amount)
      assert to_string(budget) == "€10"

      new_min = Decimal.new("5.00")

      args =
        %{
          budget: %{max: new_amount, min: new_min, currency: "EUR"},
        }

      %Group{budget: final_budget} = Groups.update_group!(group, args, actor: lead)

      refute budget == final_budget,
             "the budget is still the same as before! #{budget} == #{final_budget}"

      refute is_nil(budget)
      assert Decimal.eq?(budget.max, new_amount)
      assert to_string(budget) == "€10"
    end

    @tag feature: :groups, lead?: true, group?: %{max: 100, currency: :gbp}
    test "can remove a valid budget", %{lead: lead, group: group = %Group{}} do
      assert to_string(group.budget) == "£100"

      args = %{budget: nil}

      %Group{budget: budget} = Groups.update_group!(group, args, actor: lead)

      assert is_nil(budget)
    end
  end

  describe "Groups.shuffle/1" do
    @tag feature: :groups, guests: 3
    test "can shuffle", %{lead: lead = %_{}, group: group = %Group{}} do
      %Group{pairs: pairs} =
        group
        |> dbg()
        |> Groups.shuffle!(actor: lead)

      assert Enum.count(pairs) == 4

      # pairs =
      #   pairs
      #   |> Enum.map(& %{lhs: &1.participant_id, rhs: &1.target_id})
    end
  end
end
