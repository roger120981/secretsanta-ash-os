defmodule Repeated.Timestamps do
  @moduledoc """
  A DSL for creating timestamp attributes.
  """

  @doc false
  def timestamp_block(name, opts) do
    {type, opts} = Keyword.pop!(opts, :datetime_type)

    quote generated: true, location: :keep do
      attribute unquote(name), unquote(type), unquote(opts)
    end
  end

  @doc false
  defp set_deleted_at_defaults(opts) do
    opts
    |> Keyword.merge(
      public?: false,
      writable?: false,
      allow_nil?: true,
      datetime_type: :utc_datetime_usec,
      default: nil,
      description: "The timestamp for when the record was deleted."
    )
  end

  @doc """
  Creates a new timestamp attribute with the name `deleted_at`,
  following the project's conventions.
  """
  @spec deleted_at(name :: atom(), opts :: Keyword.t()) :: Macro.t()
  defmacro deleted_at(name, opts) do
    Repeated.Timestamps.timestamp_block(name, set_deleted_at_defaults(opts))
  end

  @doc """
  Creates a new timestamp attribute with the name `deleted_at`,
  following the project's conventions.
  """
  @spec deleted_at(opts :: Keyword.t()) :: Macro.t()
  defmacro deleted_at(opts \\ []) do
    Repeated.Timestamps.timestamp_block(:deleted_at, set_deleted_at_defaults(opts))
  end

  @doc """
  Creates a new timestamp attribute with the given `name` and `opts`.
  """
  @spec timestamp(name :: atom(), opts :: Keyword.t()) :: Macro.t()
  defmacro timestamp(name, opts \\ []) do
    Repeated.Timestamps.timestamp_block(name, set_defaults(opts))
  end

  @spec set_defaults(opts :: Keyword.t()) :: Keyword.t()
  defp set_defaults(opts) do
    [
      allow_nil?: false,
      datetime_type: :utc_datetime_usec,
      default: &DateTime.utc_now/0,
      match_other_defaults?: false,
      public?: false,
      writable?: false,
    ]
    |> Keyword.merge(opts)
  end

  @doc false
  @spec __using__(Keyword.t()) :: Macro.t()
  defmacro __using__(opts \\ []) do
    module = __MODULE__

    except = Keyword.get(opts, :except, [])
    only = Keyword.get(opts, :only, [])

    if Keyword.has_key?(opts, :except) && Enum.empty?(except) do
      raise ArgumentError,
        message: "expects a list of functions to exclude from importing when passing `:except`"
    end

    if Keyword.has_key?(opts, :only) && Enum.empty?(only) do
      raise ArgumentError, message: "expects a list of functions to import when passing `:only`"
    end

    quote generated: true, location: :keep do
      require unquote(module)
      import unquote(module), unquote(opts)
    end
  end
end
