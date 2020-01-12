defmodule HealthWeb.PressureView do
  use HealthWeb, :view

  alias Health.DateTools
  alias HealthWeb.PressureLive

  def current_datetime(user) do
    DateTools.current_datetime(user)
  end

  def convert_datetime_to_local(time, user) do
    DateTools.convert(time, user)
  end

  def format_local_datetime(time, user) do
    DateTools.convert(time, user)
    |> DateTools.format()
  end

  def checked?(value) do
    case value do
      "true" -> "checked"
      "false" -> ""
    end
  end

  def per_page_selected(per_page, value) do
    {value_num, ""} = Integer.parse(value)

    cond do
      per_page == value_num ->
        "selected"

      true ->
        ""
    end
  end

  def get_user_day(conn, time) do
    user = conn.assigns.current_user

    time
    |> DateTools.convert(user)
    |> Timex.format!("{M}-{D}-{YYYY}")
  end

  def get_user_time_of_day(conn, time) do
    user = conn.assigns.current_user

    time
    |> DateTools.convert(user)
    |> Timex.format!("{h24}:{m} {Zabbr}")
  end

  def my_datetime_select(form, field, opts \\ []) do
    builder = fn b ->
      ~e"""
          Date: <%= b.(:month, []) %> / <%= b.(:day, []) %> / <%= b.(:year, []) %>
          Time: <%= b.(:hour, []) %> : <%= b.(:minute, []) %>
      """
    end

    datetime_select(form, field, [builder: builder] ++ opts)
  end
end
