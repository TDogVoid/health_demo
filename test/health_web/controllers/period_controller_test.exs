defmodule HealthWeb.PeriodControllerTest do
  use HealthWeb.ConnCase

  alias Health.Data.Periods
  alias Health.TestHelper
  alias HealthWeb.PeriodLive.Index

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:period) do
    user = TestHelper.create_user()
    {:ok, period} = Periods.create_period(user, @create_attrs)
    period
  end

  describe "index" do
    test "lists all periods", %{conn: conn} do
      conn = TestHelper.signin(conn)
      conn = get(conn, Routes.live_path(conn, Index))
      assert html_response(conn, 200) =~ "Listing Periods"
    end

    test "don't lists all periods if not logged in", %{conn: conn} do
      conn = get(conn, Routes.live_path(conn, Index))
      not_signed_in(conn)
    end
  end

  describe "new period" do
    test "renders form", %{conn: conn} do
      conn = TestHelper.signin(conn)
      conn = get(conn, Routes.period_path(conn, :new))
      assert html_response(conn, 200) =~ "New Period"
    end

    test "don't if not logged in", %{conn: conn} do
      conn = get(conn, Routes.period_path(conn, :new))
      not_signed_in(conn)
    end
  end

  describe "create period" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = TestHelper.signin(conn)
      conn = post(conn, Routes.period_path(conn, :create), period: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.period_path(conn, :show, id)

      conn = get(conn, Routes.period_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Period"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = TestHelper.signin(conn)
      conn = post(conn, Routes.period_path(conn, :create), period: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Period"
    end

    test "don't if not logged in", %{conn: conn} do
      conn = post(conn, Routes.period_path(conn, :create), period: @create_attrs)
      not_signed_in(conn)
    end
  end

  describe "edit period" do
    setup [:create_period]

    test "renders form for editing chosen period", %{conn: conn, period: period} do
      conn = TestHelper.signin(conn)
      conn = get(conn, Routes.period_path(conn, :edit, period))
      assert html_response(conn, 200) =~ "Edit Period"
    end

    test "don't if not logged in", %{conn: conn, period: period} do
      conn = get(conn, Routes.period_path(conn, :edit, period))
      not_signed_in(conn)
    end

    test "don't if not owner", %{conn: conn, period: period} do
      conn = TestHelper.signin_other(conn)
      conn = get(conn, Routes.period_path(conn, :edit, period))
      unauthorized(conn)
    end
  end

  describe "update period" do
    setup [:create_period]

    test "redirects when data is valid", %{conn: conn, period: period} do
      conn = TestHelper.signin(conn)
      conn = put(conn, Routes.period_path(conn, :update, period), period: @update_attrs)
      assert redirected_to(conn) == Routes.period_path(conn, :show, period)

      conn = get(conn, Routes.period_path(conn, :show, period))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, period: period} do
      conn = TestHelper.signin(conn)
      conn = put(conn, Routes.period_path(conn, :update, period), period: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Period"
    end

    test "don't if not logged in", %{conn: conn, period: period} do
      conn = put(conn, Routes.period_path(conn, :update, period), period: @update_attrs)
      not_signed_in(conn)
    end

    test "don't if not owner", %{conn: conn, period: period} do
      conn = TestHelper.signin_other(conn)
      conn = put(conn, Routes.period_path(conn, :update, period), period: @update_attrs)
      unauthorized(conn)
    end
  end

  describe "delete period" do
    setup [:create_period]

    test "deletes chosen period", %{conn: conn, period: period} do
      conn = TestHelper.signin(conn)
      conn = delete(conn, Routes.period_path(conn, :delete, period))
      assert redirected_to(conn) == Routes.live_path(conn, Index)

      assert_error_sent 404, fn ->
        get(conn, Routes.period_path(conn, :show, period))
      end
    end

    test "don't if not logged in", %{conn: conn, period: period} do
      conn = delete(conn, Routes.period_path(conn, :delete, period))
      not_signed_in(conn)
    end

    test "don't if not owner", %{conn: conn, period: period} do
      conn = TestHelper.signin_other(conn)
      conn = delete(conn, Routes.period_path(conn, :delete, period))
      unauthorized(conn)
    end
  end

  defp create_period(_) do
    period = fixture(:period)
    {:ok, period: period}
  end

  defp not_signed_in(conn) do
    assert redirected_to(conn) == Routes.page_path(conn, :index)

    conn = get(conn, Routes.page_path(conn, :index))
    assert html_response(conn, 200) =~ "Login Required"
  end

  defp unauthorized(conn) do
    assert redirected_to(conn) == Routes.live_path(conn, Index)

    conn = get(conn, Routes.live_path(conn, Index))
    assert html_response(conn, 200) =~ "Unauthorized"
  end
end
