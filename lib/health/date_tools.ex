defmodule Health.DateTools do
  def current_datetime(user) do
    # needs to return
    # {{@current_year, @current_month, @current_day}, 
    # {@current_hour, @current_minute, @current_second}}
    time = Timex.now(user.timezone)

    {{time.year, time.month, time.day}, {time.hour, time.minute, time.second}}
  end

  def convert(time, user) do
    time
    |> Timex.Timezone.convert(user.timezone)
  end

  def format(time) do
    time
    |> Timex.format!("{M}-{D}-{YYYY} {h24}:{m} {Zabbr}")
  end

  def format_date(time) do
    time
    |> Timex.format!("{M}-{D}-{YYYY}")
  end

  def format_time(time) do
    time
    |> Timex.format!("{h24}:{m} {Zabbr}")
  end

  def convert_user_input_to_utc(user, params) do
    time =
      params["time"]
      |> Timex.to_datetime(user.timezone)

    %{params | "time" => time}
  end
end
