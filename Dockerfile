FROM lscr.io/linuxserver/chrome:latest

USER root

# Install dependencies + Tailscale (Debian/Ubuntu-based LSIO Chrome image)
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg2 iproute2 iptables procps \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg \
       -o /etc/apt/keyrings/tailscale.gpg \
    && curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list \
       -o /etc/apt/sources.list.d/tailscale.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends tailscale \
    && rm -rf /var/lib/apt/lists/*

# LinuxServer init hook: runs at container start
COPY root/custom-cont-init.d/50-tailscale /custom-cont-init.d/50-tailscale
RUN chmod +x /custom-cont-init.d/50-tailscale

USER abc
