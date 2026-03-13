#!/usr/bin/env python3
"""
Test credit endpoints using the existing setup.
Run with: python3 scripts/run.py test_credit.py
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'scripts'))

from api_client import YoumindApiClient

def main():
    client = YoumindApiClient()
    
    endpoints = [
        ("/api/v1/user/getProfile", {}),
        ("/api/v1/user/getBalance", {}),
        ("/api/v1/credit/getCredit", {}),
        ("/api/v1/subscription/getSubscription", {}),
        ("/api/v1/wallet/getWallet", {}),
        ("/api/v1/user/getInfo", {}),
        ("/api/v1/getProfile", {}),
        ("/api/v1/favorite/listFavorites", {}),
    ]
    
    print("🦐 虾王殿下正在帮你查Youmind积分...\n")
    
    for path, payload in endpoints:
        try:
            print(f"➡️  尝试: POST {path}")
            result = client._post(path, payload)
            print(f"✅ 成功:\n{result}\n")
        except Exception as e:
            print(f"❌ 失败: {e}\n")

if __name__ == "__main__":
    main()
