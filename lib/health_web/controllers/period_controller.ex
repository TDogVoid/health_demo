defmodule HealthWeb.PeriodController do
  use HealthWeb, :controller

  alias Health.Data.Periods
  alias Health.Data.Periods.Period
  alias Phoenix.LiveView
  alias HealthWeb.PeriodLive

  plug :check_owner when action in [:update, :edit, :delete]

  def index(conn, _params) do
    user = conn.assigns.current_user

    LiveView.Controller.live_render(conn, HealthWeb.Periods.IndexLive,
      session: %{user_id: user.id}
    )
  end

  def new(conn, _params) do
    changeset = Periods.change_period(%Period{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"period" => period_params}) do
    user = conn.assigns.current_user

    case Periods.create_period(user, period_params) do
      {:ok, period} ->
        conn
        |> put_flash(:info, "Period created successfully.")
        |> redirect(to: Routes.period_path(conn, :show, period))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    period = Periods.get_period!(id)
    render(conn, "show.html", period: period)
  end

  def edit(conn, %{"id" => id}) do
    period = Periods.get_period!(id)
    changeset = Periods.change_period(period)
    render(conn, "edit.html", period: period, changeset: changeset)
  end

  def update(conn, %{"id" => id, "period" => period_params}) do
    period = Periods.get_period!(id)

    case Periods.update_period(period, period_params) do
      {:ok, period} ->
        conn
        |> put_flash(:info, "Period updated successfully.")
        |> redirect(to: Routes.period_path(conn, :show, period))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", period: period, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    period = Periods.get_period!(id)
    {:ok, _period} = Periods.delete_period(period)

    conn
    |> put_flash(:info, "Period deleted successfully.")
    |> redirect(to: Routes.live_path(conn, PeriodLive.Index))
  end

  defp check_owner(%{params: %{"id" => id}} = conn, _params) do
    user = conn.assigns.current_user

    if user && Periods.get_period!(id).user_id == user.id do
      conn
    else
      conn
      |> put_flash(:error, "Unauthorized")
      |> redirect(to: Routes.live_path(conn, PeriodLive.Index))
      |> halt()
    end
  end
end
