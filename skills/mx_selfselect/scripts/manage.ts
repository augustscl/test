#!/usr/bin/env bun

const API_KEY = "mkt_fHydsJOjfZCrjaVA4FZh7vw1TD54TlMuqUF-cLmEGWk";
const API_URL_MANAGE = "https://mkapi2.dfcfs.com/finskillshub/api/claw/self-select/manage";

async function manageSelfSelect(query: string) {
  const response = await fetch(API_URL_MANAGE, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "apikey": API_KEY,
    },
    body: JSON.stringify({ query }),
  });

  const data = await response.json();
  return data;
}

// CLI
const args = process.argv.slice(2);
if (args.length === 0) {
  console.log("Usage: bun run manage.ts <query>");
  console.log("Example: bun run manage.ts 把东方财富加入自选");
  process.exit(1);
}

const query = args.join(" ");
console.log("Managing self-select:", query);

const result = await manageSelfSelect(query);
console.log(JSON.stringify(result, null, 2));
