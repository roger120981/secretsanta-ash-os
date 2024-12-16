import Config

import_config "deps.exs"

read_version_file = fn ->
  __DIR__
  |> Path.join("../VERSION")
  |> File.read!()
  |> String.trim()
end

resolve_git_sha_env = fn ->
  System.get_env("GIT_VERSION_SHA", "dev")
  |> String.trim()
end

config :secret_santa,
  ash_domains: [
    SecretSanta.Accounts,
    SecretSanta.Groups,
    SecretSanta.Users,
  ],
  build_app_version: read_version_file.(),
  build_git_sha: resolve_git_sha_env.(),
  ecto_repos: [SecretSanta.Repo],
  generators: [timestamp_type: :utc_datetime, binary_id: true],
  noreply_sender_email: "noreply@local.domain"

# Configures the endpoint
config :secret_santa, SecretSantaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: SecretSantaWeb.ErrorHTML, json: SecretSantaWeb.ErrorJSON],
    layout: false,
  ],
  pubsub_server: SecretSanta.PubSub,
  live_view: [signing_salt: "TnZGU6r0"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :secret_santa, SecretSanta.Mailer, adapter: Swoosh.Adapters.Local

metadata = [
  # Core
  :crash_reason,
  :file,
  :line,
  :module,
  :function,

  # HTTP
  :remote_ip,

  # SecretSanta
  :group_id,
  :request_id,
  :account_id,
  :user_id,
]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: metadata

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
