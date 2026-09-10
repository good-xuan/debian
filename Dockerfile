FROM debian:13

# 安装 systemd、dbus 及 openssh-server
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    systemd \
    dbus \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# 设置 systemd 默认运行级别并启用 ssh 服务
RUN systemctl set-default multi-user.target && \
    systemctl enable ssh

# 配置 SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 暴露 SSH 端口
EXPOSE 22

WORKDIR /root

# 以 systemd 作为 PID 1 启动
CMD ["/lib/systemd/systemd"]
