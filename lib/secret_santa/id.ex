defmodule SecretSanta.Id do
  @moduledoc """
  A wrapper for the ID type(s) of letsplan.events.
  """

  @alphabet "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ"
  @default_size 8

  @doc "Returns the default alphabet used to generate NanoIDs"
  def alphabet() do
    @alphabet
  end

  @doc "Returns the default size for the `Nanoid` IDs to generate"
  def default_size() do
    @default_size
  end

  @doc """
  Generates a new `Nanoid` of the pre-configured length/size
  """
  def generate(size \\ @default_size, alphabet \\ @alphabet) do
    Nanoid.generate(size, alphabet)
  end
end
