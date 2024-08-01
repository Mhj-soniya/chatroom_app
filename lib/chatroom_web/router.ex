defmodule ChatroomWeb.Router do
  alias ChatroomWeb.ChatLive
  use ChatroomWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ChatroomWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ChatroomWeb.Plug.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug ChatroomWeb.Plug.Auth
  end

  scope "/", ChatroomWeb do
    pipe_through :browser

    get "/", PageController, :home

    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create
    get "/login", LoginController, :new
    post "/login", LoginController, :authenticate

    get "/rooms", ChatController, :new
    post "/add/room", ChatController, :create

    live "/chats/:id", ChatLive, :index

  end


  # Other scopes may use custom stacks.
  # scope "/api", ChatroomWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:chatroom, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChatroomWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end