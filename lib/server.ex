defmodule Server do
  @moduledoc """
  Your implementation of a Redis server
  """

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Server.ClientAcceptor},
      {Task, fn -> Server.Listener.listen() end}
    ]

    opts = [strategy: :one_for_one]

    Supervisor.start_link(children, opts)
  end
end
