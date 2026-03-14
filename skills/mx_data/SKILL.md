---
name: mx_data
description: 妙想金融数据 skill，基于东方财富权威数据库查询股票、板块、指数、基金、债券等行情和财务数据。触发条件：用户提到"查股票"、"金融数据"、"行情"、"东方财富"、"妙想数据"、"mx_data"等。
metadata:
  openclaw:
    emoji: "📈"
    requires:
      env: ["MX_APIKEY"]
    primaryEnv: "MX_APIKEY"
---

# 妙想金融数据 (mx_data)

查询东方财富权威金融数据，包括行情、财务、关系经营三类数据。

## API 端点

```
POST https://mkapi2.dfcfs.com/finskillshub/api/claw/query
Headers:
  Content-Type: application/json
  apikey: {MX_APIKEY}
Body:
  {"toolQuery": "查询内容"}
```

## 使用方式

### 方式一：环境变量

```bash
# 设置 API Key
export MX_APIKEY="mkt_fHydsJOjfZCrjaVA4FZh7vw1TD54TlMuqUF-cLmEGWk"

# 查询示例
curl -X POST 'https://mkapi2.dfcfs.com/finskillshub/api/claw/query' \
  -H 'Content-Type: application/json' \
  -H 'apikey: mkt_fHydsJOjfZCrjaVA4FZh7vw1TD54TlMuqUF-cLmEGWk' \
  -d '{"toolQuery": "东方财富最新价"}'
```

### 方式二：脚本调用

直接调用 `scripts/query.ts`：

```bash
bun run scripts/query.ts "东方财富最新价"
bun run scripts/query.ts "贵州茅台股价"
bun run scripts/query.sh "上证指数行情"
```

## 查询示例

| 查询类型 | 示例 |
|---------|------|
| 股票行情 | "东方财富最新价"、"贵州茅台收盘价" |
| 板块数据 | "新能源板块行情"、"半导体行业资金流向" |
| 指数数据 | "上证指数实时行情"、"创业板指估值" |
| 基金数据 | "易方达基金净值" |
| 财务数据 | "茅台2023年营收"、"比亚迪利润" |

## 响应解析

返回 JSON 格式，核心数据在 `data.dataTableDTOList`：

- `code` - 证券代码（如 300059.SZ）
- `entityName` - 证券名称
- `table` - 表格数据（指标编码→数值）
- `nameMap` - 列名映射（编码→中文名）
- `field.returnName` - 指标名称

## 注意事项

1. **大数据谨慎**：查询3年以上日线数据可能导致返回内容过多
2. **结果为空**：提示用户到东方财富妙想AI查询
3. **API Key**：已在环境变量中配置

## 输出格式

查询成功后，提取关键信息呈现给用户：

```
📊 {证券名称}
- 最新价：{数值}
- 涨跌幅：{数值}%
- 等等...
```
