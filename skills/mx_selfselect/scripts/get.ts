#!/usr/bin/env bun

const API_KEY = "mkt_fHydsJOjfZCrjaVA4FZh7vw1TD54TlMuqUF-cLmEGWk";
const API_URL_GET = "https://mkapi2.dfcfs.com/finskillshub/api/claw/self-select/get";

async function getSelfSelect() {
  const response = await fetch(API_URL_GET, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "apikey": API_KEY,
    },
    body: JSON.stringify({}),
  });

  const data = await response.json();
  return data;
}

console.log("Fetching self-selected stocks...");
const result = await getSelfSelect();
console.log(JSON.stringify(result, null, 2));
