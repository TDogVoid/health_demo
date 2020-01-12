defmodule HealthWeb.GlucoseView do
  use HealthWeb, :view

  alias Health.DateTools
  alias HealthWeb.GlucoseLive

  def low(data) do
    if data != [] do
      data
      |> get_list_of_readings()
      |> Enum.min()
    end
  end

  def high(data) do
    if data != [] do
      data
      |> get_list_of_readings()
      |> Enum.max()
    end
  end

  def average(data) do
    if data != [] do
      list =
        data
        |> get_list_of_readings()

      list
      |> Enum.sum()
      |> Kernel.div(Enum.count(list))
    end
  end

  def get_list_of_readings(data) do
    for d <- data do
      d.reading
    end
  end

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
