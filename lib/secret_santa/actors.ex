defmodule SecretSanta.Actors do
  @moduledoc """
  A module for managing different actors.
  """

  def admin(), do: %{admin: true}
  def system(), do: %{system: true}
end
