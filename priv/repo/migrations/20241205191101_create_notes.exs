defmodule Blade.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes) do
      add :filepath, :text
      add :checksum, :text
      add :embedding, :vector, size: 768
    end
  end
end
