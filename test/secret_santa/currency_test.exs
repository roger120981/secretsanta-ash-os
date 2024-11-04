defmodule SecretSanta.CurrencyTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias SecretSanta.Currency

  defp test_currency_p(fun, currency, expected) do
    casted_input = fun.(currency, [])
    assert casted_input == {:ok, expected}
  end

  defp test_currency(currency, expected) when is_binary(currency) do
    funs = [
      &Currency.cast_input/2,
      &Currency.cast_stored/2,
      &Currency.dump_to_native/2,
    ]

    for fun <- funs do
      test_currency_p(fun, currency, expected)
      test_currency_p(fun, expected, expected)
    end
  end
  defp test_currency(currencies, expected) when is_list(currencies) do
    for currency <- currencies do
      test_currency(currency, expected)
    end
  end

  describe "Currencies can be serialised and deserialised." do
    for {k, v} <- [
                    {:gbp, ["GBP", "GBp", "GbP", "gBP", "Gbp", "gbP", "gBp", "gbp"]},
                    {:sek, ["SEK", "SEk", "SeK", "sEK", "Sek", "seK", "sEk", "sek"]},
                  ] do
      test "#{k} is supported" do
        test_currency(unquote(v), unquote(k))
      end
    end
  end
end
