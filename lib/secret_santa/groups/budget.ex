defmodule SecretSanta.Groups.Budget do
  @moduledoc """
  An embedded struct that contains
  """

  use Ash.Resource,
    data_layer: :embedded

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    attribute :min, :decimal do
      public? true
      allow_nil? true

      constraints [min: 1]
    end

    attribute :max, :decimal do
      public? true
      allow_nil? false

      constraints [min: 1]
    end

    attribute :currency, :currency do
      public? true
      allow_nil? false
    end
  end
end

defimpl String.Chars, for: SecretSanta.Groups.Budget do
  import Number.Currency

  alias SecretSanta.Currency
  alias SecretSanta.Groups.Budget

  @opts Currency.currency_opts()

  def to_string(nil),
    do: "n/a"
  def to_string(%Budget{min: nil, max: nil}),
    do: "n/a"
  def to_string(%Budget{min: min, max: nil, currency: currency}),
    do: "Min #{number_to_currency(min, Map.fetch!(@opts, currency))}"
  def to_string(%Budget{min: nil, max: max, currency: currency}),
    do: number_to_currency(max, Map.fetch!(@opts, currency))
  def to_string(%Budget{min: min, max: max, currency: currency}) do
    [
      min
      |> number_to_currency(Map.fetch!(@opts, :usd))
      |> drop_unit(),
      number_to_currency(max, Map.fetch!(@opts, currency)),
    ]
    |> Enum.join(" - ")
  end

  # defp dec_to_string(nil), do: "n/a"
  # defp dec_to_string(val = %Decimal{}), do: Decimal.to_string(val)

  defp drop_unit("$" <> value), do: value
  defp drop_unit("€" <> value), do: value
  defp drop_unit("£" <> value), do: value
  defp drop_unit(value), do: value |> String.split(" ") |> hd()
end
