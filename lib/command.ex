defmodule Command do
  def process([command | args]) do
    case String.downcase(command) do
      "ping" ->
        RedisProtocol.Encoder.encode_simple_string("PONG")

      "echo" ->
        RedisProtocol.Encoder.encode_simple_string(List.first(args))

      "set" ->
        handle_set(args)

      "get" ->
        handle_get(args)

      _ ->
        "COMMAND NOT IMPLEMENTED"
    end
  end

  defp handle_set(args) do
    [key | [value]] = args
    Storage.GlobalMap.set(Storage.GlobalMap, key, value)

    RedisProtocol.Encoder.encode_simple_string("OK")
  end

  defp handle_get(args) do
    [key] = args

    case Storage.GlobalMap.get(Storage.GlobalMap, key) do
      nil ->
        RedisProtocol.Encoder.encode_nil_reply()

      value ->
        RedisProtocol.Encoder.encode_bulk_string(value)
    end
  end
end
