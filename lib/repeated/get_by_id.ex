defmodule Repeated.GetById do
  @moduledoc """
  A DSL for creating `get_by_id` actions.
  """

  @doc """
  Creates a new `get_by_id` action. Supports passing `:id_field`
  as an opt in case the primary key is not `:id`.

  The following code is injected in-place:

    ```elixir
    read :get_by_id do
      get_by :id
    end
    ```
  """
  @spec get_by_id(opts :: Keyword.t()) :: Macro.t()
  defmacro get_by_id(opts \\ []) do
    opts = Macro.prewalk(opts, &Macro.expand(&1, __CALLER__))
    {id_field, opts} = Keyword.pop(opts, :field, :id)

    Repeated.GetBy.get_by_block(id_field, [{:name, :id} | opts])
  end

  @doc false
  @spec __using__(opts :: Keyword.t()) :: Macro.t()
  defmacro __using__(_opts) do
    module = __MODULE__

    quote generated: true, location: :keep do
      require unquote(module)
      import unquote(module), only: [get_by_id: 0, get_by_id: 1]
    end
  end
end
