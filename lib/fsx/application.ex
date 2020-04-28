defmodule Fsx.Application do
  use Application

  def start(_type, _args) do
    children = [
      FsxWeb.Telemetry,
      {Phoenix.PubSub, name: Fsx.PubSub},
      FsxWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Fsx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    FsxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
