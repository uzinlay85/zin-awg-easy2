# Compile Go and C binaries of AmneziaWG 2.0 from source
FROM alpine AS build_go
RUN apk add --no-cache git go make
RUN git clone https://github.com/amnezia-vpn/amneziawg-go.git /amneziawg-go && \
    cd /amneziawg-go && \
    make

FROM alpine AS build_tools
RUN apk add --no-cache git build-base linux-headers
RUN git clone https://github.com/amnezia-vpn/amneziawg-tools.git /amneziawg-tools && \
    cd /amneziawg-tools/src && \
    make

# Web UI build
FROM docker.io/library/node:18-alpine AS build_node_modules
COPY src /app
WORKDIR /app
RUN npm ci --omit=dev && \
    mv node_modules /node_modules

# Copy build result to a new image.
FROM amneziavpn/amnezia-wg:latest
HEALTHCHECK CMD /usr/bin/timeout 5s /bin/sh -c "/usr/bin/wg show | /bin/grep -q interface || exit 1" --interval=1m --timeout=5s --retries=3

# Overwrite base binaries with the compiled AmneziaWG 2.0 binaries
COPY --from=build_go /amneziawg-go/amneziawg-go /usr/bin/wireguard-go
COPY --from=build_go /amneziawg-go/amneziawg-go /usr/bin/amneziawg-go
COPY --from=build_tools /amneziawg-tools/src/wg /usr/bin/wg
COPY --from=build_tools /amneziawg-tools/src/wg /usr/bin/awg
COPY --from=build_tools /amneziawg-tools/src/wg-quick/linux.bash /usr/bin/wg-quick
COPY --from=build_tools /amneziawg-tools/src/wg-quick/linux.bash /usr/bin/awg-quick

COPY --from=build_node_modules /app /app
COPY --from=build_node_modules /node_modules /node_modules
COPY --from=build_node_modules /app/wgpw.sh /bin/wgpw
RUN chmod +x /bin/wgpw

RUN apk add --no-cache \
    dpkg \
    dumb-init \
    iptables \
    nodejs \
    npm

RUN update-alternatives --install /sbin/iptables iptables /sbin/iptables-legacy 10 --slave /sbin/iptables-restore iptables-restore /sbin/iptables-legacy-restore --slave /sbin/iptables-save iptables-save /sbin/iptables-legacy-save

ENV DEBUG=Server,WireGuard
WORKDIR /app
CMD ["/usr/bin/dumb-init", "node", "server.js"]

