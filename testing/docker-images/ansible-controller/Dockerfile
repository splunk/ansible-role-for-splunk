# Build stage for ttyd
FROM ubuntu:22.04 AS builder

# Install build dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential cmake git ca-certificates libjson-c-dev libwebsockets-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone and build ttyd from source (latest version 1.7.7)
RUN git clone https://github.com/tsl0922/ttyd.git /tmp/ttyd && \
    cd /tmp/ttyd && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make

# Final stage
FROM splunk-base-ubuntu2204:latest

# Install runtime dependencies and tools
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg iproute2 net-tools nginx apache2-utils ansible \
      libjson-c5 libwebsockets16 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy ttyd binary from builder stage
COPY --from=builder /tmp/ttyd/build/ttyd /usr/local/bin/

# Create systemd directory (service will be configured in prepare.yml)
RUN mkdir -p /etc/systemd/system

# Systemd adjustments: enable nginx
RUN systemctl enable nginx || true

# Create nginx configuration for ttyd
RUN mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled && \
    echo 'server {\n\
    listen 3000;\n\
    listen [::]:3000;\n\
    server_name _;\n\
\n\
    location /ttyd/ {\n\
        proxy_pass http://127.0.0.1:7681/;\n\
        proxy_http_version 1.1;\n\
        proxy_set_header Upgrade $http_upgrade;\n\
        proxy_set_header Connection "upgrade";\n\
        proxy_set_header Host $host;\n\
        proxy_set_header X-Real-IP $remote_addr;\n\
        proxy_read_timeout 1800s;\n\
    }\n\
\n\
    location / {\n\
        return 301 /ttyd/;\n\
    }\n\
}' > /etc/nginx/sites-available/ttyd && \
    ln -sf /etc/nginx/sites-available/ttyd /etc/nginx/sites-enabled/

EXPOSE 22 3000
STOPSIGNAL SIGRTMIN+3
CMD ["/usr/sbin/init"]
