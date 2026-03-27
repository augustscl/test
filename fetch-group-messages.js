#!/usr/bin/env node
/**
 * 飞书群消息获取脚本
 * 使用 tenant_access_token 调用飞书 Open API 获取群消息
 */

const Lark = require('/Users/suchuanlei/.openclaw/extensions/feishu-openclaw-plugin/node_modules/@larksuiteoapi/node-sdk');

// 从配置文件获取的凭证
const appId = 'cli_a92027f8bbb85bc6';
const appSecret = 'qHbubWguafLFd1NppHnXcdIDXf84WXl4';
const chatId = 'oc_4e3daa6139b1eb7beebec0de6dcef569';

// 计算过去1小时的时间戳（毫秒）
const oneHourAgo = Date.now() - 60 * 60 * 1000;

async function main() {
  try {
    console.log('正在初始化飞书客户端...');
    
    // 创建飞书客户端（使用应用身份）
    const client = new Lark.Client({
      appId,
      appSecret,
      appType: Lark.AppType.SelfBuild,
      domain: Lark.Domain.Feishu,
    });

    console.log('正在获取群消息...');
    
    // 调用获取消息列表 API
    const response = await client.request({
      method: 'GET',
      url: '/open-apis/im/v1/messages',
      params: {
        container_id_type: 'chat',
        container_id: chatId,
        sort_type: 'ByCreateTimeDesc',
        page_size: 50,
      },
    });

    if (response.code !== 0) {
      console.error('API 调用失败:', response.msg);
      process.exit(1);
    }

    console.log('消息获取成功！');
    
    // 过滤过去1小时内的消息
    const messages = (response.data?.items || []).filter(msg => {
      const createTime = parseInt(msg.create_time);
      return createTime >= oneHourAgo;
    });

    if (messages.length === 0) {
      console.log('过去1小时内没有消息');
      process.exit(0);
    }

    console.log(`找到 ${messages.length} 条消息（过去1小时内）`);
    console.log('='.repeat(80));
    
    // 输出消息内容（反向排序，按时间正序）
    messages.reverse().forEach((msg, index) => {
      const time = new Date(parseInt(msg.create_time)).toLocaleString('zh-CN');
      console.log(`[${time}] ${msg.sender?.sender_id?.open_id || '未知发送者'}:`);
      console.log(msg.body?.content || '');
      console.log('-'.repeat(80));
    });

  } catch (error) {
    console.error('执行出错:', error);
    process.exit(1);
  }
}

main();
