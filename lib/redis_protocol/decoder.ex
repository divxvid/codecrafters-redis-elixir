defmodule RedisProtocol.Decoder do
  @doc """
  Decodes the RedisProtocol protocol string into Elixir data structures

  ## Examples

      iex> RedisProtocol.Decoder.decode("")
      {}

      iex> RedisProtocol.Decoder.decode("+hello\\r\\n")
      {"hello", ""}

      iex> RedisProtocol.Decoder.decode("+hello\\r\\n+world\\r\\n")
      {"hello", "+world\\r\\n"}

      iex> RedisProtocol.Decoder.decode(":425\\r\\n")
      {425, ""}

      iex> RedisProtocol.Decoder.decode(":-425\\r\\n+hello\\r\\n")
      {-425, "+hello\\r\\n"}

      iex> RedisProtocol.Decoder.decode("$5\\r\\nhello\\r\\n")
      {"hello", ""}

      iex> RedisProtocol.Decoder.decode("*2\\r\\n$4\\r\\nECHO\\r\\n$3\\r\\nhey\\r\\n")
      {["ECHO", "hey"], ""}

  """
  def decode(bitstring)

  def decode(<<>>) do
    {}
  end

  def decode(<<"+", rest::binary>>) do
    # this denotes a simple string
    {string_value, rest} =
      Stream.iterate(0, &(&1 + 1))
      |> Enum.reduce_while({[], rest}, fn _, {acc, rest} ->
        <<head::8, tail::binary>> = rest

        case head do
          ?\r -> {:halt, {acc, rest}}
          _ -> {:cont, {[head | acc], tail}}
        end
      end)

    string_value =
      string_value
      |> Enum.reverse()
      |> to_string()

    {string_value, consume_newline(rest)}
  end

  def decode(<<":", rest::binary>>) do
    # this denotes an integer
    {integer_value, rest} = decode_integer(rest)
    {integer_value, consume_newline(rest)}
  end

  def decode(<<"$", rest::binary>>) do
    with {count, rest} <- decode_integer(rest) do
      rest = consume_newline(rest)

      # Produces a {decoded_array, rest} tuple
      {char_list, rest} =
        Enum.reduce(1..count, {[], rest}, fn _, {acc, rest} ->
          <<head::8, tail::binary>> = rest
          {[head | acc], tail}
        end)

      str_data =
        char_list
        |> Enum.reverse()
        |> to_string()

      {str_data, consume_newline(rest)}
    end
  end

  def decode(<<"*", rest::binary>>) do
    # this indicates the start of an array
    # we first decode out the length of the array which follows *
    with {count, rest} <- decode_integer(rest) do
      rest = consume_newline(rest)

      # Produces a {decoded_array, rest} tuple
      {data_list, rest} =
        Enum.reduce(1..count, {[], rest}, fn _, {acc, rest} ->
          {element, rest} = decode(rest)
          {[element | acc], rest}
        end)

      {Enum.reverse(data_list), rest}
    end
  end

  @doc """
  decodes the valid integer till it encounters a non integer.
  Returns `{integer-value, rest}` in case of a successful decode
  or `{:not_integer, rest}` when the starting of the string is not an integer.

  ## Examples

      iex> RedisProtocol.Decoder.decode_integer("1234")
      {1234, ""}

      iex> RedisProtocol.Decoder.decode_integer("1234\\r\\n")
      {1234, "\\r\\n"}

      iex> RedisProtocol.Decoder.decode_integer("-1234\\r\\n")
      {-1234, "\\r\\n"}

      iex> RedisProtocol.Decoder.decode_integer("not-an-integer")
      {:not_integer, "not-an-integer"}

  """
  def decode_integer(data) do
    <<head::8, rest::binary>> = data

    cond do
      head == ?- ->
        {value, rest} = decode_integer1(rest, 0)
        {-1 * value, rest}

      head == ?+ ->
        decode_integer1(rest, 0)

      head in ?0..?9 ->
        decode_integer1(data, 0)

      true ->
        {:not_integer, data}
    end
  end

  defp decode_integer1(<<digit::8, rest::binary>>, acc) when digit in ?0..?9 do
    acc = acc * 10 + (digit - ?0)
    decode_integer1(rest, acc)
  end

  defp decode_integer1(rest, acc), do: {acc, rest}

  defp consume_newline(<<"\r\n", rest::binary>>), do: rest
end
