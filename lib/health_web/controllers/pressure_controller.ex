defmodule HealthWeb.PressureController do
  use HealthWeb, :controller

  alias Health.Data.BloodPressures
  alias HealthWeb.PressureLive
  alias Health.Data.BloodPressures.Pressure
  alias Health.DateTools
  alias Phoenix.LiveView

  plug :check_owner when action in [:update, :edit, :delete]

  def index(conn, _params) do
    user = conn.assigns.current_user

    LiveView.Controller.live_render(conn, HealthWeb.Pressure.IndexLive,
      session: %{user_id: user.id}
    )
  end

  def new(conn, _params) do
    changeset = BloodPressures.change_pressure(%Pressure{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pressure" => pressure_params}) do
    user = conn.assigns.current_user
    pressure_params = DateTools.convert_user_input_to_utc(user, pressure_params)

    case BloodPressures.create_pressure(user, pressure_params) do
      {:ok, pressure} ->
        conn
        |> put_flash(:info, "Pressure created successfully.")
        |> redirect(to: Routes.pressure_path(conn, :show, pressure))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    pressure = BloodPressures.get_pressure!(id)
    render(conn, "show.html", pressure: pressure)
  end

  def edit(conn, %{"id" => id}) do
    pressure = BloodPressures.get_pressure!(id)
    changeset = BloodPressures.change_pressure(pressure)
    render(conn, "edit.html", pressure: pressure, changeset: changeset)
  end

  def update(conn, %{"id" => id, "pressure" => pressure_params}) do
    pressure = BloodPressures.get_pressure!(id)
    user = conn.assigns.current_user
    pressure_params = DateTools.convert_user_input_to_utc(user, pressure_params)

    case BloodPressures.update_pressure(pressure, pressure_params) do
      {:ok, pressure} ->
        conn
        |> put_flash(:info, "Pressure updated successfully.")
        |> redirect(to: Routes.pressure_path(conn, :show, pressure))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", pressure: pressure, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    pressure = BloodPressures.get_pressure!(id)
    {:ok, _pressure} = BloodPressures.delete_pressure(pressure)

    conn
    |> put_flash(:info, "Pressure deleted successfully.")
    |> redirect(to: Routes.live_path(conn, PressureLive.Index))
  end

  defp check_owner(%{params: %{"id" => id}} = conn, _params) do
    user = conn.assigns.current_user

    if user && BloodPressures.get_pressure!(id).user_id == user.id do
      conn
    else
      conn
      |> put_flash(:error, "Unauthorized")
      |> redirect(to: Routes.live_path(conn, PressureLive.Index))
      |> halt()
    end
  end
end
