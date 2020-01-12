defmodule Health.Data.BloodPressuresTest do
  use Health.DataCase

  alias Health.Data.BloodPressures
  alias Health.TestHelper

  describe "pressures" do
    alias Health.Data.BloodPressures.Pressure

    @valid_attrs %{diastolic: 42, heart_rate: 42, systolic: 42, time: "2010-04-17T14:00:00Z"}
    @update_attrs %{diastolic: 43, heart_rate: 43, systolic: 43, time: "2011-05-18T15:01:01Z"}
    @invalid_attrs %{diastolic: nil, heart_rate: nil, systolic: nil, time: nil}

    def pressure_fixture(attrs \\ %{}) do
      attrs =
        attrs
        |> Enum.into(@valid_attrs)

      {:ok, pressure} =
        TestHelper.create_user()
        |> BloodPressures.create_pressure(attrs)

      pressure
    end

    test "list_pressures/0 returns all pressures" do
      pressure = pressure_fixture()
      assert BloodPressures.list_pressures() == [pressure]
    end

    test "get_pressure!/1 returns the pressure with given id" do
      pressure = pressure_fixture()
      assert BloodPressures.get_pressure!(pressure.id) == pressure
    end

    test "create_pressure/2 with valid data creates a pressure" do
      user = TestHelper.create_user()
      assert {:ok, %Pressure{} = pressure} = BloodPressures.create_pressure(user, @valid_attrs)
      assert pressure.diastolic == 42
      assert pressure.heart_rate == 42
      assert pressure.systolic == 42
      assert pressure.time == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_pressure/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BloodPressures.create_pressure(@invalid_attrs)
    end

    test "update_pressure/2 with valid data updates the pressure" do
      pressure = pressure_fixture()

      assert {:ok, %Pressure{} = pressure} =
               BloodPressures.update_pressure(pressure, @update_attrs)

      assert pressure.diastolic == 43
      assert pressure.heart_rate == 43
      assert pressure.systolic == 43
      assert pressure.time == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_pressure/2 with invalid data returns error changeset" do
      pressure = pressure_fixture()

      assert {:error, %Ecto.Changeset{}} =
               BloodPressures.update_pressure(pressure, @invalid_attrs)

      assert pressure == BloodPressures.get_pressure!(pressure.id)
    end

    test "delete_pressure/1 deletes the pressure" do
      pressure = pressure_fixture()
      assert {:ok, %Pressure{}} = BloodPressures.delete_pressure(pressure)
      assert_raise Ecto.NoResultsError, fn -> BloodPressures.get_pressure!(pressure.id) end
    end

    test "change_pressure/1 returns a pressure changeset" do
      pressure = pressure_fixture()
      assert %Ecto.Changeset{} = BloodPressures.change_pressure(pressure)
    end
  end
end
