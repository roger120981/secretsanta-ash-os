defmodule SecretSanta.Accounts.Senders.SendMagicLink do
  @moduledoc """
  Sends a magic link for a user login.
  """

  use AshAuthentication.Sender
  use SecretSantaWeb, :verified_routes

  alias SecretSanta.Accounts.Emails.MagicLink

  @impl AshAuthentication.Sender
  def send(user, token, _) do
    url =  url(~p"/a/auth/account/magic_link/?token=#{token}")

    user
    |> MagicLink.email(url)
    |> SecretSanta.Mailer.deliver!()
  end
end
