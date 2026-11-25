# sing-box for Cloady (VLESS + WebSocket)
#
# Cloady 的部署表单没有配置文件上传、没有启动命令字段，只有环境变量和 $PORT。
# 这个镜像在启动时读取 $PORT，自动生成 sing-box 的 config.json 再运行。
# 容器内走明文 WS，TLS 由 Cloady 的域名自动终止。

FROM alpine:latest

RUN apk add --no-cache ca-certificates curl gcompat

ARG SING_BOX_VERSION=1.14.4
RUN curl -fsSL -o /tmp/sing-box.tar.gz \
      "https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION}-linux-amd64.tar.gz" \
    && tar -xzf /tmp/sing-box.tar.gz -C /tmp \
    && mv /tmp/sing-box-${SING_BOX_VERSION}-linux-amd64/sing-box /usr/local/bin/sing-box \
    && chmod +x /usr/local/bin/sing-box \
    && rm -rf /tmp/sing-box.tar.gz /tmp/sing-box-${SING_BOX_VERSION}-linux-amd64 \
    && /usr/local/bin/sing-box version

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
