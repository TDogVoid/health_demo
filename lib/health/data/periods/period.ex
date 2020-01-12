defmodule Health.Data.Periods.Period do
  use Ecto.Schema
  import Ecto.Changeset

  alias Health.Data.Glucoses.Glucose
  alias Health.Accounts.User

  schema "periods" do
    field :name, :string
    has_many :glucoses, Glucose
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(period, attrs) do
    period
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
