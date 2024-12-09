defmodule Blade.Workers.Index do
  use Oban.Worker,
    unique: [period: :infinity, states: ~w(scheduled available executing retryable)a]

  def schedule, do: new(%{}) |> Oban.insert!()

  def perform(_) do
    Blade.index()
    :ok
  end
end
