defmodule Health.Repo.Migrations.CreatePressures do
  use Ecto.Migration

  def change do
    create table(:pressures) do
      add :systolic, :integer
      add :diastolic, :integer
      add :heart_rate, :integer
      add :time, :utc_datetime
      add :note, :text
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:pressures, [:user_id])
    create index(:pressures, [:time])
    create index(:pressures, [:systolic])
    create index(:pressures, [:diastolic])
    create index(:pressures, [:heart_rate])
  end
end
