defmodule Repeated.Search do
  @moduledoc """
  A DSL for creating a `search` action that takes
  a `query` string, which will be queried against
  the list of fields included in the call to this
  macro.
  """

  @doc """
  Creates a new `searh` action that takes a `query` string.

  The following code is injected in-place:

    ```elixir
    read :search do
      argument :query, :string do
        allow_nil? false
      end
      argument :limit, :string do
        allow_nil? false
        default 10
      end

      prepare build(
        sort: [
          {:search_score, %{query: arg(:query)}, :desc},
          {:updated_at, :asc},
        ])
    end
    ```
  """
  @spec search_action(calculation_name :: atom(), opts :: Keyword.t()) :: Macro.t()
  defmacro search_action(calculation_name, opts \\ []) do
    default_limit = Keyword.get(opts, :default_limit, 10)
    default_limit_min = Keyword.get(opts, :default_limit, 1)
    default_threshold = Keyword.get(opts, :default_threshold, 0.75)
    calculation_arg_name = Keyword.get(opts, :calculation_arg_name, :query)

    quote generated: true, location: :keep do
      read :search do
        argument :query, :string do
          allow_nil? false
        end

        argument :threshold, :float do
          allow_nil? false
          default unquote(default_threshold)
        end

        argument :limit, :integer do
          allow_nil? false
          default unquote(default_limit)

          constraints min: unquote(default_limit_min)
        end

        prepare build(
                  filter: [
                    {unquote(calculation_name),
                     {%{unquote(calculation_arg_name) => arg(:query)},
                      greater_than: arg(:threshold)}},
                  ],
                  limit: arg(:limit),
                  sort: [
                    {unquote(calculation_name),
                     {%{unquote(calculation_arg_name) => arg(:query)}, :desc}},
                    {:updated_at, :desc},
                  ]
                )
      end
    end
  end

  defp build_trgm_call({name, :cast}) do
    quote do
      trigram_similarity(type(unquote(name), :string), ^arg(:query))
    end
  end

  defp build_trgm_call(name) do
    quote do
      trigram_similarity(unquote(name), ^arg(:query))
    end
  end

  defp build_trgm_calls(fields) do
    fields
    |> Enum.map(&build_trgm_call/1)
  end

  defmacro search_calculation(calculation_name, fields) do
    question_marks =
      1..Enum.count(fields)
      |> Enum.map_join(", ", fn _ -> "?" end)

    greatest = "greatest(#{question_marks})"
    trgm_calls = build_trgm_calls(fields)

    quote generated: true, location: :keep do
      calculate unquote(calculation_name),
                :float,
                expr(
                  fragment(
                    unquote(greatest),
                    unquote_splicing(trgm_calls)
                  )
                ) do
        argument :query, :string do
          allow_nil? false
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

      import unquote(module),
        only: [
          search_action: 1,
          search_calculation: 2,
        ]
    end
  end
end
