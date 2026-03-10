#!/usr/bin/env python3
"""
虾王群消息总结脚本
使用 tenant_access_token 调用飞书 API 获取群消息
"""

import requests
import json
import time
import sys
from datetime import datetime, timedelta

# 配置
APP_ID = "cli_a92027f8bbb85bc6"
APP_SECRET = "qHbubWguafLFd1NppHnXcdIDXf84WXl4"
CHAT_ID = "oc_4e3daa6139b1eb7beebec0de6dcef569"

# 获取 tenant_access_token
def get_tenant_access_token():
    url = "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal"
    payload = {
        "app_id": APP_ID,
        "app_secret": APP_SECRET
    }
    response = requests.post(url, json=payload)
    data = response.json()
    if data.get("code") != 0:
        raise Exception(f"获取 tenant_access_token 失败: {data}")
    return data["tenant_access_token"]

# 获取群消息
def get_messages(tenant_access_token, chat_id, hours_ago=1):
    url = f"https://open.feishu.cn/open-apis/im/v1/messages"
    headers = {
        "Authorization": f"Bearer {tenant_access_token}"
    }
    params = {
        "container_id_type": "chat",
        "container_id": chat_id,
        "sort_type": "ByCreateTimeDesc",
        "page_size": 50
    }
    response = requests.get(url, headers=headers, params=params)
    data = response.json()
    if data.get("code") != 0:
        raise Exception(f"获取消息失败: {data}")
    return data.get("data", {}).get("items", [])

# 过滤指定时间范围内的消息
def filter_messages_by_time(messages, hours_ago=1):
    cutoff_time = int((datetime.now() - timedelta(hours=hours_ago)).timestamp() * 1000)
    filtered = []
    for msg in messages:
        create_time = int(msg.get("create_time", 0))
        if create_time >= cutoff_time:
            filtered.append(msg)
    return filtered

# 解析消息内容
def parse_message_content(msg):
    msg_type = msg.get("msg_type", "")
    try:
        body = json.loads(msg.get("body", "{}"))
        if msg_type == "text":
            return body.get("content", "")
        return f"[{msg_type}]"
    except:
        return msg.get("body", "")

# 主函数
def main():
    try:
        # 获取 token
        token = get_tenant_access_token()
        
        # 获取消息
        messages = get_messages(token, CHAT_ID)
        
        # 过滤最近 1 小时的消息
        recent_messages = filter_messages_by_time(messages, 1)
        
        if not recent_messages:
            print(json.dumps({"count": 0, "messages": []}, ensure_ascii=False))
            return 0
        
        # 准备输出数据
        result = {
            "count": len(recent_messages),
            "messages": []
        }
        
        for msg in recent_messages:
            content = parse_message_content(msg)
            sender = msg.get("sender", {}).get("sender_id", {}).get("open_id", "未知用户")
            result["messages"].append({
                "sender": sender,
                "content": content,
                "create_time": msg.get("create_time"),
                "message_id": msg.get("message_id")
            })
        
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return 0
        
    except Exception as e:
        print(f"错误: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    sys.exit(main())
