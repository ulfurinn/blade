defmodule Blade.Migrate do
  use GenServer
  require Ecto.Query

  def start_link(_), do: GenServer.start_link(__MODULE__, nil)

  def init(_) do
    Blade.Release.migrate()
    Blade.Repo.delete_all(Ecto.Query.where(Oban.Job, [j], j.state == "executing"))

    :ignore
  end
end
