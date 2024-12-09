defmodule Blade.Workers.Prune do
  use Oban.Worker

  def schedule, do: new(%{}) |> Oban.insert!()

  def perform(_) do
    Blade.prune()
    :ok
  end
end
