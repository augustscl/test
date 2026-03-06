
const https = require('https');

// 从配置里拿到的凭证
const APP_ID = 'cli_a92027f8bbb85bc6';
const APP_SECRET = 'qHbubWguafLFd1NppHnXcdIDXf84WXl4';
const CHAT_ID = 'oc_4e3daa6139b1eb7beebec0de6dcef569';

// 辅助函数：发送HTTPS请求
function request(options, data = null) {
  return new Promise((resolve, reject) =&gt; {
    const req = https.request(options, (res) =&gt; {
      let body = '';
      res.on('data', (chunk) =&gt; body += chunk);
      res.on('end', () =&gt; {
        try {
          resolve(JSON.parse(body));
        } catch (e) {
          reject(e);
        }
      });
    });
    req.on('error', reject);
    if (data) req.write(JSON.stringify(data));
    req.end();
  });
}

// 1. 获取tenant_access_token
async function getTenantAccessToken() {
  const options = {
    hostname: 'open.feishu.cn',
    path: '/open-apis/auth/v3/tenant_access_token/internal',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    }
  };
  const data = {
    app_id: APP_ID,
    app_secret: APP_SECRET
  };
  const result = await request(options, data);
  if (result.code !== 0) {
    throw new Error(`获取tenant_access_token失败: ${JSON.stringify(result)}`);
  }
  return result.tenant_access_token;
}

// 2. 拉取群消息（过去1小时）
async function fetchMessages(tenantAccessToken) {
  const oneHourAgo = Date.now() - 3600 * 1000;
  const options = {
    hostname: 'open.feishu.cn',
    path: `/open-apis/im/v1/messages?container_id_type=chat&amp;container_id=${CHAT_ID}&amp;sort_type=ByCreateTimeDesc&amp;page_size=100`,
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${tenantAccessToken}`
    }
  };
  const result = await request(options);
  if (result.code !== 0) {
    throw new Error(`拉取消息失败: ${JSON.stringify(result)}`);
  }
  // 过滤过去1小时内的消息
  const messages = (result.data?.items || []).filter(item =&gt; {
    const createTime = parseInt(item.create_time, 10);
    return createTime &gt;= oneHourAgo;
  });
  return messages.reverse(); // 按时间正序排列
}

// 主函数
async function main() {
  try {
    const token = await getTenantAccessToken();
    const messages = await fetchMessages(token);
    console.log(JSON.stringify(messages, null, 2));
  } catch (error) {
    console.error('出错了:', error);
    process.exit(1);
  }
}

main();
