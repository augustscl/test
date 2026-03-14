#!/usr/bin/env bun

const API_KEY = "mkt_fHydsJOjfZCrjaVA4FZh7vw1TD54TlMuqUF-cLmEGWk";
const API_URL = "https://mkapi2.dfcfs.com/finskillshub/api/claw/query";

async function query(queryStr: string) {
  const response = await fetch(API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "apikey": API_KEY,
    },
    body: JSON.stringify({ toolQuery: queryStr }),
  });

  const data = await response.json();
  return data;
}

// CLI
const args = process.argv.slice(2);
if (args.length === 0) {
  console.log("Usage: bun run query.ts <query>");
  console.log("Example: bun run query.ts 东方财富最新价");
  process.exit(1);
}

const queryStr = args.join(" ");
console.log("Querying:", queryStr);

const result = await query(queryStr);
console.log(JSON.stringify(result, null, 2));
