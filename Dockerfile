FROM debian:13

# 安装基础组件及 openssh-server
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    systemd \
    dbus \
    openssh-server \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# 允许 root 远程密码登录并启用 SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    systemctl set-default multi-user.target && \
    systemctl enable ssh

# 编写随机生成密码的脚本
RUN printf '#!/bin/bash\n\
PASSWORD=$(openssl rand -base64 12)\n\
echo "root:${PASSWORD}" | chpasswd\n\
echo "========================================"\n\
echo "[SSH INFO] Root password set to: ${PASSWORD}"\n\
echo "========================================"\n' > /usr/local/bin/init-root-password.sh && \
    chmod +x /usr/local/bin/init-root-password.sh

# 注册一次性 systemd 服务，将输出重定向到控制台以供 docker logs 捕获
RUN printf '[Unit]\n\
Description=Generate random root password\n\
Before=ssh.service\n\
\n\
[Service]\n\
Type=oneshot\n\
ExecStart=/usr/local/bin/init-root-password.sh\n\
StandardOutput=journal+console\n\
StandardError=journal+console\n\
\n\
[Install]\n\
WantedBy=multi-user.target\n' > /etc/systemd/system/generate-root-pwd.service && \
    systemctl enable generate-root-pwd.service

EXPOSE 22

WORKDIR /root

CMD ["/lib/systemd/systemd"]
