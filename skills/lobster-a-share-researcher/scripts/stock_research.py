#!/usr/bin/env python3
"""龙虾A股研究员 - 基于 AkShare 的研究脚本

输出 JSON，供上层 Skill 组织成自然语言回答。
"""
import argparse
import json
import sys
import os
from datetime import datetime, timedelta

# 默认关闭代理，避免本机代理对 EastMoney / AkShare 请求造成干扰
for _k in ['http_proxy', 'https_proxy', 'all_proxy', 'HTTP_PROXY', 'HTTPS_PROXY', 'ALL_PROXY']:
    os.environ.pop(_k, None)

try:
    import akshare as ak
    import pandas as pd
except ImportError:
    print(json.dumps({"error": "请先安装依赖: pip install akshare pandas"}, ensure_ascii=False))
    sys.exit(1)


def _safe_records(df, limit=None):
    if df is None:
        return []
    if limit is not None:
        df = df.head(limit)
    return df.fillna("").to_dict(orient="records")


def search_stock(keyword: str):
    df = ak.stock_zh_a_spot_em()
    result = df[df['代码'].astype(str).str.contains(keyword) | df['名称'].astype(str).str.contains(keyword)]
    return _safe_records(result, 10)


def quote(symbol: str = None, keyword: str = None):
    df = ak.stock_zh_a_spot_em()
    if symbol:
        df = df[df['代码'].astype(str) == symbol]
    elif keyword:
        df = df[df['名称'].astype(str).str.contains(keyword) | df['代码'].astype(str).str.contains(keyword)]
    return _safe_records(df, 10)


def kline(symbol: str, period: str = 'daily', days: int = 30):
    end_date = datetime.now().strftime('%Y%m%d')
    start_date = (datetime.now() - timedelta(days=days)).strftime('%Y%m%d')
    df = ak.stock_zh_a_hist(symbol=symbol, period=period, start_date=start_date, end_date=end_date, adjust='qfq')
    records = _safe_records(df)
    summary = {}
    if records:
        closes = [float(x['收盘']) for x in records if str(x.get('收盘', '')).strip() != '']
        if closes:
            summary = {
                "start_close": closes[0],
                "end_close": closes[-1],
                "change_pct": round((closes[-1] / closes[0] - 1) * 100, 2) if closes[0] else None,
                "high": max(closes),
                "low": min(closes),
                "days": days,
                "period": period,
            }
    return {"summary": summary, "records": records}


def industry():
    df = ak.stock_board_industry_name_em()
    return _safe_records(df, 20)


def concept():
    df = ak.stock_board_concept_name_em()
    return _safe_records(df, 20)


def fund_flow(symbol: str, market: str = 'sh'):
    # 修复原 skill 的 bug：这里必须显式通过 ak 调用
    df = ak.stock_individual_fund_flow(stock=symbol, market=market)
    return _safe_records(df, 20)


def financial(symbol: str):
    out = {}
    try:
        out['abstract'] = _safe_records(ak.stock_financial_abstract_ths(symbol=symbol, indicator='按报告期'), 8)
    except Exception as e:
        out['abstract_error'] = str(e)
    try:
        out['indicator'] = _safe_records(ak.stock_financial_analysis_indicator(symbol=symbol), 8)
    except Exception as e:
        out['indicator_error'] = str(e)
    return out


def compare(symbol1: str, symbol2: str):
    return {
        symbol1: financial(symbol1),
        symbol2: financial(symbol2),
    }


def main():
    parser = argparse.ArgumentParser(description='龙虾A股研究员')
    parser.add_argument('action', choices=['search', 'quote', 'kline', 'industry', 'concept', 'flow', 'financial', 'compare'])
    parser.add_argument('--symbol')
    parser.add_argument('--symbol2')
    parser.add_argument('--keyword')
    parser.add_argument('--period', default='daily', choices=['daily', 'weekly', 'monthly'])
    parser.add_argument('--days', type=int, default=30)
    parser.add_argument('--market', default='sh')
    args = parser.parse_args()

    try:
        if args.action == 'search':
            if not args.keyword:
                raise ValueError('search 需要 --keyword')
            data = search_stock(args.keyword)
        elif args.action == 'quote':
            data = quote(args.symbol, args.keyword)
        elif args.action == 'kline':
            if not args.symbol:
                raise ValueError('kline 需要 --symbol')
            data = kline(args.symbol, args.period, args.days)
        elif args.action == 'industry':
            data = industry()
        elif args.action == 'concept':
            data = concept()
        elif args.action == 'flow':
            if not args.symbol:
                raise ValueError('flow 需要 --symbol')
            data = fund_flow(args.symbol, args.market)
        elif args.action == 'financial':
            if not args.symbol:
                raise ValueError('financial 需要 --symbol')
            data = financial(args.symbol)
        elif args.action == 'compare':
            if not args.symbol or not args.symbol2:
                raise ValueError('compare 需要 --symbol 和 --symbol2')
            data = compare(args.symbol, args.symbol2)
        else:
            raise ValueError('未知 action')
        print(json.dumps({"ok": True, "action": args.action, "data": data}, ensure_ascii=False, indent=2))
    except Exception as e:
        print(json.dumps({"ok": False, "error": str(e), "action": args.action}, ensure_ascii=False, indent=2))
        sys.exit(1)


if __name__ == '__main__':
    main()
