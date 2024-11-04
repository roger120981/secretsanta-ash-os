#
# To make a seed, just define a module in `priv/repo/seeds`,
# e.g. `priv/repo/seeds/my_secret_seeds.ex`.
#

require Logger

defmodule Seeder do
  def maybe_drop(module) do
    if function_exported?(seed_module, :drop, 0) do
      Logger.info("[#{inspect module, pretty: true}} Dropping...")
      seed_module.drop()
    else
      Logger.info("[#{inspect module, pretty: true}] Can't drop seeds as the module doesn't export `drop/0`")
      {:error, :invalid_seed_module}
    end
  end

  def maybe_seed(module) do
    if function_exported?(seed_module, :seed, 0) do
      Logger.info("[#{inspect module, pretty: true}} Seeding...")
      seed_module.seed()
    else
      Logger.info("[#{inspect module, pretty: true}] Can't seed as the module doesn't export `seed/0`")
      {:error, :invalid_seed_module}
    end
  end
end

seed_modules = [
  SecretDevSeeds,
]

Logger.warning("No seeds available yet...")

for seed_module <- seed_modules do
  if Code.loaded?(seed_module) do
    if function_exported?(seed_module, :drop, 0) do
      seed_module.drop()
    else
    end

    if function_exported?(seed_module, :seed, 0) do
    else
      seed.module.seed()
    end
  end
end
