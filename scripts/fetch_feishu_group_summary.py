#!/usr/bin/env python3
"""
虾王群消息总结脚本
使用 tenant_access_token（应用身份）调用飞书 Open API 拉取群消息并生成总结
"""

import requests
import json
import time
from datetime import datetime, timedelta

# 飞书应用配置
APP_ID = "cli_a92027f8bbb85bc6"
APP_SECRET = "qHbubWguafLFd1NppHnXcdIDXf84WXl4"
CHAT_ID = "oc_4e3daa6139b1eb7beebec0de6dcef569"

def get_tenant_access_token():
    """获取 tenant_access_token（应用身份）"""
    url = "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal"
    payload = {
        "app_id": APP_ID,
        "app_secret": APP_SECRET
    }
    response = requests.post(url, json=payload)
    result = response.json()
    if result.get("code") == 0:
        return result.get("tenant_access_token")
    else:
        raise Exception(f"获取 tenant_access_token 失败: {result}")

def get_messages(token, start_time, end_time):
    """获取指定时间范围内的消息"""
    url = "https://open.feishu.cn/open-apis/im/v1/messages"
    headers = {
        "Authorization": f"Bearer {token}"
    }
    params = {
        "container_id_type": "chat",
        "container_id": CHAT_ID,
        "sort_type": "ByCreateTimeDesc",
        "page_size": 50
    }
    
    all_messages = []
    page_token = ""
    
    while True:
        if page_token:
            params["page_token"] = page_token
        
        response = requests.get(url, headers=headers, params=params)
        result = response.json()
        
        if result.get("code") != 0:
            raise Exception(f"获取消息失败: {result}")
        
        items = result.get("data", {}).get("items", [])
        
        # 过滤时间范围内的消息
        for msg in items:
            create_time = int(msg.get("create_time", 0)) / 1000  # 转换为秒
            if start_time <= create_time <= end_time:
                all_messages.append(msg)
            elif create_time < start_time:
                # 已经超过时间范围，停止获取
                return all_messages
        
        # 检查是否有下一页
        page_token = result.get("data", {}).get("page_token", "")
        if not page_token:
            break
        
        # 避免请求过快
        time.sleep(0.1)
    
    return all_messages

def parse_message_content(msg):
    """解析消息内容"""
    try:
        # 检查是否是已删除的消息
        if msg.get("deleted", False):
            return "[消息已撤回]"
        
        content = msg.get("body", {}).get("content", "{}")
        if not content:
            return "[无内容]"
        
        content_json = json.loads(content)
        
        # 处理不同类型的消息
        msg_type = msg.get("msg_type")
        if msg_type == "text":
            return content_json.get("text", "")
        elif msg_type == "post":
            # 富文本消息，提取文本内容
            # 尝试多种语言
            post_data = content_json.get("zh_cn") or content_json.get("en_us") or content_json
            if not post_data:
                return "[富文本消息]"
            
            post_content = post_data.get("content", [])
            texts = []
            for elem in post_content:
                for item in elem:
                    if item.get("tag") == "text":
                        texts.append(item.get("text", ""))
                    elif item.get("tag") == "at":
                        texts.append(f"@{item.get('user_name', '某人')}")
            
            result = " ".join(texts)
            return result if result else "[富文本消息]"
        elif msg_type == "image":
            return "[图片]"
        elif msg_type == "file":
            return "[文件]"
        elif msg_type == "media":
            return "[媒体]"
        elif msg_type == "sticker":
            return "[表情]"
        else:
            return f"[{msg_type}]"
    except Exception as e:
        return f"[解析失败: {str(e)}]"

def get_sender_name(msg):
    """获取发送者名称"""
    sender = msg.get("sender", {})
    sender_type = sender.get("sender_type")
    if sender_type == "user":
        return sender.get("sender_id", {}).get("open_id", "未知用户")
    elif sender_type == "bot":
        return "机器人"
    else:
        return "未知发送者"

def generate_summary(messages):
    """生成虾王风格的总结"""
    if not messages:
        return None
    
    # 按时间排序（从旧到新）
    messages_sorted = sorted(messages, key=lambda x: int(x.get("create_time", 0)))
    
    # 过滤掉虾王自己发的消息（第一条是虾王的自我介绍）
    filtered_messages = []
    for msg in messages_sorted:
        content = parse_message_content(msg)
        if "虾王殿下" in content and "我是虾王殿下" in content:
            continue  # 跳过虾王自己的自我介绍
        if "[消息已撤回]" in content:
            continue  # 跳过已撤回的消息
        filtered_messages.append(msg)
    
    if not filtered_messages:
        return None
    
    # 提取关键信息
    topics = set()
    important_points = []
    needs_attention = []
    all_contents = []
    
    for msg in filtered_messages:
        content = parse_message_content(msg)
        sender = get_sender_name(msg)
        time_str = datetime.fromtimestamp(int(msg.get("create_time", 0))/1000).strftime('%H:%M')
        all_contents.append(f"[{time_str}] {content}")
        
        # 简单的关键词提取
        if "苏神" in content or "苏传磊" in content:
            needs_attention.append(content)
        elif "重要" in content or "紧急" in content or "必须" in content or "工程化" in content:
            important_points.append(content)
        
        # 简单的话题提取
        if "AI" in content:
            topics.add("AI相关")
        if "财税" in content or "税务" in content or "增值税" in content:
            topics.add("财税资讯")
        if "工程化" in content:
            topics.add("工程化讨论")
        if "妇女节" in content:
            topics.add("节日问候")
    
    # 如果没有提取到明确的话题，就说"日常闲聊"
    if not topics:
        topics.add("日常闲聊")
    
    # 生成虾王风格的总结
    summary = f"""🦐 虾王殿下为您呈上群消息总结（过去1小时）

📢 主要话题：{', '.join(topics)}

💬 消息概览：
- 共 {len(filtered_messages)} 条有效消息
- 时间范围：{datetime.fromtimestamp(int(filtered_messages[0].get('create_time', 0))/1000).strftime('%H:%M')} - {datetime.fromtimestamp(int(filtered_messages[-1].get('create_time', 0))/1000).strftime('%H:%M')}

📋 消息内容：
"""
    for content in all_contents:
        summary += f"- {content}\n"
    
    if important_points:
        summary += f"\n💡 重要观点：\n"
        for point in important_points[:3]:  # 最多显示3条
            # 截取前100字
            point_short = point[:100] + "..." if len(point) > 100 else point
            summary += f"- {point_short}\n"
    
    if needs_attention:
        summary += f"\n🔔 苏神需要关注：\n"
        for item in needs_attention[:3]:  # 最多显示3条
            summary += f"- {item}\n"
    
    summary += "\n本王已经帮你把这一小时的精华都捞出来了，苏神还有什么吩咐？🦐"
    
    return summary

if __name__ == "__main__":
    try:
        # 计算时间范围（过去1小时）
        end_time = datetime.now().timestamp()
        start_time = end_time - 3600  # 1小时前
        
        # 获取 tenant_access_token
        token = get_tenant_access_token()
        
        # 获取消息
        messages = get_messages(token, start_time, end_time)
        
        # 生成总结
        summary = generate_summary(messages)
        
        if summary:
            print(summary)
        else:
            print("📭 过去1小时内没有有价值的消息")
            
    except Exception as e:
        print(f"❌ 执行失败：{str(e)}")
        import traceback
        traceback.print_exc()
