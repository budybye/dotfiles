#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
check_proof.py
----------------
簡易的な証明ステップの自動採点ツール。
入力は標準入力から、番号付きステップ形式のテキストを受け取ります。
例:
    1. f ∘ id = f
    2. id ∘ g = g
    3. (g ∘ f) ∘ h = g ∘ (f ∘ h)

出力はステップが全部揃っているかのチェックと、欠落番号の一覧を返します。
"""
import sys
import re

def parse_steps(text):
    steps = {}
    for line in text.splitlines():
        m = re.match(r"^\s*(\d+)\.\s*(.+)$", line)
        if m:
            steps[int(m.group(1))] = m.group(2).strip()
    return steps

def main():
    data = sys.stdin.read()
    steps = parse_steps(data)
    if not steps:
        print("[error] No numbered steps detected.")
        sys.exit(1)
    max_step = max(steps.keys())
    missing = [i for i in range(1, max_step + 1) if i not in steps]
    if missing:
        print(f"⚠️  欠落ステップ: {missing}")
    else:
        print("✅  全ステップが揃っています！")

if __name__ == "__main__":
    main()
