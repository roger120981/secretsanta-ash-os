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
      account = %Account{} = Accounts.create_by_sign_up!(account_params)
      assert Ash.CiString.to_comparable_string(account.email) == account_params[:email]
    end

    @tag feature: :accounts, lead?: true
    test "forbidden when already signed in", %{lead: lead} do
      assert_raise Ash.Error.Forbidden, fn -> Accounts.create_by_sign_up!(params!(Account), actor: lead) end
    end
  end
end
