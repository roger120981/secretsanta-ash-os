defmodule SecretSanta.Users.UserProfileTest do
  @moduledoc false

  use SecretSanta.DataCase, async: true
  use SecretSantaTest.Factory

  alias SecretSanta.Users
  alias SecretSanta.Users.UserProfile

  setup ctx do
    SecretSantaTest.Factory.prepare_test_context([], ctx)
  end

  describe "create_by_sign_up" do
    @tag feature: :users
    test "successfully creates a user profile and account" do
      user_profile_params = %{name: name} = params!(UserProfile, variant: :invitation)

      user_profile =
        %UserProfile{account: account} =
        Users.create_user_profile_by_invitation!(user_profile_params,
          actor: SecretSanta.Actors.admin()
        )

      assert user_profile.name == name

      assert Ash.CiString.to_comparable_string(account.email) ==
               get_in(user_profile_params, [:account, :email])
    end
  end
end
