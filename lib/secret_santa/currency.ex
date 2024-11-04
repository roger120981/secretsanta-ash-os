defmodule SecretSanta.Currency do
  @moduledoc """
  An `Ash.Type` representation of a currency string.

  Possible values are the three letter code of any
  currency, for example "SEK", "JPY" or "ZAR".
  """

  use Ash.Type

  @impl Ash.Type
  def describe(_constraints) do
    nil
  end

  @impl Ash.Type
  def storage_type(_), do: :string

  @impl Ash.Type
  def cast_input(nil, _), do: {:ok, nil}
  def cast_input(value, _) when is_atom(value) do
    validate_and_return(value)
  end
  def cast_input(value, _) when is_binary(value) do
    common_caster(value)
  end

  @impl Ash.Type
  def cast_stored(nil, _), do: {:ok, nil}
  def cast_stored(value, _) when is_atom(value) do
    validate_and_return(value)
  end
  def cast_stored(value, _) when is_binary(value) do
    common_caster(value)
  end

  @impl Ash.Type
  def dump_to_native(nil, _), do: {:ok, nil}
  def dump_to_native(value, _) when is_atom(value) do
    validate_and_return(value)
  end
  def dump_to_native(value, _) when is_binary(value) do
    common_caster(value)
  end

  # ! private functions

  defp common_caster(value) do
    try do
      value
      |> String.downcase()
      |> String.to_existing_atom()
      |> validate_and_return()
    catch
      _ ->
        {:error, {:invalid_currency_code, value}}
    end
  end

  defp validate_and_return(value) do
    if validate(value),
      do: {:ok, value},
      else: {:error, {:invalid_currency_code, value}}
  end

  defp validate(value) do
    value in currencies()
  end

  @currency_map %{
      eur: [delimiter: ",", format: "%u%n",  negative_format: "%u%n",  precision: 0, separator: ".", unit: "€"],
      gbp: [delimiter: ",", format: "%u%n",  negative_format: "%u%n",  precision: 0, separator: ".", unit: "£"],
      sek: [delimiter: " ", format: "%n %u", negative_format: "%n %u", precision: 0, separator: ",", unit: "kr"],
      usd: [delimiter: ",", format: "%u%n",  negative_format: "%u%n",  precision: 0, separator: ".", unit: "$"],
    }

  @currency_set @currency_map |> Map.keys() |> MapSet.new()

  @doc "List of all supported currencies."
  def currencies() do
    @currency_set
  end

  @doc "List all currencies and their formatting options."
  def currency_opts() do
    @currency_map
  end

  @doc "Get a specific currency's formatting options."
  def currency_opts(currency) do
    @currency_map
    |> Map.get(currency)
  end
end
