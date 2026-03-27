#!/usr/bin/env bun

const API_KEY = process.env.MX_APIKEY;
const API_URL = "https://mkapi2.dfcfs.com/finskillshub/api/claw/stock-screen";

if (!API_KEY) {
  throw new Error("Missing MX_APIKEY environment variable");
}

async function selectStock(keyword: string, pageNo = 1, pageSize = 20) {
  const response = await fetch(API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "apikey": API_KEY,
    },
    body: JSON.stringify({ keyword, pageNo, pageSize }),
  });

  const data = await response.json();
  return data;
}

// CLI
const args = process.argv.slice(2);
if (args.length === 0) {
  console.log("Usage: bun run select.ts <keyword>");
  console.log("Example: bun run select.ts 今日涨幅2%的股票");
  process.exit(1);
}

const keyword = args.join(" ");
console.log("Selecting stocks:", keyword);

const result = await selectStock(keyword);
console.log(JSON.stringify(result, null, 2));
