defmodule HealthWeb.PageControllerTest do
  use HealthWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Health Vault"
  end
end
