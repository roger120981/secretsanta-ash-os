defmodule Repeated.ListActions do
  @moduledoc """
  A DSL for creating a standard list of `:read` actions for listing things.
  """

  @doc """
  Creates two new `:read` actions: `:list` and `:list_paginated`.
  """
  @spec list_actions(opts :: Keyword.t()) :: Macro.t()
  defmacro list_actions(opts \\ []) do
    is_list_primary_true? = Keyword.get(opts, :list_primary?, false)
    is_list_paginated_primary_true? = Keyword.get(opts, :list_paginated_primary?, false)

    if is_list_primary_true? and is_list_paginated_primary_true? do
      raise "cannot set both `:list_primary?` and `:list_paginated_primary?` to `true` at the same time."
    end

    prepare_build? = Keyword.has_key?(opts, :prepare)
    prepare_opts = Keyword.get(opts, :prepare)

    quote do
      read :list do
        primary? unquote(is_list_primary_true?)

        if unquote(prepare_build?) do
          prepare build(unquote(prepare_opts))
        end
      end

      read :list_paginated do
        primary? unquote(is_list_paginated_primary_true?)
        pagination offset?: true, countable: :by_default, default_limit: 10

        if unquote(prepare_build?) do
          prepare build(unquote(prepare_opts))
        end
      end
    end
  end

  @doc false
  @spec __using__(opts :: Keyword.t()) :: Macro.t()
  defmacro __using__(_opts) do
    module = __MODULE__

    quote generated: true, location: :keep do
      require unquote(module)
      import unquote(module), only: [list_actions: 0, list_actions: 1]
    end
  end
end
