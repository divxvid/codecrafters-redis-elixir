defmodule Command do
  def process([command | args]) do
    case String.downcase(command) do
      "ping" ->
        "PONG"

      "echo" ->
        List.first(args)

      _ ->
        "COMMAND NOT IMPLEMENTED"
    end
  end
end
