defmodule SecretSanta.Accounts.Emails.MagicLink do
  @moduledoc false

  import Swoosh.Email

  alias SecretSanta.Accounts
  alias SecretSanta.Accounts.Account
  alias SecretSanta.Users.UserProfile

  def email(account = %Account{id: account_id, user_profile: %Ash.NotLoaded{}}, url) do
    with {:ok, acc} <- Accounts.get_by_id(account_id, actor: account) do
      email(acc, url)
    end
  end

  def email(%Account{email: email, user_profile: profile = %UserProfile{}}, url) do
    body =
      """
      Hello #{profile.name}!

      Use the following link to login:
      #{url}
      """

    new()
    |> to({profile.name, Ash.CiString.value(email)})
    |> from({"SecretSanta", noreply_sender_email()})
    |> subject("Login request")
    |> text_body(body)
  end

  # ! private function

  defp noreply_sender_email() do
    Application.get_env(:secret_santa, :noreply_sender_email)
  end
end
