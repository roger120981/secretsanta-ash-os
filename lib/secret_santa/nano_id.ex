defmodule SecretSanta.NanoId do
  @constraints [
    max_length: [
      type: :non_neg_integer,
      doc: "Enforces a maximum length on the value",
    ],
    min_length: [
      type: :non_neg_integer,
      doc: "Enforces a minimum length on the value",
    ],
  ]

  @moduledoc """
  An `Ash.Type` representation of a `NanoID`.

  ### Constraints

  #{Spark.Options.docs(@constraints)}
  """

  use Ash.Type

  alias SecretSanta.Id

  @impl Ash.Type
  def constraints() do
    @constraints
  end

  @impl Ash.Type
  def describe(_constraints) do
    nil
  end

  @impl Ash.Type
  def storage_type(_), do: :string

  @impl Ash.Type
  def cast_input(nil, _), do: {:ok, nil}

  def cast_input(value, _) when is_binary(value) do
    common_caster(value)
  end

  @impl Ash.Type
  def cast_stored(nil, _), do: {:ok, nil}

  def cast_stored(value, _) when is_binary(value) do
    common_caster(value)
  end

  @impl Ash.Type
  def dump_to_native(nil, _), do: {:ok, nil}

  def dump_to_native(value, _) when is_binary(value) do
    common_caster(value)
  end

  # ! private functions

  defp common_caster(value) do
    if validate_alphabet(value, Id.alphabet()),
      do: {:ok, value},
      else: {:error, :bad_alphabet}
  end

  defp validate_alphabet(value, alphabet) do
    value
    |> string_to_set()
    |> MapSet.subset?(alphabet |> string_to_set())
  end

  defp string_to_set(string) when is_binary(string) do
    string
    |> String.graphemes()
    |> MapSet.new()
  end
end
