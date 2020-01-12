defmodule HealthWeb.PressureControllerTest do
  use HealthWeb.ConnCase

  alias Health.Data.BloodPressures
  alias Health.TestHelper
  alias HealthWeb.PressureLive.Index

  @create_attrs %{
    diastolic: 42,
    heart_rate: 42,
    systolic: 42,
    time: ~U[2020-01-06 06:07:58.911000Z]
  }
  @update_attrs %{
    diastolic: 43,
    heart_rate: 43,
    systolic: 43,
    time: ~U[2020-01-06 06:07:58.911000Z]
  }
  @invalid_attrs %{
    diastolic: nil,
    heart_rate: nil,
    systolic: nil,
    time: ~U[2020-01-06 06:07:58.911000Z]
  }

  def fixture(:pressure) do
    user = TestHelper.create_user()
    {:ok, pressure} = BloodPressures.create_pressure(user, @create_attrs)
    pressure
  end

  describe "index" do
    test "lists all pressures", %{conn: conn} do
      conn = TestHelper.signin(conn)
      conn = get(conn, Routes.live_path(conn, Index))
      assert html_response(conn, 200) =~ "Blood Pressure Readings"
    end

    test "don't lists all pressures if not logged in", %{conn: conn} do
      conn = get(conn, Routes.live_path(conn, Index))
      not_signed_in(conn)
    end
  end

  describe "new pressure" do
    test "renders form", %{conn: conn} do
      conn = TestHelper.signin(conn)
      conn = get(conn, Routes.pressure_path(conn, :new))
      assert html_response(conn, 200) =~ "New Pressure"
    end

    test "don't render form if not logged in", %{conn: conn} do
      conn = get(conn, Routes.pressure_path(conn, :new))
      not_signed_in(conn)
    end
  end

  describe "create pressure" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = TestHelper.signin(conn)
      conn = post(conn, Routes.pressure_path(conn, :create), pressure: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.pressure_path(conn, :show, id)

      conn = get(conn, Routes.pressure_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Pressure"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = TestHelper.signin(conn)
      conn = post(conn, Routes.pressure_path(conn, :create), pressure: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Pressure"
    end

    test "don't render form if not logged in", %{conn: conn} do
      conn = post(conn, Routes.pressure_path(conn, :create), pressure: @create_attrs)
      not_signed_in(conn)
    end
  end

  describe "edit pressure" do
    setup [:create_pressure]

    test "renders form for editing chosen pressure", %{conn: conn, pressure: pressure} do
      conn = TestHelper.signin(conn)
      conn = get(conn, Routes.pressure_path(conn, :edit, pressure))
      assert html_response(conn, 200) =~ "Edit Pressure"
    end

    test "don't renders form for editing chosen pressure", %{conn: conn, pressure: pressure} do
      conn = get(conn, Routes.pressure_path(conn, :edit, pressure))
      not_signed_in(conn)
    end

    test "don't if not user", %{conn: conn, pressure: pressure} do
      conn = TestHelper.signin_other(conn)
      conn = get(conn, Routes.pressure_path(conn, :edit, pressure))
      unauthorized(conn)
    end
  end

  describe "update pressure" do
    setup [:create_pressure]

    test "redirects when data is valid", %{conn: conn, pressure: pressure} do
      conn = TestHelper.signin(conn)
      conn = put(conn, Routes.pressure_path(conn, :update, pressure), pressure: @update_attrs)
      assert redirected_to(conn) == Routes.pressure_path(conn, :show, pressure)

      conn = get(conn, Routes.pressure_path(conn, :show, pressure))
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, pressure: pressure} do
      conn = TestHelper.signin(conn)
      conn = put(conn, Routes.pressure_path(conn, :update, pressure), pressure: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Pressure"
    end

    test "don't if not logged in", %{conn: conn, pressure: pressure} do
      conn = put(conn, Routes.pressure_path(conn, :update, pressure), pressure: @update_attrs)
      not_signed_in(conn)
    end

    test "don't if not user", %{conn: conn, pressure: pressure} do
      conn = TestHelper.signin_other(conn)
      conn = put(conn, Routes.pressure_path(conn, :update, pressure), pressure: @update_attrs)
      unauthorized(conn)
    end
  end

  describe "delete pressure" do
    setup [:create_pressure]

    test "deletes chosen pressure", %{conn: conn, pressure: pressure} do
      conn = TestHelper.signin(conn)
      conn = delete(conn, Routes.pressure_path(conn, :delete, pressure))
      assert redirected_to(conn) == Routes.live_path(conn, Index)

      assert_error_sent 404, fn ->
        get(conn, Routes.pressure_path(conn, :show, pressure))
      end
    end

    test "don't if not logged in", %{conn: conn, pressure: pressure} do
      conn = delete(conn, Routes.pressure_path(conn, :delete, pressure))
      not_signed_in(conn)
    end

    test "don't if not user", %{conn: conn, pressure: pressure} do
      conn = TestHelper.signin_other(conn)
      conn = delete(conn, Routes.pressure_path(conn, :delete, pressure))
      unauthorized(conn)
    end
  end

  defp create_pressure(_) do
    pressure = fixture(:pressure)
    {:ok, pressure: pressure}
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
