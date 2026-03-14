#!/usr/bin/env bun

const API_KEY = "mkt_fHydsJOjfZCrjaVA4FZh7vw1TD54TlMuqUF-cLmEGWk";
const API_URL = "https://mkapi2.dfcfs.com/finskillshub/api/claw/news-search";

async function search(queryStr: string) {
  const response = await fetch(API_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "apikey": API_KEY,
    },
    body: JSON.stringify({ query: queryStr }),
  });

  const data = await response.json();
  return data;
}

// CLI
const args = process.argv.slice(2);
if (args.length === 0) {
  console.log("Usage: bun run search.ts <query>");
  console.log("Example: bun run search.ts 立讯精密资讯");
  process.exit(1);
}

const queryStr = args.join(" ");
console.log("Searching:", queryStr);

const result = await search(queryStr);
console.log(JSON.stringify(result, null, 2));
