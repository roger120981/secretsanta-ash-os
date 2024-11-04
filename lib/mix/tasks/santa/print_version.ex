defmodule Mix.Tasks.Santa.PrintVersion do
  @shortdoc "Prints the current project's version"

  @moduledoc """
  Prints the current project's version
  """

  use Mix.Task

  # @dialyzer {:no_return, :"g/0"}
  @shortdoc "Prints the full build version of the project."
  def run(_) do
    SecretSanta.build_version()
    |> IO.puts()
  end
end
