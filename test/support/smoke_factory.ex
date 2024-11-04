defmodule SecretSantaTest.Factory do
  @moduledoc false

  use Smokestack

  alias SecretSanta.Accounts
  alias SecretSanta.Accounts.Account
  alias SecretSanta.Groups
  alias SecretSanta.Groups.Budget
  alias SecretSanta.Groups.Group
  alias SecretSanta.Users.UserProfile

  # Accounts Domain
  factory Account do
    before_build fn _ ->
      params!(Account, variant: :invitation)
      |> Map.put(:user_profile, params!(UserProfile))
    end
  end

  factory Account, :invitation do
    attribute :email, &Faker.Internet.email/0
  end

  factory Budget do
    attribute :currency, fn -> "sek" end
    attribute :max, fn -> random_between(10, 20) * 10 end
    attribute :min, fn -> random_between(1, 10) * 10 end
  end

  factory Group do
    attribute :name, &Faker.Pokemon.name/0
    attribute :desc, fn -> Faker.Lorem.paragraph(4..10) end
  end

  factory UserProfile do
    attribute :name, &Faker.Pokemon.name/0
  end

  factory UserProfile, :invitation do
    before_build fn p ->
      account =
        params!(Account, variant: :invitation)

      params!(UserProfile)
      |> Map.put(:account, account)
    end
  end

  # Convenience functions

  def prepare_test_context(context, tags) do
    context
    |> add_lead?(tags[:lead?])
    |> add_group?(tags[:group?])
    |> add_guests?(tags[:guests])
    |> add_people?(tags[:people])
  end

  # ! private functions

  # no deps
  defp add_lead?(context, true) do
    lead =
      create_users(1)
      |> hd()
      |> Accounts.create_by_sign_up!()

    context
    |> Keyword.put_new(:lead, lead)
  end
  defp add_lead?(context, _) do
    context
  end

  # this implies the existence of a lead, so it'll create
  # one if it doesn't already exist.
  defp add_group?(context, nil) do
    context
  end
  defp add_group?(context, settings) do
    budget =
      case settings do
        %{amount: amount, currency: currency} ->
          %{max: amount, currency: currency}
        map when is_map(map) ->
          map
        true -> nil
      end

    context = make_sure_exists(context, :lead, &add_lead?/2)

    group =
      context
      |> Keyword.fetch!(:lead)
      |> create_group(budget)

    context
    |> Keyword.put_new(:group, group)
  end

  # this implies the existence of a group, so it'll create
  # one if it doesn't already exist.
  defp add_guests?(context, count) when is_integer(count) and count > 0 do
    context = make_sure_exists(context, :group, &add_group?/2)
    lead = Keyword.fetch!(context, :lead)
    group = Keyword.fetch!(context, :group)

    guests = create_users(count)
      |> Enum.map(&Accounts.create_by_sign_up!/1)

    guest_profiles = Enum.map(guests, & &1.user_profile)

    updated_group =
      %Group{
        id: group_id,
        participants: participants
      } = Groups.invite_participants!(group, guest_profiles, actor: lead)

    for participant <- participants do
      Groups.get_user_group_by_ids!(group_id, participant.id)
      |> Groups.accept_invitation!()
    end

    context
    |> Keyword.put(:group, updated_group)
    |> Keyword.put(:guests, guests)
  end
  defp add_guests?(context, _) do
    context
  end

  # no deps
  defp add_people?(context, count) when is_integer(count) and count > 0 do
    people = create_users(count, :invitation)

    context
    |> Keyword.put(:people, people)
  end
  defp add_people?(context, _) do
    context
  end

  defp create_group(lead, budget) do
    params!(Group)
    |> Map.put(:budget, budget)
    |> Groups.create_group!(actor: lead)
  end

  defp create_users(count, variant \\ nil)
  defp create_users(count, :invitation) do
    UserProfile
    |> params!(count: count, variant: :invitation)
  end

  defp create_users(count, nil) do
    Account
    |> params!(count: count)
  end

  defp make_sure_exists(context, key, fun) do
    case Keyword.has_key?(context, key) do
      true -> context
      false -> fun.(context, true)
    end
  end

  defp random_between(min, max) do
    Faker.Random.Elixir.random_between(min, max)
  end
end
