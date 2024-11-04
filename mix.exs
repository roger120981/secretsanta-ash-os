defmodule SecretSanta.MixProject do
  use Mix.Project

  def project do
    [
      app: :secret_santa,
      version: version(),
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: releases(),
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SecretSanta.Application, []},
      extra_applications: [:logger, :runtime_tools],
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "priv/repo/seeds"]
  defp elixirc_paths(_), do: ["lib"]

  defp version() do
    [
      read_version_file(),
      resolve_git_sha_env(),
    ]
    |> Stream.reject(&is_nil(&1) or &1 == "")
    |> Enum.join("-")
  end

  defp releases() do
    [
      secret_santa: [
        version: version(),
        applications: [secret_santa: :permanent],
        include_executables_for: [:unix],
        include_erts: true,
        strip_beams: true,
        quiet: false,
        steps: [:assemble, :tar],
      ]
    ]
  end

  defp read_version_file() do
    Path.join(__DIR__, "VERSION")
    |> File.read!()
    |> String.trim()
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps() do
    [
      # ash
      {:ash, "~> 3.4"},
      {:ash_authentication, "~> 4.0"},
      {:ash_authentication_phoenix, "~> 2.0"},
      {:ash_phoenix, "~> 2.0"},
      {:ash_postgres, "~> 2.0"},

      # certificates
      {:castore, "~> 1.0", override: true},

      # clustering
      {:dns_cluster, "~> 0.1.1"},

      # data & formats
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:nanoid, "~> 2.1"},
      {:number, "~> 1.0"},
      {:picosat_elixir, "~> 0.2.3"},

      # database stuff
      {:ecto_sql, "~> 3.10"},
      {:phoenix_ecto, "~> 4.4"},
      {:postgrex, ">= 0.0.0"},

      # email
      {:swoosh, "~> 1.3"},

      # http client
      {:finch, "~> 0.18"},

      # http server
      {:bandit, "~> 1.0"},
      {:petal_components, "~> 2.4"},
      {:phoenix, "~> 1.7.9"},
      {:phoenix_html, "~> 4.0"},
      {:plug_early_hints, "~> 0.1"},
      {:remote_ip, "~> 1.0"},

      # liveview
      {:phoenix_live_view, "~> 1.0.0-rc.6", override: true},

      # oban
      {:oban, "~> 2.16"},

      # telemetry
      {:telemetry, "~> 1.0"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},

      # overrides that aren't actual deps
      # {:sourceror, "~> 0.14", override: true},

      # tools
      {:credo, "~> 1.7", only: :dev},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:faker, ">= 0.0.0", only: [:test]},
      {:floki, ">= 0.36.2", only: :test},
      {:freedom_formatter, ">= 2.0.0", only: :dev},
      {:hammox, "~> 0.7.0", only: :test},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.5",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:smokestack, "~> 0.9", only: [:dev, :test]},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      seed: ["run priv/repo/seeds.exs"],
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
    ]
  end

  defp resolve_git_sha_env() do
    System.get_env("GIT_VERSION_SHA", "dev")
    |> String.trim()
  end
end
