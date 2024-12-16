defmodule SecretSanta.Checks.ActorIsNil do
  @moduledoc false

  use Ash.Policy.SimpleCheck

  def describe(_) do
    "actor should be nil"
  end

  def match?(nil, _context, _opts) do
    true
  end

  def match?(_actor, _context, _opts) do
    false
  end
end
