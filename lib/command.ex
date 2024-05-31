defmodule Command do
  def process([]), do: :noop

  def process(["PING" | _]), do: "PONG"
end
