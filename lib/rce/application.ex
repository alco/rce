defmodule RCE.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RCEWeb.Telemetry,
      # Start the Ecto repository
      RCE.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: RCE.PubSub},
      # Start the Endpoint (http/https)
      RCEWeb.Endpoint,
      # Start a worker process that manages user points.
      {RCE.Users.Manager, update_interval: 60_000}
    ]

    opts = [strategy: :one_for_one, name: RCE.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RCEWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
