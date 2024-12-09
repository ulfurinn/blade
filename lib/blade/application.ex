defmodule Blade.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BladeWeb.Telemetry,
      Blade.Repo,
      Blade.Migrate,
      {Oban, Application.fetch_env!(:blade, Oban)},
      Blade.Kickoff,
      {DNSCluster, query: Application.get_env(:blade, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Blade.PubSub},
      # Start a worker by calling: Blade.Worker.start_link(arg)
      # {Blade.Worker, arg},
      # Start to serve requests, typically the last entry
      BladeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blade.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BladeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
