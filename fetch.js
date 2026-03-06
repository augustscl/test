
const https = require('https');

const APP_ID = 'cli_a92027f8bbb85bc6';
const APP_SECRET = 'qHbubWguafLFd1NppHnXcdIDXf84WXl4';
const CHAT_ID = 'oc_4e3daa6139b1eb7beebec0de6dcef569';

function post(host, path, data) {
  return new Promise((res, rej) =&gt; {
    const req = https.request({
      hostname: host, path: path, method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }, (resp) =&gt; {
      let b = ''; resp.on('data', d => b += d);
      resp.on('end', () => res(JSON.parse(b)));
    });
    req.on('error', rej); req.write(JSON.stringify(data)); req.end();
  });
}

function get(host, path, token) {
  return new Promise((res, rej) => {
    const req = https.request({
      hostname: host, path: path, method: 'GET',
      headers: { 'Authorization': 'Bearer ' + token }
    }, (resp) => {
      let b = ''; resp.on('data', d => b += d);
      resp.on('end', () => res(JSON.parse(b)));
    });
    req.on('error', rej); req.end();
  });
}

async function run() {
  const auth = await post('open.feishu.cn', '/open-apis/auth/v3/tenant_access_token/internal', { app_id: APP_ID, app_secret: APP_SECRET });
  const token = auth.tenant_access_token;
  const msgs = await get('open.feishu.cn', '/open-apis/im/v1/messages?container_id_type=chat&container_id=' + CHAT_ID + '&sort_type=ByCreateTimeDesc&page_size=100', token);
  const oneHour = Date.now() - 3600000;
  const filtered = (msgs.data?.items || []).filter(m => parseInt(m.create_time) >= oneHour).reverse();
  console.log(JSON.stringify(filtered, null, 2));
}

run().catch(e => { console.error(e); process.exit(1); });
