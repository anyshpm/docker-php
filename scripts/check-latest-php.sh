#!/usr/bin/env bash
set -eo pipefail

DOCKERFILE_PATH="${1:-Dockerfile}"
BRANCH="${2:-${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")}}"

if [ ! -f "$DOCKERFILE_PATH" ]; then
  echo "Error: Dockerfile not found at '$DOCKERFILE_PATH'" >&2
  exit 1
fi

# 1. 确定当前 Dockerfile 中的完整 TAG
CURRENT_LINE=$(grep -E '^FROM[ \t]+php:' "$DOCKERFILE_PATH" | head -n 1)
CURRENT_TAG=$(echo "$CURRENT_LINE" | sed -E 's/^FROM[ \t]+php:([^ \t#]+).*/\1/')

if [ -z "$CURRENT_TAG" ]; then
  echo "Error: Cannot extract current PHP tag from $DOCKERFILE_PATH" >&2
  exit 1
fi

echo "Current Dockerfile Tag: $CURRENT_TAG"

# 2. 根据分支名称或 Dockerfile 推断目标 PHP 大小版本 (如 8.3 / 8.2)
TARGET_SERIES=""
if [[ "$BRANCH" =~ ^(php-?)?([0-9]+\.[0-9]+)$ ]]; then
  TARGET_SERIES="${BASH_REMATCH[2]}"
  echo "Detected PHP target series from branch '$BRANCH': $TARGET_SERIES"
else
  # 从当前 Dockerfile 的 TAG 中提取主次版本号，例如 8.3.4 -> 8.3
  if [[ "$CURRENT_TAG" =~ ^([0-9]+\.[0-9]+) ]]; then
    TARGET_SERIES="${BASH_REMATCH[1]}"
    echo "Inferred PHP target series from current tag: $TARGET_SERIES"
  fi
fi

if [ -z "$TARGET_SERIES" ]; then
  echo "Error: Unable to determine PHP target series (e.g., 8.3)." >&2
  exit 1
fi

# 3. 从 Docker Hub 获取对应系列的最新官方 fpm-alpine 标签
echo "Querying Docker Hub for PHP ${TARGET_SERIES} fpm-alpine images..."

API_URL="https://hub.docker.com/v2/namespaces/library/repositories/php/tags?name=${TARGET_SERIES}.&page_size=100"
RESPONSE=$(curl -fsSL "$API_URL" || true)

if [ -z "$RESPONSE" ]; then
  echo "Error: Failed to fetch tags from Docker Hub API." >&2
  exit 1
fi

# 筛选格式类似: 8.3.36-fpm-alpine3.24
# 排序规则: sort -V 升序排列，取最后一个
ESCAPED_SERIES="${TARGET_SERIES//./\\.}"
MATCHING_TAGS=$(echo "$RESPONSE" | grep -o '"name": *"[^"]*"' | cut -d'"' -f4 | grep -E "^${ESCAPED_SERIES}\\.[0-9]+-fpm-alpine[0-9.]+$" || true)

if [ -z "$MATCHING_TAGS" ]; then
  echo "Error: No matching tags found for series ${TARGET_SERIES}." >&2
  exit 1
fi

LATEST_TAG=$(echo "$MATCHING_TAGS" | sort -V | tail -n 1)
echo "Latest available Tag: $LATEST_TAG"

# 4. 判断版本是否有更新
HAS_UPDATE="false"
if [ "$CURRENT_TAG" != "$LATEST_TAG" ]; then
  echo "New version detected: $CURRENT_TAG -> $LATEST_TAG"
  HAS_UPDATE="true"
  # 替换 Dockerfile 中的第一行基础镜像
  sed -i.bak -E "s/^(FROM[ \t]+php:)[^ \t#]+/\1${LATEST_TAG}/" "$DOCKERFILE_PATH"
  rm -f "${DOCKERFILE_PATH}.bak"
  echo "Updated $DOCKERFILE_PATH to use php:${LATEST_TAG}"
else
  echo "Already up-to-date with latest PHP tag ($CURRENT_TAG)."
fi

# 5. 如果在 GitHub Actions 环境中，写入 GITHUB_OUTPUT
if [ -n "$GITHUB_OUTPUT" ]; then
  echo "has_update=${HAS_UPDATE}" >> "$GITHUB_OUTPUT"
  echo "latest_tag=${LATEST_TAG}" >> "$GITHUB_OUTPUT"
  echo "current_tag=${CURRENT_TAG}" >> "$GITHUB_OUTPUT"
  echo "target_series=${TARGET_SERIES}" >> "$GITHUB_OUTPUT"
fi
