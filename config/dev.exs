import Config

# Configure your database
config :secret_santa, SecretSanta.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "secret_santa_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :secret_santa, SecretSantaWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  https: [
    port: 4443,
    cipher_suite: :strong,
    otp_app: :secret_santa,
    certfile: "priv/cert/selfsigned.pem",
    keyfile: "priv/cert/selfsigned_key.pem"
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "dHU5DHoMzTffc2zPw7pQ37LGxa7heS/4O7leKM+/DZiMB/ew0bG0Bu4SJ+A5mLlS",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]},
  ]

config :secret_santa, SecretSantaWeb.Endpoint,
  reloadable_compilers: [:gettext, :elixir, :app, :surface],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/secret_santa_web/(controllers|live|components)/.*(ex|heex|sface|js)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :secret_santa, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments in rendered markup
config :phoenix_live_view, :debug_heex_annotations, true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

