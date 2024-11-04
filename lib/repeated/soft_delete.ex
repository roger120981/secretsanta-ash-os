defmodule Repeated.SoftDelete do
  @moduledoc """
  A DSL for creating `soft_delete` actions.
  """

  @doc """
  Creates a new soft `:destroy` action named `soft_delete`,
  which by default is the primary `:destroy` action.
  """
  @spec soft_delete(opts :: Keyword.t()) :: Macro.t()
  defmacro soft_delete(opts \\ []) do
    primary? = Keyword.get(opts, :primary, true)
    deleted_at_field_name = Keyword.get(opts, :field_name, :deleted_at)
    value_setter = Keyword.get(opts, :value_setter, &DateTime.utc_now/0)

    quote generated: true do
      destroy :soft_delete do
        primary? unquote(primary?)
        soft? true

        change set_attribute(unquote(deleted_at_field_name), unquote(value_setter))
      end
    end
  end

  @doc false
  @spec __using__(opts :: Keyword.t()) :: Macro.t()
  defmacro __using__(_opts) do
    module = __MODULE__

    quote generated: true, location: :keep do
      require unquote(module)
      import unquote(module), only: [soft_delete: 0, soft_delete: 1]
    end
  end
end
