defmodule Crosby.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :path, :string
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:entries, [:category_id])
  end
end
