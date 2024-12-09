Postgrex.Types.define(
  Blade.PgTypes,
  Pgvector.extensions() ++ Ecto.Adapters.Postgres.extensions(),
  []
)
