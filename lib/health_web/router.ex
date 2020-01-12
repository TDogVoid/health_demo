defmodule HealthWeb.Router do
  use HealthWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug HealthWeb.CSPHeader
    plug :assign_user
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HealthWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/session", SessionController

    if Mix.env() != :prod do
      resources "/users", UserController, only: [:new, :create]
    end
  end

  scope "/v/", HealthWeb do
    pipe_through [:browser, :authenticate_user]

    resources "/users", UserController
    resources "/glucoses", GlucoseController, except: [:index]
    resources "/periods", PeriodController, except: [:index]
    resources "/pressures", PressureController, except: [:index]
    live "/glucoses", GlucoseLive.Index, session: [:user_id]
    live "/glucoses/page/:page", GlucoseLive.Index, session: [:user_id]
    live "/pressures/page/:page", PressureLive.Index, session: [:user_id]
    live "/pressures", PressureLive.Index, session: [:user_id]
    live "/periods", PeriodLive.Index, session: [:user_id]
    live "/periods/page/:page", PeriodLive.Index, session: [:user_id]
  end

  defp assign_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        conn

      user_id ->
        assign(conn, :current_user, Health.Accounts.get_user!(user_id))
    end
  end

  defp authenticate_user(conn, _) do
    case conn.assigns[:current_user] do
      %Health.Accounts.User{} ->
        conn

      _ ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Login Required")
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", HealthWeb do
  #   pipe_through :api
  # end
end
