defmodule Health.Data.Glucoses.Glucose do
  use Ecto.Schema
  import Ecto.Changeset

  alias Health.Data.Periods.Period
  alias Health.Accounts.User

  schema "glucoses" do
    field :note, :string
    field :reading, :integer
    field :time, :utc_datetime
    belongs_to :period, Period
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(glucose, attrs) do
    glucose
    |> cast(attrs, [:reading, :time, :note, :period_id])
    |> validate_required([:reading, :time, :period_id])
  end
end
