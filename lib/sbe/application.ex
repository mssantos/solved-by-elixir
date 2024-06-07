defmodule Sbe.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SbeWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:sbe, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Sbe.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Sbe.Finch},
      # Start a worker by calling: Sbe.Worker.start_link(arg)
      # {Sbe.Worker, arg},
      # Start to serve requests, typically the last entry
      SbeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sbe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SbeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
