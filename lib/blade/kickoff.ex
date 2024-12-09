defmodule Blade.Kickoff do
  use GenServer
  require Ecto.Query

  def start_link(_), do: GenServer.start_link(__MODULE__, nil)

  def init(_) do
    if !Blade.Repo.exists?(Blade.Note) do
      Blade.Workers.Index.schedule()
    end

    :ignore
  end
end
