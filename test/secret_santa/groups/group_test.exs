defmodule SecretSanta.Groups.GroupTest do
  @moduledoc false

  use SecretSanta.DataCase, async: true
  use SecretSantaTest.Factory

  alias SecretSanta.Accounts.Account
  alias SecretSanta.Groups
  alias SecretSanta.Groups.Group
  alias SecretSanta.Groups.UserGroup
  alias SecretSanta.Users
  alias SecretSanta.Users.UserProfile

  setup ctx do
    SecretSantaTest.Factory.prepare_test_context([], ctx)
  end

  describe "Groups.create!" do
    @tag feature: :groups, lead?: true
    test "create works without inviting", %{lead: user = %Account{user_profile: _profile = %{id: profile_id}}} do
      args = %{
        name: Faker.Team.creature(),
      }

      # group = %Group{
      #   id: group_id,
      #   name: group_name,
      #   all_users: [
      #     %UserGroup{
      #       group_id: group_id,
      #       user_id: ^profile_id,
      #       accepted_at: accepted_at,
      #       invited_at: invited_at,
      #       hint_requested_at: nil,
      #       rejected_at: nil,
      #     },
      #   ],
      #   participants: [
      #     %UserProfile{id: ^profile_id},
      #   ],
      #   rejections: [],
      # } = Groups.create_group!(args, actor: user)

      created_group =
        %Group{id: group_id, group_size: group_size, participants: participants}
          = Groups.create_group!(args, actor: user)

      actual_group_size = Enum.count(participants)
      assert created_group.name == args[:name]
      assert created_group.lead_santa_id == profile_id
      assert actual_group_size == group_size,
        "the number of participants and group_size are not equal: #{actual_group_size} != #{group_size}"
      assert group_size == 1,
        "expected lead and only lead to be a participant, but got #{group_size} participants"

      refetched_group = Groups.get_group_by_id!(group_id, actor: user)

      assert {:ok, _group} = Groups.get_group_by_id(group_id, actor: user)
      assert {:ok, [%Group{id: ^group_id}]} = Groups.list_groups(actor: user)
    end

    @tag feature: :groups, lead?: true, people: 3
    test "create! works with inviting", %{lead: user = %Account{user_profile: profile}, people: people} do
      args = %{
        name: Faker.Team.creature(),
        invited_users: people
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
      %Group{participants: participants} = group
      participant_count = Enum.count(participants)
      assert participant_count == 1, "expected lead (and only lead) to be a participant at this time, but got #{Enum.count(participants)} participants"

      _updated_group = %Group{participants: participants}
        = Groups.invite_participants!(group, people, actor: lead_acc)

      # Lead can read Group
      %Group{id: ^group_id} = Groups.get_group_by_id!(group_id, actor: lead_acc)

      group_size = @people_count + 1

      # All guests can read Group
      for participant = %UserProfile{account: participant_account} <- participants do
        participant = %{participant | account: nil}
        actor = %Account{participant_account | user_profile: participant}
        %Group{id: ^group_id, group_size: ^group_size, participants: participants} = Groups.get_group_by_id!(group_id, actor: actor)
        [%Group{id: ^group_id}] = Groups.list_groups!(actor: actor)

        assert Enum.count(participants) == group_size
      end

      # All guests are in the participants relationship
      assert Enum.count(participants) == group_size

      assert %Group{
          id: ^group_id,
        } = Groups.get_group_by_id!(group.id, actor: lead_acc)
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
        |> IO.inspect(pretty: true, label: "updated group ~>")

      _lead_participation = %UserProfile{id: lead_id}
        = Enum.find(participants, & &1.id == lead.user_profile.id)
      [%UserProfile{id: participant_id}]
        = Enum.reject(participants, & &1.id == lead_id)

      assert Enum.count(participants) == 1, """
        still expecting only the lead to be a participant, guest has not yet accepted:
        #{inspect participants, pretty: true}
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
      assert Enum.empty?(Groups.list_groups!(actor: person)), "expected person's list_groups! result to be empty!"
      assert Enum.count(Groups.list_groups!(actor: lead)) == 1, "expected lead's list_groups! result to have exactly one element!"

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

      refute first_budget == budget, "the budget is still the same as before! #{first_budget} == #{budget}"
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
      %Group{pairs: pairs} = Groups.shuffle!(group, actor: lead)

      assert Enum.count(pairs) == 4

      # pairs =
      #   pairs
      #   |> Enum.map(& %{lhs: &1.participant_id, rhs: &1.target_id})
    end
  end
end
