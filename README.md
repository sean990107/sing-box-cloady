# sing-box-cloady

给 Cloady 用的定制 sing-box 镜像：VLESS + WebSocket 入站。

## 为什么需要这个镜像

Cloady 的部署表单没有配置文件上传、没有启动命令字段，只有环境变量和 `$PORT`。
sing-box 原版镜像只读 config.json 文件，在 Cloady 上跑不起来。
这个镜像在启动时读取 `$PORT`，自动生成 config.json 再运行 sing-box。

## 镜像内容

- 基础：`alpine:latest` + sing-box v1.14.4（二进制从 GitHub Releases 下载）
- 入口：`entrypoint.sh`，启动时生成 `/etc/sing-box/config.json`：
  - 入站：VLESS，监听 `0.0.0.0:$PORT`，UUID `de9313dc-50f5-4c81-ac47-f5c0902a00cb`
  - 传输：WebSocket，路径 `/vless`
  - 出站：direct
  - 容器内不走 TLS（Cloady 的域名自带 TLS 终止）
- 推送：`.github/workflows/build.yml`，push 到 main 时自动编译并推送到
  `ghcr.io/sean990107/sing-box-cloady:latest`

## 手动建仓库并推送（Muse VM 上 gh 未登录，只能手动做）

在电脑上执行（需要已登录 GitHub 的终端）：

```bash
# 1. 在 GitHub 上新建仓库 sean990107/sing-box-cloady（公开，Public）
#    网址：https://github.com/new

# 2. 把这些文件推上去（先把本目录整个拷到电脑上）
cd sing-box-cloady
git init
git add .
git commit -m "sing-box for Cloady: VLESS+WS from \$PORT"
git branch -M main
git remote add origin https://github.com/sean990107/sing-box-cloady.git
git push -u origin main
```

## 验证编译

push 后打开 https://github.com/sean990107/sing-box-cloady/actions
等 workflow 跑完（约 1–2 分钟），状态变绿即成功。

再确认镜像已推送：

```bash
curl -s https://ghcr.io/v2/sean990107/sing-box-cloady/tags/list
# 应返回 {"name":"sean990107/sing-box-cloady","tags":["latest"]}
```

## 在 Cloady 上部署（部署那步另做）

部署表单里填：
- 镜像：`ghcr.io/sean990107/sing-box-cloady:latest`
- 地区：JPN1（日本）
- 环境变量：不用填，`$PORT` 由 Cloady 自动注入

部署成功后，Loon 节点地址格式：

```
vless://de9313dc-50f5-4c81-ac47-f5c0902a00cb@<Cloady 分配的域名>:443?encryption=none&security=tls&sni=<同上域名>&type=ws&host=<同上域名>&path=%2Fvless#小免替代-Cloady日本
```
