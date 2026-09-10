FROM debian:13

# 安装 systemd 和 dbus
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    systemd \
    dbus \
    && rm -rf /var/lib/apt/lists/*

# 设置 systemd 默认运行级别
RUN systemctl set-default multi-user.target


WORKDIR /root

# 以 systemd 作为 PID 1 启动
CMD ["/lib/systemd/systemd"]
