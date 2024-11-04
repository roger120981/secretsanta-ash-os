defmodule Repeated.NanoId do
  @moduledoc """
  Provides a DSL module for generating NanoID:s on Ash resources.
  """

  @doc """
  Generates an `id` attribute of type `NanoID`, which is a string generated from
  a pre-configured alphabet and size.
  """
  defmacro nanoid(field_name \\ :id, opts \\ []) do
    allow_nil? = Keyword.get(opts, :allow_nil?, false)
    public? = Keyword.get(opts, :public?, false)

    description =
      Keyword.get(
        opts,
        :description,
        "A NanoID string. They're easier to copy-paste and makes for nicer links."
      )

    alphabet = Keyword.get(opts, :alphabet, SecretSanta.Id.alphabet())
    size = Keyword.get(opts, :size, SecretSanta.Id.default_size())

    quote generated: true do
      attribute unquote(field_name), :nanoid do
        primary_key? true
        public? unquote(public?)
        allow_nil? unquote(allow_nil?)
        description unquote(description)

        default fn ->
          SecretSanta.Id.generate(unquote(size), unquote(alphabet))
        end
      end
    end
  end

  @doc false
  defmacro __using__(_opts) do
    id_module = __MODULE__

    quote generated: true, location: :keep do
      require unquote(id_module)
      import unquote(id_module), only: [nanoid: 0, nanoid: 1, nanoid: 2]
    end
  end
end
