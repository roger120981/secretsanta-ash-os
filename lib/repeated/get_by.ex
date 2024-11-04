defmodule Repeated.GetBy do
  @moduledoc """
  A DSL for creating `get_by` actions by passing
  the name of the identity.
  """

  @doc """
  Creates a new `get_by` action for the passed `identity`.
  with the name of the action being `:get_by_<opts.name>`.

  The following code is injected in-place:

    ```elixir
    read :get_by_<opts.name> do
      get_by <identity>
    end
    ```
  """
  @spec get_by_block(identity :: atom(), opts :: Keyword.t()) :: Macro.t()
  def get_by_block(identity, opts) do
    name = Keyword.fetch!(opts, :name)
    action_name = String.to_atom("get_by_#{name}")

    prepare_build? = Keyword.has_key?(opts, :prepare)

    quote generated: true, location: :keep do
      read unquote(action_name) do
        Ash.Resource.Dsl.Actions.Read.Options.get_by(unquote(identity))

        if unquote(prepare_build?) do
          prepare build(unquote(Keyword.get(opts, :prepare)))
        end
      end
    end
  end

  @doc """
  Creates a new `get_by` action for the passed `identity`.

  The following code is injected in-place:

    ```elixir
    read :get_by_<opts.name> do
      get_by <identity>
    end
    ```
  """
  @spec get_by(identity :: atom()) :: Macro.t()
  defmacro get_by(identity, opts \\ [])

  defmacro get_by(identity, opts) when is_atom(identity) do
    get_by_block(identity, [{:name, identity} | opts])
  end

  @doc false
  @spec __using__(opts :: Keyword.t()) :: Macro.t()
  defmacro __using__(_opts) do
    module = __MODULE__

    quote generated: true, location: :keep do
      require unquote(module)
      import unquote(module), only: [get_by: 1, get_by: 2]
    end
  end
end
