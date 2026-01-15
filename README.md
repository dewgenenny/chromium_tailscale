# chromium_tailscale

![Docker](https://github.com/dewgenenny/chromium_tailscale/actions/workflows/docker-publish.yml/badge.svg)

Private browsing via chromium docker with tailscale.

This container runs [Chromium](https://www.chromium.org/Home) (via [LinuxServer.io's image](https://docs.linuxserver.io/images/docker-chromium)) with [Tailscale](https://tailscale.com/) integrated. This allows you to privately browse using your own tailscale network.

## Prerequisites

- A Tailscale account.
- An Auth Key from your Tailscale admin console. You can generate one [here](https://login.tailscale.com/admin/settings/keys).

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `TS_AUTHKEY` | **Required.** Your Tailscale auth key (starts with `tskey-`). | |
| `TS_HOSTNAME` | The hostname to register in your Tailscale network. | `chromium-ts` |
| `TS_EXTRA_ARGS` | Additional arguments to pass to `tailscale up`. | |
| `CUSTOM_RES_W` | Width of the chromium window. | `1920` |
| `CUSTOM_RES_H` | Height of the chromium window. | `1080` |
| `CUSTOM_DPI` | DPI of the chromium window. | `96` |
| `DEBIAN_FRONTEND`| System variable, likely shouldn't change. | `noninteractive` |

## Usage

### Docker Cli

```bash
docker run -d \
  --name=chromium-tailscale \
  --security-opt seccomp=unconfined ` # Optional, but recommended for Chromium` \
  --shm-size=1g ` # Recommended to prevent crashes` \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e TS_AUTHKEY="tskey-auth-..." \
  -e TS_HOSTNAME="my-secure-browser" \
  -e TS_EXTRA_ARGS="--accept-dns=true" \
  -p 3000:3000 \
  -p 3001:3001 \
  --device /dev/net/tun:/dev/net/tun \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  ghcr.io/dewgenenny/chromium_tailscale:latest
```

> [!IMPORTANT]
> - **Tailscale Requirements**: `--device /dev/net/tun:/dev/net/tun` and capability additions `NET_ADMIN` and `NET_RAW` are required.
> - **Performance**: `--shm-size=1g` is highly recommended to prevent Chrome from crashing on memory-intensive pages.

### Accessing the application

Once running, the container will register itself on your Tailscale network.
- **Web UI**: Access via `http://<TS_IP>:3000` or `https://<TS_IP>:3001` (if configured).
- **Tailscale**: Check your Tailscale admin console to see the machine online.

## Architecture

This image is based on `lscr.io/linuxserver/chromium`.
- **Init Logic**: A custom init script (`/custom-cont-init.d/50-tailscale`) starts the Tailscale daemon in userspace mode and authenticates using the provided key.
- **Runtime**: A supervised service (`/custom-services.d/tailscale`) monitors the Tailscale daemon to ensure it stays running.
