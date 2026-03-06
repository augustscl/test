
const https = require('https');

const APP_ID = 'cli_a92027f8bbb85bc6';
const APP_SECRET = 'qHbubWguafLFd1NppHnXcdIDXf84WXl4';
const CHAT_ID = 'oc_4e3daa6139b1eb7beebec0de6dcef569';

function request(options, data = null) {
  return new Promise(function(resolve, reject) {
    const req = https.request(options, function(res) {
      let body = '';
      res.on('data', function(chunk) { body += chunk; });
      res.on('end', function() {
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

async function main() {
  // 获取 tenant_access_token
  const authOptions = {
    hostname: 'open.feishu.cn',
    path: '/open-apis/auth/v3/tenant_access_token/internal',
    method: 'POST',
    headers: { 'Content-Type': 'application/json' }
  };
  const authResult = await request(authOptions, { app_id: APP_ID, app_secret: APP_SECRET });
  const token = authResult.tenant_access_token;

  // 拉取消息
  const msgOptions = {
    hostname: 'open.feishu.cn',
    path: '/open-apis/im/v1/messages?container_id_type=chat&container_id=' + CHAT_ID + '&sort_type=ByCreateTimeDesc&page_size=100',
    method: 'GET',
    headers: { 'Authorization': 'Bearer ' + token }
  };
  const msgResult = await request(msgOptions);

  // 过滤过去1小时的消息
  const oneHourAgo = Date.now() - 3600 * 1000;
  const messages = (msgResult.data?.items || []).filter(function(item) {
    return parseInt(item.create_time, 10) >= oneHourAgo;
  }).reverse();

  console.log(JSON.stringify(messages, null, 2));
}

main().catch(function(e) {
  console.error('Error:', e);
  process.exit(1);
});
