defmodule SecretSanta.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SecretSantaWeb.Telemetry,
      SecretSanta.Repo,
      {AshAuthentication.Supervisor, otp_app: :secret_santa},
      {DNSCluster, query: Application.get_env(:secret_santa, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SecretSanta.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SecretSanta.Finch},
      # Start to serve requests, typically the last entry
      SecretSantaWeb.Endpoint,
    ]

    setup_opentelemetry()

    opts = [strategy: :one_for_one, name: SecretSanta.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    SecretSantaWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @request_headers [
    "x-account-id",
    "x-group-id",
    "x-request-id",
  ]

  defp setup_opentelemetry() do
    OpentelemetryBandit.setup(
      opt_in_attrs: bandit_opt_in_attrs(),
      request_headers: @request_headers
    )

    OpentelemetryPhoenix.setup(adapter: :bandit)
    OpentelemetryEcto.setup([:secret_santa, :repo])
  end

  defp bandit_opt_in_attrs() do
    [
      :"client.port",
      :"http.request.body.size",
      :"http.response.body.size",
      :"network.local.address",
      :"network.local.port",
      :"network.transport",
    ]
  end
end
