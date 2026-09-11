FROM debian:stable-slim

WORKDIR /app

# 安装必要的工具并清理 apt 缓存以减少体积
RUN apt-get update && apt-get install -y --no-install-recommends \
        ttyd \
        tini \
        bash \
        coreutils \
        fastfetch \
        fish \
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
