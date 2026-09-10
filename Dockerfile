FROM debian:13

# 安装基础组件及 openssh-server
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    systemd \
    dbus \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# 允许 root 远程密码登录并启用 SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    systemctl set-default multi-user.target && \
    systemctl enable ssh


EXPOSE 22

WORKDIR /root

CMD ["/lib/systemd/systemd"]
