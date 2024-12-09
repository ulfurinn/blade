defmodule Blade.Repo.Migrations.CreateExtension do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS vector", "DROP EXTENSION vector"
  end
end
