defmodule Server.Listener do
  @doc """
  Listen for incoming connections
  """
  def listen() do
    # You can use print statements as follows for debugging, they'll be visible when running tests.
    IO.puts("Logs from your program will appear here!")

    # Uncomment this block to pass the first stage
    #
    # # Since the tester restarts your program quite often, setting SO_REUSEADDR
    # # ensures that we don't run into 'Address already in use' errors
    {:ok, socket} = :gen_tcp.listen(6379, [:binary, active: false, reuseaddr: true])
    accept_connection(socket)
  end

  def accept_connection(listening_socket) do
    {:ok, client} = :gen_tcp.accept(listening_socket)

    {:ok, pid} =
      Task.Supervisor.start_child(
        Server.ClientAcceptor,
        fn -> ping_pong(client) end
      )

    :gen_tcp.controlling_process(client, pid)
    accept_connection(listening_socket)
  end

  defp ping_pong(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, _} ->
        :gen_tcp.send(socket, "+PONG\r\n")
        ping_pong(socket)

      {:error, :closed} ->
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end
end
