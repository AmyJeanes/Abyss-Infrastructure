# syntax=docker/dockerfile:1@sha256:87999aa3d42bdc6bea60565083ee17e86d1f3339802f543c0d03998580f9cb89
# Self-contained musl AMD VAAPI stack baked onto linuxserver/plex. musl keeps it isolated
# from Plex's bundled libs — a glibc Mesa driver shares sonames with them and segfaults.

FROM alpine:edge@sha256:9a341ff2287c54b86425cbee0141114d811ae69d88a36019087be6d896cef241 AS vaapi
RUN apk add --no-cache mesa-va-gallium \
 && apk add --no-cache -X https://dl-cdn.alpinelinux.org/alpine/edge/testing libva-utils
RUN set -eux; \
    out=/vaapi; mkdir -p "$out/lib/dri" "$out/share/libdrm" "$out/bin"; \
    for d in /usr/lib/dri/*_drv_video.so; do cp -aL "$d" "$out/lib/dri/"; done; \
    { for f in /usr/lib/dri/*_drv_video.so /usr/lib/libva.so.2 /usr/lib/libva-drm.so.2 /usr/bin/vainfo; do \
          /lib/ld-musl-x86_64.so.1 --list "$f" 2>/dev/null; \
      done; } \
      | awk '{for (i=1;i<=NF;i++) if (substr($i,1,1)=="/") print $i}' \
      | sort -u \
      | while read -r p; do \
          case "$p" in */dri/*) continue ;; esac; \
          [ -f "$p" ] && cp -aL "$p" "$out/lib/"; \
        done; \
    cp -aL /lib/ld-musl-x86_64.so.1 "$out/lib/"; \
    ln -sf ld-musl-x86_64.so.1 "$out/lib/libc.musl-x86_64.so.1"; \
    cp -aL /usr/share/libdrm/amdgpu.ids "$out/share/libdrm/"; \
    cp -aL /usr/bin/vainfo "$out/bin/vainfo"

FROM lscr.io/linuxserver/plex:latest@sha256:d8b3417b9173bab8bb79b167119b6b69a85558f2127e7fa810a045654e3dbe7f
COPY --from=vaapi /vaapi/lib/ /usr/lib/plex-vaapi/lib/
COPY --from=vaapi /vaapi/bin/ /usr/lib/plex-vaapi/bin/
COPY --from=vaapi /vaapi/share/libdrm/amdgpu.ids /usr/share/libdrm/amdgpu.ids
COPY root/ /
RUN sed -i 's/\r$//' /etc/s6-overlay/s6-rc.d/svc-plex/run \
 && chmod 0755 /etc/s6-overlay/s6-rc.d/svc-plex/run
