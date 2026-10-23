# Docker PHP-FPM

轻量、多架构（`linux/amd64`, `linux/arm64`）的定制化 PHP-FPM Docker 镜像。

## 🎯 针对场景定制

- **Nextcloud**: 集成 `sysvsem`、`imagick`、`intl`、`zip`、`opcache` 等
- **Zabbix**: 集成 `sockets`、`bcmath`、`gd` 等
- **Modern PHP Web**: 内置 `pdo_mysql`、`mysqli`、`gmp`、`sodium` 及 `Composer`

## ⚙️ 自动化工作流 Pipeline

1. **版本每日巡检与测试构建 (`check-update.yml`)**：
   - 每天自动根据分支版本（如 `8.3`）查询 Docker Hub 官方 `library/php` 最新 `fpm-alpine` 标签。
   - 发现新版本时自动更新 `Dockerfile`，并执行多架构**测试构建**验证扩展兼容性。
   - 测试构建成功后自动提交代码、创建 Git Tag 并触发正式发布。
2. **多架构发布与 Release (`docker-buildx.yml`)**：
   - 监听 Tag 推送事件，构建并推送 `linux/amd64` 与 `linux/arm64` 镜像到 Docker Hub。
   - 采用 [Cosign](https://github.com/sigstore/cosign) 完成无密钥数字签名。
   - 自动生成 GitHub Release 页面。
