defmodule HealthWeb.UserControllerTest do
  use HealthWeb.ConnCase

  alias Health.Accounts
  alias Health.TestHelper

  @create_attrs %{
    name: "some name",
    timezone: "America/New_York",
    credential: %{email: "user@user.com", password: "password", password_confirmation: "password"}
  }
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = TestHelper.signin(conn)
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end

    test "don't list users if not signed in", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      not_signed_in(conn)
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_path(conn, :show, id)

      conn = get(conn, Routes.user_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = TestHelper.signin(conn)
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "don't render form if not signed in", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      not_signed_in(conn)
    end

    test "don't if not owner", %{conn: conn, user: user} do
      conn = TestHelper.signin_other(conn)
      conn = get(conn, Routes.user_path(conn, :edit, user))
      unauthorized(conn)
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = TestHelper.signin(conn)
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = TestHelper.signin(conn)
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end

    test "don't if not signed in", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      not_signed_in(conn)
    end

    test "don't if not owner", %{conn: conn, user: user} do
      conn = TestHelper.signin_other(conn)
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      unauthorized(conn)
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = TestHelper.signin(conn)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end

    test "don't if not signed in", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      not_signed_in(conn)
    end

    test "don't if not owner", %{conn: conn, user: user} do
      conn = TestHelper.signin_other(conn)
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      unauthorized(conn)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp not_signed_in(conn) do
    assert redirected_to(conn) == Routes.page_path(conn, :index)

    conn = get(conn, Routes.page_path(conn, :index))
    assert html_response(conn, 200) =~ "Login Required"
  end

  defp unauthorized(conn) do
    user = conn.assigns.current_user
    assert redirected_to(conn) == Routes.user_path(conn, :show, user)

    conn = get(conn, Routes.user_path(conn, :show, user))
    assert html_response(conn, 200) =~ "Unauthorized"
  end
end
