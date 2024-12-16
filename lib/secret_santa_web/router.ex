defmodule SecretSantaWeb.Router do
  use SecretSantaWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SecretSantaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", SecretSantaWeb do
    pipe_through :browser

    get "/", PageController, :home

    scope "/a" do
      # sign_in_route(register_path: "/register", reset_path: "/reset")
      sign_in_route(on_mount: [{SecretSantaWeb.LiveUserAuth, :live_no_user}])
      sign_out_route AuthController
      auth_routes_for SecretSanta.Accounts.Account, to: AuthController
      reset_route []
    end

    scope "/" do
      ash_authentication_live_session :authentication_required,
        on_mount: {SecretSantaWeb.LiveUserAuth, :live_user_required} do
        # Group View
        scope "/groups" do
          # Index
          live "/", GroupLive.Index, :index
          live "/new", GroupLive.Index, :new
          live "/:id/edit", GroupLive.Index, :edit

          # Show
          live "/:id", GroupLive.Show, :show
          live "/:id/show/edit", GroupLive.Show, :edit
        end
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", SecretSantaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:secret_santa, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SecretSantaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
