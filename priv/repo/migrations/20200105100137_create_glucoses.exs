defmodule Health.Repo.Migrations.CreateGlucoses do
  use Ecto.Migration

  def change do
    create table(:glucoses) do
      add :reading, :integer, null: false
      add :time, :utc_datetime
      add :note, :text
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:glucoses, [:time])
    create index(:glucoses, [:reading])
    create index(:glucoses, [:user_id])
  end
end
