import Config

# Ash
config :ash, :default_belongs_to_type, :string

config :ash,
  custom_types: [
    currency: SecretSanta.Currency,
    nanoid: SecretSanta.NanoId,
  ],
  known_types: [
    SecretSanta.Currency,
  ]

ash_policy_debug_enabled? =
  System.get_env("ASH_POLICY_BREAKDOWN_ENABLED")
  |> case do
    "true" -> true
    _ -> false
  end

if ash_policy_debug_enabled? do
  config :ash, :policies, show_policy_breakdowns?: true
  config :ash, :policies, log_policy_breakdowns: :error
  # config :ash, :policies, log_successful_policy_breakdowns: false
end

ash_authentication_debug_enabled? =
  System.get_env("ASH_AUTHENTICATION_DEBUG_ENABLED")
  |> case do
    "true" -> true
    _ -> false
  end

if ash_authentication_debug_enabled? do
  config :ash_authentication, debug_authentication_failures?: true
end

# esbuild
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)},
  ]

# PetalComponents
config :petal_components,
       :error_translator_function,
       {SecretSantaWeb.ErrorHelpers, :translate_error}

# Spark configuration
config :spark, :formatter,
  remove_parens?: true,
  "Ash.Resource": [
    type: Ash.Resource,
    section_order: [
      :authentication,
      :token,
      :actions,
      :attributes,
      :relationships,
      :code_interface,
      :policies,
      :postgres,
    ],
  ]

# Tailwind
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__),
  ]
