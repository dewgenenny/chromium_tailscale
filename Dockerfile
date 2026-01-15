FROM lscr.io/linuxserver/chromium:latest

USER root
ENV DEBIAN_FRONTEND=noninteractive \
    CUSTOM_RES_W=1920 \
    CUSTOM_RES_H=1080

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg iproute2 iptables procps \
    && install -m 0755 -d /usr/share/keyrings \
    && curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg \
       -o /usr/share/keyrings/tailscale-archive-keyring.gpg \
    && printf "deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/debian bookworm main\n" \
       > /etc/apt/sources.list.d/tailscale.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends tailscale \
    && rm -rf /var/lib/apt/lists/*

COPY root/custom-cont-init.d/10-fix-x11-tmp /custom-cont-init.d/10-fix-x11-tmp
COPY root/custom-cont-init.d/50-tailscale   /custom-cont-init.d/50-tailscale
RUN chmod +x /custom-cont-init.d/10-fix-x11-tmp /custom-cont-init.d/50-tailscale

# IMPORTANT: do NOT set USER here; LSIO handles runtime users.

