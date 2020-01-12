defmodule Health.TestHelper do
  alias Health.Accounts
  alias Health.Data.Periods
  import Plug.Test

  @user_attrs %{
    name: "some name",
    timezone: "America/New_York",
    credential: %{email: "user@user.com", password: "password", password_confirmation: "password"}
  }
  @period_attrs %{name: "some name"}
  @other_user_attrs %{
    name: "some name",
    timezone: "America/New_York",
    credential: %{
      email: "other@user.com",
      password: "password",
      password_confirmation: "password"
    }
  }

  defp user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@user_attrs)
      |> Accounts.create_user()

    credential =
      user
      |> Map.get(:credential)
      |> Map.put(:password, nil)
      |> Map.put(:password_confirmation, nil)

    user = Map.put(user, :credential, credential)

    user
  end

  def create_user(attrs) do
    case Accounts.get_user_by_email(attrs.credential.email) do
      nil ->
        user_fixture(attrs)

      user ->
        user
    end
  end

  def create_user() do
    attrs = @user_attrs

    case Accounts.get_user_by_email(attrs.credential.email) do
      nil ->
        user_fixture(attrs)

      user ->
        user
    end
  end

  def signin(conn) do
    user = create_user()

    conn
    |> test_session(user)
  end

  def signin_other(conn) do
    user = create_user(@other_user_attrs)

    conn
    |> test_session(user)
  end

  defp test_session(conn, user) do
    conn
    |> init_test_session(user_id: user.id)
  end

  def period_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(@period_attrs)

    {:ok, period} =
      create_user()
      |> Periods.create_period(attrs)

    period
  end
end
