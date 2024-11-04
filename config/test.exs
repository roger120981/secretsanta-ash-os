import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

partition = System.get_env("MIX_TEST_PARTITION", nil)

database_name =
  [
    "secret_santa_test",
    partition,
  ]
  |> Enum.reject(&is_nil/1)
  |> Enum.join("_")

unless is_nil(partition) do
  IO.puts("Mix test partition: #{partition}")
  IO.puts("Database name: #{database_name}")
end

config :secret_santa, SecretSanta.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: database_name,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :secret_santa, SecretSantaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "rqRw2BbsA5rwajjQ++0Fquj/AgphxaH/7FADVs4mSsg7RRqCoXUi4b5An/1wfy6Y",
  server: false

# In test we don't send emails.
config :secret_santa, SecretSanta.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
