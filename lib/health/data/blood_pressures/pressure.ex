defmodule Health.Data.BloodPressures.Pressure do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pressures" do
    field :diastolic, :integer
    field :heart_rate, :integer
    field :systolic, :integer
    field :time, :utc_datetime
    field :note, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(pressure, attrs) do
    pressure
    |> cast(attrs, [:systolic, :diastolic, :heart_rate, :time, :note])
    |> validate_required([:systolic, :diastolic, :heart_rate, :time])
  end
end
