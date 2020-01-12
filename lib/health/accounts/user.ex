defmodule Health.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Health.Accounts.Credential

  schema "users" do
    field :name, :string
    field :timezone, :string
    has_one :credential, Credential

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :timezone])
    |> validate_required([:name, :timezone])
    |> validate_timezone()
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2, required: true)
  end

  defp validate_timezone(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{timezone: timezone}} ->
        case Tzdata.zone_exists?(timezone) do
          true ->
            changeset

          false ->
            add_error(changeset, :timezone, "timezone error")
        end

      _ ->
        changeset
    end
  end
end
