defmodule HealthWeb.PeriodLive.Index do
  use Phoenix.LiveView
  alias HealthWeb.Router.Helpers, as: Routes

  alias Health.Data.Periods
  alias Health.Accounts
  alias HealthWeb.PeriodView

  def render(assigns) do
    PeriodView.render("index.html", assigns)
  end

  def mount(%{user_id: user_id}, socket) do
    user = Accounts.get_user!(user_id)

    {:ok,
     socket
     |> assign(:page, 1)
     |> assign(:per_page, 30)
     |> assign(:current_user, user)
     |> fetch()}
  end

  def handle_event("show_cols", checked_cols, socket) do
    {:noreply, assign(socket, show_cols: checked_cols)}
  end

  def handle_event("per_page", per_page, socket) do
    %{"per_page" => per_page_str} = per_page

    {per_page_num, ""} = Integer.parse(per_page_str)
    {:noreply, socket |> assign(:per_page, per_page_num) |> fetch()}
  end

  def handle_event("show", %{"id" => id}, socket) do
    {:noreply, live_redirect(socket, to: Routes.period_path(socket, :show, id))}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply, live_redirect(socket, to: Routes.period_path(socket, :edit, id))}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    period = Periods.get_period!(id)
    user = socket.assigns.current_user

    if user.id == period.user_id do
      Periods.delete_period(period)
    end

    {:noreply, socket |> fetch()}
  end

  def handle_params(params, _uri, socket) do
    {page_num, ""} = Integer.parse(params["page"] || "1")

    {:noreply,
     socket
     |> assign(page: page_num)
     |> fetch()}
  end

  defp fetch(socket) do
    cols = [
      {"name", "Name"},
      {"options", "Options"}
    ]

    per_page_options = ["30", "60", "90"]

    show_cols = Enum.map(cols, fn {col, _} -> {col, "true"} end) |> Enum.into(%{})

    %{page: page, per_page: per_page, current_user: user} = socket.assigns

    assign(socket,
      rows: Periods.list_user_periods(page, per_page, user),
      show_cols: show_cols,
      cols: cols,
      per_page_options: per_page_options
    )
  end
end
