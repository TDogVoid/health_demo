defmodule Health.Repo.Migrations.AddPeriodToGlucose do
  use Ecto.Migration

  def change do
    alter table(:glucoses) do
      add :period_id, references(:periods)
    end

    create index(:glucoses, [:period_id])
  end
end
