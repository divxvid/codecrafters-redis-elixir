defmodule RedisProtocol.Encoder do
  @doc """
  Encode the elixir string into a RESP2 simple string.

  ## Examples

      iex> RedisProtocol.Encoder.encode_simple_string("PONG")
      "+PONG\\r\\n"

  """
  def encode_simple_string(data) when is_bitstring(data) do
    <<?+, data::binary, ?\r, ?\n>>
  end

  @doc """
  Encode the elixir string into a RESP2 bulk string.

  ## Examples

      iex> RedisProtocol.Encoder.encode_bulk_string("PONG")
      "$4\\r\\nPONG\\r\\n"

  """
  def encode_bulk_string(data) when is_bitstring(data) do
    len = String.length(data)
    <<?$, to_string(len)::binary, ?\r, ?\n, data::binary, ?\r, ?\n>>
  end

  def encode_nil_reply(), do: <<?$, "-1", ?\r, ?\n>>
end
