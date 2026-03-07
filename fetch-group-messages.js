#!/usr/bin/env node
/**
 * 虾王群消息总结脚本
 * 使用 tenant_access_token 调用飞书 API 获取群消息并生成总结
 */

import * as Lark from "@larksuiteoapi/node-sdk";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// 配置文件路径
const CONFIG_PATH = path.join(process.env.HOME, ".openclaw", "openclaw.json");

// 群聊 ID（从 cron 任务中获取）
const CHAT_ID = "oc_4e3daa6139b1eb7beebec0de6dcef569";

// 加载配置
function loadConfig() {
  try {
    const configData = fs.readFileSync(CONFIG_PATH, "utf8");
    return JSON.parse(configData);
  } catch (err) {
    console.error("无法加载配置文件:", err.message);
    process.exit(1);
  }
}

// 获取飞书账户配置
function getFeishuAccount(config) {
  const feishuConfig = config?.plugins?.feishu;
  if (!feishuConfig) {
    console.error("未找到飞书插件配置");
    process.exit(1);
  }

  // 找到第一个启用的账户
  const accountId = Object.keys(feishuConfig.accounts || {}).find(
    (id) => feishuConfig.accounts[id].enabled
  );

  if (!accountId) {
    console.error("未找到启用的飞书账户");
    process.exit(1);
  }

  return feishuConfig.accounts[accountId];
}

// 创建 Lark 客户端
function createLarkClient(account) {
  return new Lark.Client({
    appId: account.appId,
    appSecret: account.appSecret,
    appType: Lark.AppType.SelfBuild,
    domain: Lark.Domain.Feishu,
  });
}

// 获取 tenant_access_token（虽然 SDK 会自动处理，但我们这里直接用 SDK）
async function fetchMessages(client, chatId, hoursAgo = 1) {
  const now = Date.now();
  const startTime = now - hoursAgo * 60 * 60 * 1000;

  // 调用飞书 API 获取消息
  // 注意：这个 API 需要 tenant_access_token，SDK 会自动处理
  const res = await client.request({
    method: "GET",
    url: "/open-apis/im/v1/messages",
    params: {
      container_id_type: "chat",
      container_id: chatId,
      sort_type: "ByCreateTimeDesc",
      page_size: 50,
    },
  });

  if (res.code !== 0) {
    throw new Error(`API 调用失败: ${res.msg} (code: ${res.code})`);
  }

  return res.data?.items || [];
}

// 过滤指定时间范围内的消息
function filterMessagesByTime(messages, hoursAgo = 1) {
  const now = Date.now();
  const startTime = now - hoursAgo * 60 * 60 * 1000;

  return messages.filter((msg) => {
    const createTime = parseInt(msg.create_time, 10);
    return createTime >= startTime;
  });
}

// 解析消息内容
function parseMessageContent(msg) {
  try {
    if (msg.msg_type === "text") {
      const body = JSON.parse(msg.body);
      return body.content || "";
    }
    return `[${msg.msg_type}]`;
  } catch {
    return msg.body || "";
  }
}

// 生成总结
function generateSummary(messages) {
  if (messages.length === 0) {
    return null;
  }

  // 按时间排序（最新的在后面）
  const sortedMessages = [...messages].sort(
    (a, b) => parseInt(a.create_time, 10) - parseInt(b.create_time, 10)
  );

  // 提取消息内容
  const messageTexts = sortedMessages.map((msg) => {
    const content = parseMessageContent(msg);
    const sender = msg.sender?.sender_id?.open_id || "未知用户";
    return `[${sender}] ${content}`;
  });

  // 这里可以集成 AI 来生成更智能的总结
  // 暂时我们先简单输出消息列表，让调用者处理

  return {
    count: messages.length,
    messages: sortedMessages,
    messageTexts,
  };
}

// 主函数
async function main() {
  try {
    console.error("加载配置...");
    const config = loadConfig();

    console.error("获取飞书账户...");
    const account = getFeishuAccount(config);

    console.error("创建 Lark 客户端...");
    const client = createLarkClient(account);

    console.error("获取群消息...");
    const allMessages = await fetchMessages(client, CHAT_ID);

    console.error("过滤最近 1 小时的消息...");
    const recentMessages = filterMessagesByTime(allMessages, 1);

    console.error(`找到 ${recentMessages.length} 条消息`);

    if (recentMessages.length === 0) {
      console.error("没有新消息");
      process.exit(0);
    }

    // 生成总结数据
    const summary = generateSummary(recentMessages);

    // 输出 JSON 供调用者处理
    console.log(JSON.stringify(summary, null, 2));
  } catch (err) {
    console.error("执行失败:", err);
    process.exit(1);
  }
}

main();
