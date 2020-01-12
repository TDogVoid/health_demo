defmodule HealthWeb.PeriodView do
  use HealthWeb, :view

  alias HealthWeb.PeriodLive
  alias HealthWeb.PeriodLive.Index

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
end
