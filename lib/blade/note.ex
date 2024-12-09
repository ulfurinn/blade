defmodule Blade.Note do
  use Ecto.Schema

  @primary_key {:id, Uniq.UUID, version: 7, autogenerate: true}
  schema "notes" do
    field :filepath, :string
    field :checksum, :string
    field :embedding, Pgvector.Ecto.Vector
  end
end
