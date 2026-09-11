FROM debian:stable-slim

ARG TTYD_VERSION=1.7.7

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        tini \
        bash \
        coreutils \
        fastfetch \
        fish \
    && curl -fL \
        "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.x86_64" \
        -o /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd \
    && ttyd --version \
    && rm -rf /var/lib/apt/lists/*

ENV TERM=xterm-256color

# 写入 config.fish：清空 fish 自带的文本问候语，并执行 fastfetch
RUN mkdir -p /root/.config/fish && \
    echo 'set -g fish_greeting ""' >> /root/.config/fish/config.fish && \
    echo 'fastfetch' >> /root/.config/fish/config.fish

WORKDIR /root

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 7681

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 默认启动 Shell 设为 fish
CMD ["-W", "-p", "7681", "fish"]
