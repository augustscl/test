---
name: mx_select_stock
description: 妙想智能选股 skill，基于东方财富条件筛选股票，支持行情指标、财务指标选股。触发条件：用户提到"选股"、"智能选股"、"mx_select_stock"等。
metadata:
  openclaw:
    emoji: "🎯"
    requires:
      env: ["MX_APIKEY"]
    primaryEnv: "MX_APIKEY"
---

# 妙想智能选股 (mx_select_stock)

基于条件筛选股票，支持行情指标、财务指标、行业板块等。

## API 端点

```
POST https://mkapi2.dfcfs.com/finskillshub/api/claw/stock-screen
Headers:
  Content-Type: application/json
  apikey: {MX_APIKEY}
Body:
  {"keyword": "选股条件", "pageNo": 1, "pageSize": 20}
```

## 使用方式

```bash
bun run scripts/select.ts "今日涨幅2%的股票"
bun run scripts/select.ts "新能源板块市值前10"
bun run scripts/select.ts "市盈率低于20的银行股"
```

## 查询示例

| 类型 | 示例 |
|-----|------|
| 行情选股 | "今日涨幅2%的股票"、"换手率大于10%的股票" |
| 财务选股 | "市盈率低于20"、"净利润增长超过50%" |
| 板块选股 | "新能源板块股票"、"人工智能概念股" |
| 综合 | "市值前10的半导体股票" |

## 返回字段

- `columns` - 列定义（英文键→中文名）
- `dataList` - 股票数据列表
- `total` - 符合条件的股票数量
- `responseConditionList` - 筛选条件统计

## 输出格式

```
🎯 选股结果：{符合条件的股票数}只

筛选条件：{条件描述}

股票列表：
| 序号 | 代码 | 名称 | 最新价 | 涨跌幅 |
|------|------|------|--------|--------|
| 1 | 300059 | 东方财富 | 21.10 | 2.35% |
...
```
