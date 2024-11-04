defmodule SecretSanta.Accounts do
  @moduledoc """
  The `Accounts` domain.
  """

  use Ash.Domain

  alias SecretSanta.Accounts

  resources do
    resource Accounts.Account do
      define :create_by_sign_up, action: :create_by_sign_up
      define :create_by_invitation, action: :create_by_invitation
      define :get_by_email, action: :get_by_email, args: [:email]
      define :get_by_id, action: :get_by_id, args: [:id]
      define :list_accounts, action: :list
      define :list_accounts_paginated, action: :list_paginated
      define :update_account, action: :update
      define :delete_account, action: :soft_delete
      define :destroy_account, action: :destroy
      define :destroy_accounts_by_emails, action: :destroy_by_emails, args: [:emails]
    end

    resource Accounts.Token
  end
end
