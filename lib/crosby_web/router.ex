defmodule CrosbyWeb.Router do
  use CrosbyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CrosbyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CrosbyWeb do
    pipe_through :browser

    live "/", HomeLive

    live "/category/:category", CategoryLive
  end

  scope "/api", CrosbyWeb do
    pipe_through :api

    get "/category/:category", Api, :category

    get "/playlists.zip", Api, :playlists
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:crosby, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CrosbyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
