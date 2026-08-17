# Docker

Run Nexus in a container. Published image: [`decolua/nexus`](https://hub.docker.com/r/decolua/nexus) — multi-platform `linux/amd64` + `linux/arm64`.

---

# 👤 For Users

## Quick start

```bash
docker run -d \
  -p 20128:20128 \
  -v "$HOME/.nexus:/app/data" \
  -e DATA_DIR=/app/data \
  --name nexus \
  decolua/nexus:latest
```

App listens on port `20128`. Open: http://localhost:20128

## Manage container

```bash
docker logs -f nexus        # view logs
docker stop nexus           # stop
docker start nexus          # start again
docker rm -f nexus          # remove
```

## Data persistence

```bash
-v "$HOME/.nexus:/app/data" \
-e DATA_DIR=/app/data
```

Without `DATA_DIR`, the app falls back to `~/.nexus/` (macOS/Linux) or `%APPDATA%\nexus\` (Windows). In the container, `DATA_DIR=/app/data` makes the bind mount work.

Data layout under `$DATA_DIR/`:

```text
$DATA_DIR/
├── db/
│   ├── data.sqlite       # main SQLite database
│   └── backups/          # auto backups
└── ...                   # certs, logs, runtime configs
```

Host path: `$HOME/.nexus/db/data.sqlite`
Container path: `/app/data/db/data.sqlite`

## Optional env vars

```bash
docker run -d \
  -p 20128:20128 \
  -v "$HOME/.nexus:/app/data" \
  -e DATA_DIR=/app/data \
  -e PORT=20128 \
  -e HOSTNAME=0.0.0.0 \
  -e DEBUG=true \
  --name nexus \
  decolua/nexus:latest
```

## Optional Headroom sidecar

The Nexus image does not bundle Python or Headroom. To use Headroom in Docker, run it as a separate service and point Nexus at that proxy:

```yaml
services:
  nexus:
    image: decolua/nexus:latest
    ports:
      - "20128:20128"
    volumes:
      - "$HOME/.nexus:/app/data"
    environment:
      DATA_DIR: /app/data
      HEADROOM_URL: http://headroom:8787
    depends_on:
      - headroom

  headroom:
    image: ghcr.io/chopratejas/headroom:latest
    ports:
      - "8787:8787"
```

In the dashboard, open `Endpoint` → `Token Saver` → `Headroom`, confirm the URL is `http://headroom:8787`, recheck status, then enable Headroom.

If Headroom runs on the Docker host instead of as a sidecar, use `http://host.docker.internal:8787` on macOS/Windows. On Linux, add `--add-host=host.docker.internal:host-gateway` or the equivalent compose `extra_hosts` entry.

## Update to latest

```bash
docker pull decolua/nexus:latest
docker rm -f nexus
# re-run the quick start command
```

---

# 🛠 For Developers

## Build image locally (test)

```bash
cd app && docker build -t nexus .

docker run --rm -p 20128:20128 \
  -v "$HOME/.nexus:/app/data" \
  -e DATA_DIR=/app/data \
  nexus
```

## Publish (automatic via CI)

Push a git tag `v*` → GitHub Actions builds multi-platform (amd64+arm64) and pushes to:
- `ghcr.io/decolua/nexus:v{version}` + `:latest`
- `decolua/nexus:v{version}` + `:latest`

```bash
# Use scripts/release.js (recommended)
node scripts/release.js "Release title" "Notes"

# Or manually
git tag v0.4.x && git push origin v0.4.x
```

Workflow: `app/.github/workflows/docker-publish.yml`
