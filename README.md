# SecretSanta

## Development

## Requirements and dependencies

### Dependencies

You need to install [mise](https://mise.jdx.dev/getting-started.html) to
install the proper versions of Erlang/OTP and Elixir.

The specific versions are declared in the `.mise.toml` file.

Once `mise` has been installed, all you need to do is to run the following in the project root:
```bash
mise install
```

### Building the image

The script `build.sh` looks like this:
```bash
docker build --progress=plain \
  --build-arg REL_NAME="secret_santa" \
  --build-arg GIT_VERSION_SHA=$(git rev-parse --short HEAD) \
  -t secret_santa:$(mix version) . 2>&1 | tee docker.build.log
```
It can be used as-is

### Running the container

```bash
docker run -d -p 80:8080 \
  -e PORT="8080" \
  -e DATABASE_URL="postgresql://postgres:postgres@psql-elixir/ss_prod" \
  --link psql-elixir \
  --name ss-api \
  ss-api:$(cat VERSION)-$(git rev-parse --short HEAD) start
```
