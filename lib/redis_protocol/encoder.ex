defmodule RedisProtocol.Encoder do
  @doc """
  Encode the elixir data structure into Redis protocol compliant format.

  ## Examples

      iex> RedisProtocol.Encoder.encode("PONG")
      "+PONG\\r\\n"

  """
  def encode(data)

  def encode(data) when is_bitstring(data) do
    <<?+, data::binary, ?\r, ?\n>>
  end
end
