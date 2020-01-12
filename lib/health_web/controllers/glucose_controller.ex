defmodule HealthWeb.GlucoseController do
  use HealthWeb, :controller

  alias Health.Data.{Glucoses, Periods}
  alias Health.Data.Glucoses.Glucose
  alias Health.DateTools
  alias Phoenix.LiveView
  alias HealthWeb.GlucoseLive.Index

  plug :check_owner when action in [:update, :edit, :delete]

  def new(conn, _params) do
    changeset = Glucoses.change_glucose(%Glucose{})
    user = conn.assigns.current_user
    periods = Periods.list_user_periods(user)
    render(conn, "new.html", changeset: changeset, periods: periods)
  end

  def create(conn, %{"glucose" => glucose_params}) do
    user = conn.assigns.current_user
    glucose_params = DateTools.convert_user_input_to_utc(user, glucose_params)

    case Glucoses.create_glucose(user, glucose_params) do
      {:ok, glucose} ->
        conn
        |> put_flash(:info, "Glucose created successfully.")
        |> redirect(to: Routes.glucose_path(conn, :show, glucose))

      {:error, %Ecto.Changeset{} = changeset} ->
        user = conn.assigns.current_user
        periods = Periods.list_user_periods(user)
        render(conn, "new.html", changeset: changeset, periods: periods)
    end
  end

  def show(conn, %{"id" => id}) do
    glucose = Glucoses.get_glucose!(id)
    render(conn, "show.html", glucose: glucose)
  end

  def edit(conn, %{"id" => id}) do
    glucose = Glucoses.get_glucose!(id)
    changeset = Glucoses.change_glucose(glucose)
    user = conn.assigns.current_user
    periods = Periods.list_user_periods(user)

    render(conn, "edit.html", glucose: glucose, changeset: changeset, periods: periods)
  end

  def update(conn, %{"id" => id, "glucose" => glucose_params}) do
    glucose = Glucoses.get_glucose!(id)
    user = conn.assigns.current_user
    glucose_params = DateTools.convert_user_input_to_utc(user, glucose_params)

    case Glucoses.update_glucose(glucose, glucose_params) do
      {:ok, glucose} ->
        conn
        |> put_flash(:info, "Glucose updated successfully.")
        |> redirect(to: Routes.glucose_path(conn, :show, glucose))

      {:error, %Ecto.Changeset{} = changeset} ->
        user = conn.assigns.current_user
        periods = Periods.list_user_periods(user)
        render(conn, "edit.html", glucose: glucose, changeset: changeset, periods: periods)
    end
  end

  def delete(conn, %{"id" => id}) do
    glucose = Glucoses.get_glucose!(id)
    {:ok, _glucose} = Glucoses.delete_glucose(glucose)

    conn
    |> put_flash(:info, "Glucose deleted successfully.")
    |> redirect(to: Routes.live_path(conn, Index))
  end

  defp check_owner(%{params: %{"id" => id}} = conn, _params) do
    user = conn.assigns.current_user

    if user && Glucoses.get_glucose!(id).user_id == user.id do
      conn
    else
      conn
      |> put_flash(:error, "Unauthorized")
      |> redirect(to: Routes.live_path(conn, Index))
      |> halt()
    end
  end
end
