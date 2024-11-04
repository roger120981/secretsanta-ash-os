defmodule SecretSantaWeb.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :secret_santa

  # PlugEarlyHints
  plug PlugEarlyHints,
    # List all resources that will be needed later when rendering page
    paths: [
      # External resources that will be connected to as we will use
      # different resources from it. It will speedup as the TLS handshake
      # will be already ended, so we will be able to fetch resources
      # right away
      "https://unpkg.com": [rel: "preconnect"],
      "https://unpkg.com/@alpinejs/collapse@3.x.x/dist/cdn.min.js": [rel: "preload", as: "script"],
      "https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js": [rel: "preload", as: "script"],

      # "Regular" resources. We need to set `:as` to inform the client
      # (browser) what kinf of resource it is, so it will be able to
      # properly connect them
      "/css/app.css": [rel: "preload", as: "style"],
      "/js/app.js": [rel: "preload", as: "script"],

      # Preloading fonts will require additional `:type` and `:crossorgin`
      # to allow CSS engine to properly detect when apply the resource as
      # well as to prevent double load.

      # "/fonts/recursive.woff2": [
      #   rel: "preload",
      #   as: "font",
      #   crossorgin: :anonymous,
      #   type: "font/woff2"
      # ]
    ]

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_secret_santa_key",
    signing_salt: "CdtTuCCi",
    same_site: "Lax",
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :secret_santa,
    gzip: false,
    only: SecretSantaWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :secret_santa
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug SecretSantaWeb.Plugs.RemoteIp
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug SecretSantaWeb.Router
end
