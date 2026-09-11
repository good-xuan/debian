#!/bin/sh
set -e

USER="${TTYD_USER:-admin}"
PASS_FILE="/etc/ttyd_secret"

# 1. 优先使用环境变量指定的密码
if [ -n "$TTYD_PASSWORD" ]; then
    PASSWORD="$TTYD_PASSWORD"
# 2. 其次检查是否之前已经生成过密码（重启场景）
elif [ -f "$PASS_FILE" ]; then
    PASSWORD=$(cat "$PASS_FILE")
    IS_RELOAD=true
# 3. 首次部署且未指定密码：生成并落盘保存
else
    PASSWORD=$(head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 16)
    echo "$PASSWORD" > "$PASS_FILE"
    chmod 600 "$PASS_FILE"
fi

echo "=========================================="
if [ "$IS_RELOAD" = "true" ]; then
    echo " ttyd web terminal (Container Restarted)"
else
    echo " ttyd web terminal (New Generated)"
fi
echo " Username : ${USER}"
echo " Password : ${PASSWORD}"
echo " Web URL  : http://<server-ip>:7681"
echo "=========================================="

exec /sbin/tini -- ttyd -c "${USER}:${PASSWORD}" "$@"
