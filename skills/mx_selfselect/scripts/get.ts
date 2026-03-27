#!/usr/bin/env bun

const API_KEY = process.env.MX_APIKEY;
const API_URL_GET = "https://mkapi2.dfcfs.com/finskillshub/api/claw/self-select/get";

if (!API_KEY) {
  throw new Error("Missing MX_APIKEY environment variable");
}

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
