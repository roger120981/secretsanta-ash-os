[
  import_deps: [
    :ash,
    :ash_authentication,
    :ash_authentication_phoenix,
    :ash_postgres,
    :ash_phoenix,
    :ecto,
    :ecto_sql,
    :phoenix,
    :smokestack,
    :spark,
  ],
  subdirectories: [
    "priv/*/migrations",
  ],
  plugins: [
    Phoenix.LiveView.HTMLFormatter,
    Spark.Formatter,
    FreedomFormatter,
  ],
  inputs: [
    "*.{heex,ex,exs}",
    "{config,lib,test}/**/*.{heex,ex,exs}",
    "priv/*/seeds.exs",
  ],
  # Additional options are now supported:
  trailing_comma: true,
  local_pipe_with_parens: true,
]
