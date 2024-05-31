defmodule Storage.GlobalMap do
  use Agent

  def start_link(opts \\ []) do
    Agent.start_link(fn -> %{} end, opts)
  end

  def set(map, key, value) do
    Agent.update(map, &Map.put(&1, key, value))
  end

  def get(map, key) do
    Agent.get(map, &Map.get(&1, key))
  end
end
