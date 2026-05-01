---
name: category-theory
description: |
  圏論の概念解説、演習問題自動採点、Python での圏構造可視化を提供するスキル。使用例: 「圏の合成律を説明して」、
  「関手 F と G の自然変換を作成してください」、
  「小カテゴリ C の図を生成して」
---

# 圏論スキル – 使い方ガイド

## 目的
- 圏論の基礎概念や主要定理を簡潔に解説
- 演習問題を提示・自動採点
- `scripts/` にある Python スクリプトで圏の図や証明支援を実行

## 使い方

### 1. 概念・定理の解説
`references/basics.md`、`references/theorems.md` を必要に応じて読み込む。例: "圏の有限積の定義を教えて" → `basics.md` の該当節を出力。

### 2. 演習問題の提示と採点
`references/exercises.md` から問題を取得し、`scripts/check_proof.py` で解答を検証。例: "Adjunction の問題を出して" → 問題文を返し、解答が来たら採点結果を返す。

### 3. 圏構造の可視化
`scripts/generate_diagram.py` にカテゴリと射のリストを渡すと PNG/SVG を生成。例: "カテゴリ C のオブジェクトを A, B, C、射を f: A→B, g: B→C で図を描いて" → `diagram_template.tex` を埋め込み、画像を返す。

## 参考ファイルのロード方法
- **概念** → `[[load references/basics.md]]`
- **定理** → `[[load references/theorems.md]]`
- **演習** → `[[load references/exercises.md]]`

> **注意**
> SKILL 本体がロードされたときだけ、上記 `[[load …]]` が評価されます。不要な文脈を削減するため、ユーザーが求めた項目だけを読み込むようにしてください。

## カスタマイズ
- 新しい演習問題は `references/exercises.md` に `## <ID>` 見出しで追加。
- 新しいスクリプトは `scripts/` に配置し、`SKILL.md` の「使い方」セクションに手順を追記。
