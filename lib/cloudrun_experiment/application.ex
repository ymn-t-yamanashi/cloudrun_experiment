defmodule CloudrunExperiment.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CloudrunExperimentWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:cloudrun_experiment, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CloudrunExperiment.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CloudrunExperiment.Finch},
      # Start a worker by calling: CloudrunExperiment.Worker.start_link(arg)
      # {CloudrunExperiment.Worker, arg},
      # Start to serve requests, typically the last entry
      CloudrunExperimentWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CloudrunExperiment.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CloudrunExperimentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
