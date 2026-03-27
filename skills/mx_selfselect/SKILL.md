---
name: mx_selfselect
description: 妙想自选股管理 skill，基于东方财富账户查询/添加/删除自选股。触发条件：用户提到"自选股"、"我的股票"、"mx_selfselect"等。
metadata:
  openclaw:
    emoji: "⭐"
    requires:
      env: ["MX_APIKEY"]
    primaryEnv: "MX_APIKEY"
---

# 妙想自选股管理 (mx_selfselect)

管理东方财富账户的自选股：查询、添加、删除。

## API 端点

### 查询自选股
```
POST https://mkapi2.dfcfs.com/finskillshub/api/claw/self-select/get
Headers:
  Content-Type: application/json
  apikey: {MX_APIKEY}
```

### 添加/删除自选股
```
POST https://mkapi2.dfcfs.com/finskillshub/api/claw/self-select/manage
Headers:
  Content-Type: application/json
  apikey: {MX_APIKEY}
Body:
  {"query": "操作描述"}
```

## 使用方式

```bash
# 查询自选股
bun run scripts/get.ts

# 添加自选股
bun run scripts/manage.ts "把东方财富加入自选"

# 删除自选股
bun run scripts/manage.ts "把贵州茅台从自选删除"
```

## 功能示例

| 操作 | 示例 |
|-----|------|
| 查询 | "查询我的自选股列表" |
| 添加 | "把贵州茅台加入自选" |
| 删除 | "把东方财富从自选删除" |

## 输出格式

```
⭐ 我的自选股（共X只）

| 代码 | 名称 | 最新价 | 涨跌幅 |
|------|------|--------|--------|
| 300059 | 东方财富 | 21.10 | +2.35% |
...
```
