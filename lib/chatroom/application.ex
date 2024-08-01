defmodule Chatroom.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChatroomWeb.Telemetry,
      Chatroom.Repo,
      {DNSCluster, query: Application.get_env(:chatroom, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Chatroom.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Chatroom.Finch},
      # Start a worker by calling: Chatroom.Worker.start_link(arg)
      # {Chatroom.Worker, arg},
      # Start to serve requests, typically the last entry
      ChatroomWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatroom.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatroomWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
