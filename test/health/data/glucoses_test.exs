defmodule Health.Data.GlucosesTest do
  use Health.DataCase

  alias Health.Data.Glucoses
  alias Health.TestHelper

  describe "glucoses" do
    alias Health.Data.Glucoses.Glucose

    @valid_attrs %{note: "some note", reading: 42, time: ~U[2020-01-06 06:28:34.171118Z]}
    @update_attrs %{note: "some updated note", reading: 43, time: ~U[2020-01-06 07:28:34.171118Z]}
    @invalid_attrs %{note: nil, reading: nil, time: nil}

    def glucose_fixture(attrs \\ %{}) do
      period = TestHelper.period_fixture()

      attrs =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:period_id, period.id)

      {:ok, glucose} =
        TestHelper.create_user()
        |> Glucoses.create_glucose(attrs)

      glucose
      |> Repo.preload(:period)
    end

    test "list_user_glucoses/1 returns all glucoses" do
      glucose = glucose_fixture()
      user = TestHelper.create_user()
      assert Glucoses.list_user_glucoses(user) == [glucose]
    end

    test "get_glucose!/1 returns the glucose with given id" do
      glucose = glucose_fixture()
      assert Glucoses.get_glucose!(glucose.id) == glucose
    end

    test "create_glucose/2 with valid data creates a glucose" do
      period = TestHelper.period_fixture()
      user = TestHelper.create_user()

      attrs =
        @valid_attrs
        |> Map.put(:period_id, period.id)

      assert {:ok, %Glucose{} = glucose} = Glucoses.create_glucose(user, attrs)
      assert glucose.note == "some note"
      assert glucose.reading == 42
      assert glucose.time == ~U[2020-01-06 06:28:34Z]
    end

    test "create_glucose/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Glucoses.create_glucose(@invalid_attrs)
    end

    test "update_glucose/2 with valid data updates the glucose" do
      glucose = glucose_fixture()
      assert {:ok, %Glucose{} = glucose} = Glucoses.update_glucose(glucose, @update_attrs)
      assert glucose.note == "some updated note"
      assert glucose.reading == 43
      assert glucose.time == ~U[2020-01-06 07:28:34Z]
    end

    test "update_glucose/2 with invalid data returns error changeset" do
      glucose = glucose_fixture()
      assert {:error, %Ecto.Changeset{}} = Glucoses.update_glucose(glucose, @invalid_attrs)
      assert glucose == Glucoses.get_glucose!(glucose.id)
    end

    test "delete_glucose/1 deletes the glucose" do
      glucose = glucose_fixture()
      assert {:ok, %Glucose{}} = Glucoses.delete_glucose(glucose)
      assert_raise Ecto.NoResultsError, fn -> Glucoses.get_glucose!(glucose.id) end
    end

    test "change_glucose/1 returns a glucose changeset" do
      glucose = glucose_fixture()
      assert %Ecto.Changeset{} = Glucoses.change_glucose(glucose)
    end
  end
end
