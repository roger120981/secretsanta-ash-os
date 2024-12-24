locals_without_parens = [
  deleted_at: 0,
  deleted_at: 1,
  get_by: 1,
  get_by: 2,
  get_by_id: 1,
  list_actions: 0,
  list_actions: 1,
  list_by_ids: 0,
  list_by_ids: 1,
  search_action: 1,
  search_action: 2,
  search_calculation: 2,
  soft_delete: 0,
  soft_delete: 1,
  timestamp: 1,
  timestamp: 2,
]

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
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens,
  ],
]
