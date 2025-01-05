excluded = [
  :skip
]

ExUnit.start(exclude: excluded)
Faker.start()

Ecto.Adapters.SQL.Sandbox.mode(SecretSanta.Repo, :manual)
