defmodule SecretSanta.Accounts.AccountTest do
  @moduledoc false

  use SecretSanta.DataCase, async: true
  use SecretSantaTest.Factory

  alias SecretSanta.Accounts
  alias SecretSanta.Accounts.Account
  alias SecretSanta.Groups
  alias SecretSanta.Groups.Group

  setup ctx do
    SecretSantaTest.Factory.prepare_test_context([], ctx)
  end

  describe "create_by_sign_up" do
    @tag feature: :accounts
    test "successfully registers a new account" do
      account_params = params!(Account)
      account = %Account{} =
        account_params
        |> Accounts.create_by_sign_up!()

      assert Ash.CiString.to_comparable_string(account.email) == account_params[:email]
    end

    @tag feature: :accounts, lead?: true
    test "forbidden when already signed in", %{lead: lead} do
      assert_raise Ash.Error.Forbidden, fn ->
        params!(Account)
        |> Accounts.create_by_sign_up!(actor: lead)
      end
    end
  end

  describe "create_by_invitation" do
    @tag feature: :accounts, lead?: true, group?: true, people: 1
    test "can invite as lead", %{lead: lead, group: group, people: people} do
      updated_group = Groups.invite_participants!(group, people, actor: lead)

      lead_profile = lead.user_profile

      assert %Group{lead_santa: ^lead_profile, participants: participants} = updated_group

      participant_count = Enum.count(participants)

      assert participant_count == 2, "expected to have 2 participants: #{participant_count}"
    end
  end
end
