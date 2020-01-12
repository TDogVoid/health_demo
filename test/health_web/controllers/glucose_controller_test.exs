defmodule HealthWeb.GlucoseControllerTest do
  use HealthWeb.ConnCase

  alias Health.Data.Glucoses
  alias Health.TestHelper
  alias HealthWeb.GlucoseLive.Index

  @create_attrs %{note: "some note", reading: 42, time: ~U[2020-01-06 06:07:58.911000Z]}
  @update_attrs %{note: "some updated note", reading: 43, time: ~U[2020-01-06 07:07:58.911000Z]}
  @invalid_attrs %{note: nil, reading: nil, time: ~U[2020-01-06 07:07:58.911000Z]}

  def fixture(:glucose) do
    user = TestHelper.create_user()
    period = TestHelper.period_fixture()

    attrs =
      @create_attrs
      |> Map.put(:period_id, period.id)

    {:ok, glucose} = Glucoses.create_glucose(user, attrs)
    glucose
  end

  describe "index" do
    test "lists all glucoses", %{conn: conn} do
      conn = TestHelper.signin(conn)
      conn = get(conn, Routes.live_path(conn, Index))
      assert html_response(conn, 200) =~ "Glucose Readings"
    end

    test "don't render if not signed in", %{conn: conn} do
      conn = get(conn, Routes.live_path(conn, Index))
      not_signed_in(conn)
    end
  end

  describe "new glucose" do
    test "renders form", %{conn: conn} do
      conn = TestHelper.signin(conn)
      conn = get(conn, Routes.glucose_path(conn, :new))
      assert html_response(conn, 200) =~ "New Glucose"
    end

    test "don't render if not signed in", %{conn: conn} do
      conn = get(conn, Routes.glucose_path(conn, :new))
      not_signed_in(conn)
    end
  end

  describe "create glucose" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = TestHelper.signin(conn)
      period = TestHelper.period_fixture()

      attrs =
        @create_attrs
        |> Map.put(:period_id, period.id)

      conn = post(conn, Routes.glucose_path(conn, :create), glucose: attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.glucose_path(conn, :show, id)

      conn = get(conn, Routes.glucose_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Glucose"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = TestHelper.signin(conn)
      period = TestHelper.period_fixture()

      attrs =
        @invalid_attrs
        |> Map.put(:period_id, period.id)

      conn = post(conn, Routes.glucose_path(conn, :create), glucose: attrs)
      assert html_response(conn, 200) =~ "New Glucose"
    end

    test "don't render if not signed in", %{conn: conn} do
      period = TestHelper.period_fixture()

      attrs =
        @create_attrs
        |> Map.put(:period_id, period.id)

      conn = post(conn, Routes.glucose_path(conn, :create), glucose: attrs)

      not_signed_in(conn)
    end
  end

  describe "edit glucose" do
    setup [:create_glucose]

    test "renders form for editing chosen glucose", %{conn: conn, glucose: glucose} do
      conn = TestHelper.signin(conn)
      conn = get(conn, Routes.glucose_path(conn, :edit, glucose))
      assert html_response(conn, 200) =~ "Edit Glucose"
    end

    test "don't render if not signed in", %{conn: conn, glucose: glucose} do
      conn = get(conn, Routes.glucose_path(conn, :edit, glucose))
      not_signed_in(conn)
    end

    test "don't render other users glucose", %{conn: conn, glucose: glucose} do
      conn = TestHelper.signin_other(conn)
      conn = get(conn, Routes.glucose_path(conn, :edit, glucose))
      unauthorized(conn)
    end
  end

  describe "update glucose" do
    setup [:create_glucose]

    test "redirects when data is valid", %{conn: conn, glucose: glucose} do
      conn = TestHelper.signin(conn)
      conn = put(conn, Routes.glucose_path(conn, :update, glucose), glucose: @update_attrs)
      assert redirected_to(conn) == Routes.glucose_path(conn, :show, glucose)

      conn = get(conn, Routes.glucose_path(conn, :show, glucose))
      assert html_response(conn, 200) =~ "some updated note"
    end

    test "renders errors when data is invalid", %{conn: conn, glucose: glucose} do
      conn = TestHelper.signin(conn)
      conn = put(conn, Routes.glucose_path(conn, :update, glucose), glucose: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Glucose"
    end

    test "don't render if not signed in", %{conn: conn, glucose: glucose} do
      conn = put(conn, Routes.glucose_path(conn, :update, glucose), glucose: @update_attrs)
      not_signed_in(conn)
    end

    test "don't update other users glucose", %{conn: conn, glucose: glucose} do
      conn = TestHelper.signin_other(conn)
      conn = put(conn, Routes.glucose_path(conn, :update, glucose), glucose: @update_attrs)
      unauthorized(conn)
    end
  end

  describe "delete glucose" do
    setup [:create_glucose]

    test "deletes chosen glucose", %{conn: conn, glucose: glucose} do
      conn = TestHelper.signin(conn)
      conn = delete(conn, Routes.glucose_path(conn, :delete, glucose))
      assert redirected_to(conn) == Routes.live_path(conn, Index)

      assert_error_sent 404, fn ->
        get(conn, Routes.glucose_path(conn, :show, glucose))
      end
    end

    test "don't if not signed in", %{conn: conn, glucose: glucose} do
      conn = delete(conn, Routes.glucose_path(conn, :delete, glucose))
      not_signed_in(conn)
    end

    test "don't delete other users glucose", %{conn: conn, glucose: glucose} do
      conn = TestHelper.signin_other(conn)
      conn = get(conn, Routes.glucose_path(conn, :edit, glucose))
      unauthorized(conn)
    end
  end

  defp create_glucose(_) do
    glucose = fixture(:glucose)
    {:ok, glucose: glucose}
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
