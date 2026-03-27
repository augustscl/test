---
name: mx_search
description: 妙想资讯搜索 skill，基于东方财富搜索金融资讯、新闻、公告、研报、政策等。触发条件：用户提到"搜资讯"、"新闻搜索"、"金融资讯"、"mx_search"等。
metadata:
  openclaw:
    emoji: "📰"
    requires:
      env: ["MX_APIKEY"]
    primaryEnv: "MX_APIKEY"
---

# 妙想资讯搜索 (mx_search)

搜索东方财富金融资讯、新闻、公告、研报、政策等。

## API 端点

```
POST https://mkapi2.dfcfs.com/finskillshub/api/claw/news-search
Headers:
  Content-Type: application/json
  apikey: {MX_APIKEY}
Body:
  {"query": "查询内容"}
```

## 使用方式

```bash
bun run scripts/search.ts "立讯精密资讯"
bun run scripts/search.ts "新能源政策解读"
bun run scripts/search.sh "今日A股大盘"
```

## 查询示例

| 类型 | 示例 |
|-----|------|
| 个股资讯 | "格力电器最新研报"、"贵州茅台机构观点" |
| 板块/主题 | "商业航天板块新闻"、"新能源政策解读" |
| 宏观/风险 | "美联储加息对A股影响"、"北向资金流向" |
| 综合解读 | "今日大盘异动原因" |

## 返回字段

- `title` - 资讯标题
- `secuList` - 关联证券列表
- `trunk` - 资讯正文

## 输出格式

```
📰 {资讯标题}
关联股票：{股票列表}
{正文摘要}
```
