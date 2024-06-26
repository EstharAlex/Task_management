defmodule TaskManagementWeb.Router do
  use TaskManagementWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TaskManagementWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TaskManagementWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.

  scope "/api", TaskManagementWeb do
    pipe_through :api
    resources "/users", UserController, except: [:new, :edit]
    # resources "/tasks", TaskController, except: [:new, :edit]

    post "/tasks", TaskController, :create
    get  "/tasks_for_user/:user_id", TaskController, :index
    get  "/tasks", TaskController, :list
    get  "/tasks/:id", TaskController, :show
    put "/tasks/:id", TaskController, :update
    delete "/tasks/:id", TaskController, :delete

    resources "/task_status_tracks", TaskStatusTrackController, except: [:new, :edit]
    get "/tasks/:task_id/status_tracks", TaskStatusTrackController, :index_for_task
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:task_management, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TaskManagementWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
