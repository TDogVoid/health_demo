defmodule HealthWeb.GlucoseLive.Index do
  use Phoenix.LiveView
  alias HealthWeb.Router.Helpers, as: Routes

  alias Health.Data.Glucoses
  alias Health.Accounts
  alias HealthWeb.GlucoseView

  def render(assigns) do
    GlucoseView.render("index.html", assigns)
  end

  def mount(%{user_id: user_id}, socket) do
    user = Accounts.get_user!(user_id)

    start_date =
      user.timezone
      |> Timex.now()
      |> Timex.shift(days: -90)
      |> Timex.to_date()

    end_date =
      user.timezone
      |> Timex.now()
      |> Timex.to_date()

    {:ok,
     socket
     |> assign(:current_user, user)
     |> assign(:start_date, start_date)
     |> assign(:end_date, end_date)
     |> fetch()}
  end

  def handle_event("date_range", value, socket) do
    %{"range" => %{"end" => end_date, "start" => start_date}} = value

    {:noreply,
     socket
     |> assign(:start_date, start_date)
     |> assign(:end_date, end_date)
     |> fetch()}
  end

  def handle_event("show_cols", checked_cols, socket) do
    {:noreply, assign(socket, show_cols: checked_cols)}
  end

  def handle_event("show", %{"id" => id}, socket) do
    {:noreply, live_redirect(socket, to: Routes.glucose_path(socket, :show, id))}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, live_redirect(socket, to: Routes.glucose_path(socket, :edit, id))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    glucose = Glucoses.get_glucose!(id)
    user = socket.assigns.current_user

    if user.id == glucose.user_id do
      Glucoses.delete_glucose(glucose)
    end

    {:noreply, socket |> fetch()}
  end

  defp fetch(socket) do
    cols = [
      {"reading", "Reading"},
      {"period", "Period"},
      {"date", "Date"},
      {"time", "Time"},
      {"note", "Note"},
      {"options", "Options"}
    ]

    show_cols = Enum.map(cols, fn {col, _} -> {col, "true"} end) |> Enum.into(%{})

    %{start_date: start_date, end_date: end_date, current_user: user} = socket.assigns
    start_date = convert_date(start_date)
    end_date = convert_date(end_date)

    assign(socket,
      rows: Glucoses.list_user_glucoses(start_date, end_date, user),
      show_cols: show_cols,
      cols: cols
    )
  end

  defp convert_date(date) when is_bitstring(date) do
    date
    |> Timex.parse!("{YYYY}-{0M}-{D}")
    |> Timex.to_datetime("UTC")
  end

  defp convert_date(date) do
    date
    |> Timex.to_datetime("UTC")
  end
end
