
const fs = require('fs');
const path = require('path');

// 读取配置文件
const configPath = '/Users/suchuanlei/.openclaw/openclaw.json';
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const appId = config.channels.feishu.appId;
const appSecret = config.channels.feishu.appSecret;

// 飞书 API 基础 URL
const BASE_URL = 'https://open.feishu.cn';

// 获取 tenant_access_token
async function getTenantAccessToken() {
  const res = await fetch(`${BASE_URL}/open-apis/auth/v3/tenant_access_token/internal`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ app_id: appId, app_secret: appSecret })
  });
  const data = await res.json();
  if (data.code !== 0) {
    throw new Error(`获取 tenant_access_token 失败: ${JSON.stringify(data)}`);
  }
  return data.tenant_access_token;
}

// 获取群消息
async function getMessages(tenantAccessToken, chatId, startTime, endTime) {
  const url = new URL(`${BASE_URL}/open-apis/im/v1/messages`);
  url.searchParams.set('container_id_type', 'chat');
  url.searchParams.set('container_id', chatId);
  url.searchParams.set('start_time', Math.floor(startTime / 1000));
  url.searchParams.set('end_time', Math.floor(endTime / 1000));
  url.searchParams.set('page_size', '50');
  url.searchParams.set('sort_type', 'ByCreateTimeAsc');

  const res = await fetch(url.toString(), {
    method: 'GET',
    headers: { 'Authorization': `Bearer ${tenantAccessToken}` }
  });
  const data = await res.json();
  if (data.code !== 0) {
    throw new Error(`获取消息失败: ${JSON.stringify(data)}`);
  }
  return data.data;
}

// 获取用户信息
async function getUserInfo(tenantAccessToken, userId) {
  const res = await fetch(`${BASE_URL}/open-apis/contact/v3/users/${userId}`, {
    method: 'GET',
    headers: { 'Authorization': `Bearer ${tenantAccessToken}` }
  });
  const data = await res.json();
  if (data.code !== 0) {
    return null;
  }
  return data.data.user;
}

// 主函数
async function main() {
  const now = Date.now();
  const oneHourAgo = now - 3600 * 1000;

  const tenantAccessToken = await getTenantAccessToken();
  const messages = await getMessages(
    tenantAccessToken,
    'oc_4e3daa6139b1eb7beebec0de6dcef569',
    oneHourAgo,
    now
  );

  // 获取发送者信息
  const userMap = new Map();
  for (const item of messages.items || []) {
    if (item.sender?.id && !userMap.has(item.sender.id)) {
      const user = await getUserInfo(tenantAccessToken, item.sender.id);
      if (user) {
        userMap.set(item.sender.id, user);
      }
    }
  }

  // 输出结果
  console.log(JSON.stringify({
    messages: messages.items || [],
    users: Object.fromEntries(userMap),
    startTime: oneHourAgo,
    endTime: now
  }, null, 2));
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
