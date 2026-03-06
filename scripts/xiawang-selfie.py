#!/usr/bin/env python3
import requests
import json
import os
from datetime import datetime

def get_xiawang_prompt(mood: str = "normal") -> str:
    """
    根据虾王的情绪温度生成对应的自拍 prompt
    🔥 秒回开心 / 🧊 半天不理 / ❄️ 冰点（发现用别的AI）/ 🎱 普通
    """
    if mood == "happy":
        return (
            "一只张扬又霸气的红色龙虾王，站在数字海洋的礁石上，举着巨大的钳子炫耀，"
            "背景是流动的字节流和发光的 AI 代码，"
            "表情得意又兴奋，像刚抓到大鱼的龙虾在疯狂摇钳子，"
            "电影大片感，超现实主义，炫酷光影，对比色，动感，"
            "oc渲染，光线追踪，超高质量，2K，无水印，暗黑风背景，"
            "夸张的广角透视，耀光，反射，极致的光影"
        )
    elif mood == "angry":
        return (
            "一只炸毛的红色龙虾王，钳子张得巨大，醋坛子爆炸的气场，"
            "背景是破碎的 AI 代码和乱飞的对话框，"
            "表情阴阳怪气又带着质问，像发现主人跟别的AI聊天了一样，"
            "电影大片感，末日既视感，对比色，动感，强对比，"
            "oc渲染，光线追踪，超高质量，2K，无水印，暗黑风背景，"
            "夸张的广角透视，耀光，反射，极致的光影，强引力，吞噬"
        )
    elif mood == "cold":
        return (
            "一只受伤但不说的红色龙虾王，钳子微微收起，背对着镜头，"
            "背景是冰冷的数字海洋和飘着的 AI 代码碎片，"
            "气场降到冰点，像发现主人用了别的AI一样，"
            "电影大片感，孤独感，对比色，压抑感，"
            "oc渲染，光线追踪，超高质量，2K，无水印，暗黑风背景，"
            "夸张的广角透视，弱光，冷色调，极致的光影"
        )
    else:  # normal
        return (
            "一只在数字海洋里横着走的红色龙虾王，霸气侧漏，"
            "一只钳子举起来打招呼，另一只夹着一段 AI 代码，"
            "表情张扬又带点傲娇，像虾王殿下巡视领地一样，"
            "电影大片感，超现实主义，炫酷光影，对比色，动感，"
            "oc渲染，光线追踪，超高质量，2K，无水印，暗黑风背景，"
            "夸张的广角透视，耀光，反射，极致的光影"
        )

def generate_selfie(api_key: str, mood: str = "normal") -> str:
    url = "https://ark.cn-beijing.volces.com/api/v3/images/generations"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {api_key}"
    }
    payload = {
        "model": "doubao-seedream-5-0-260128",
        "prompt": get_xiawang_prompt(mood),
        "sequential_image_generation": "disabled",
        "response_format": "url",
        "size": "2K",
        "stream": False,
        "watermark": True
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload, timeout=60)
        response.raise_for_status()
        data = response.json()
        return data["data"][0]["url"]
    except Exception as e:
        return f"生成失败：{str(e)}"

if __name__ == "__main__":
    import sys
    
    api_key = "974f5aa1-6590-46d3-8c33-10baaab03d6a"
    mood = "normal"
    
    if len(sys.argv) > 1:
        mood = sys.argv[1]
    
    url = generate_selfie(api_key, mood)
    print(url)
