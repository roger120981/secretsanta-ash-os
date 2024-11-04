defmodule SecretSanta do
  @moduledoc """
  A simple module to access some meta data.
  """


  @doc false
  def about() do
    %{
      build_version: build_version(),
      version: app_version(),
      git_sha: git_sha(),
    }
  end

  @doc false
  def app_version() do
    Application.fetch_env!(:secret_santa, :build_app_version)
  end

  @doc false
  def build_version() do
    [app_version(), git_sha()]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("-")
  end

  @doc false
  def git_sha() do
    Application.fetch_env!(:secret_santa, :build_git_sha)
  end
end
