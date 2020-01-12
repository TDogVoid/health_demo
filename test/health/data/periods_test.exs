defmodule Health.Data.PeriodsTest do
  use Health.DataCase

  alias Health.Data.Periods
  alias Health.TestHelper

  describe "periods" do
    alias Health.Data.Periods.Period

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def period_fixture(attrs \\ %{}) do
      attrs =
        attrs
        |> Enum.into(@valid_attrs)

      {:ok, period} =
        TestHelper.create_user()
        |> Periods.create_period(attrs)

      period
    end

    test "list_periods/0 returns all periods" do
      period = period_fixture()
      assert Periods.list_periods() == [period]
    end

    test "get_period!/1 returns the period with given id" do
      period = period_fixture()
      assert Periods.get_period!(period.id) == period
    end

    test "create_period/1 with valid data creates a period" do
      user = TestHelper.create_user()
      assert {:ok, %Period{} = period} = Periods.create_period(user, @valid_attrs)
      assert period.name == "some name"
    end

    test "create_period/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Periods.create_period(@invalid_attrs)
    end

    test "update_period/2 with valid data updates the period" do
      period = period_fixture()
      assert {:ok, %Period{} = period} = Periods.update_period(period, @update_attrs)
      assert period.name == "some updated name"
    end

    test "update_period/2 with invalid data returns error changeset" do
      period = period_fixture()
      assert {:error, %Ecto.Changeset{}} = Periods.update_period(period, @invalid_attrs)
      assert period == Periods.get_period!(period.id)
    end

    test "delete_period/1 deletes the period" do
      period = period_fixture()
      assert {:ok, %Period{}} = Periods.delete_period(period)
      assert_raise Ecto.NoResultsError, fn -> Periods.get_period!(period.id) end
    end

    test "change_period/1 returns a period changeset" do
      period = period_fixture()
      assert %Ecto.Changeset{} = Periods.change_period(period)
    end
  end
end
