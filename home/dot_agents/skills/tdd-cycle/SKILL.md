---
name: tdd-cycle
description: "t-wada style TDD: one test per cycle, verify Red, minimal Green, mandatory Refactor. [Triggers: /tdd-cycle, red-green-refactor, test-driven, failing test first]"
disable-model-invocation: true
---

# /tdd-cycle — Red → Green → Refactor（週一）

テスト駆動は **自動テストでも先行テストでもなく**、テストと実装を交互に 1 本ずつ進めて設計フィードバックを取る工程。**リスト駆動 + リファクタ義務**がセット。

## 定義（t-wada / Kent Beck）

1. シナリオを **Test List** に書く。
2. **1 項目だけ**選び、実行可能なテストにして **意図した理由で落ちる** ところまで確認（Red）。
3. **そのテストを通す最小の実装**（定数返し OK）。次のテストが要求する先取り実装は禁止（Green）。
4. **挙動を変えず**構造を整える（Refactor）。
5. リストが空になるまで 2 に戻る。

## ステージ混同禁止

| 名前       | 内容                          | それ単体が TDD？ |
| ---------- | ----------------------------- | ---------------- |
| 自動テスト | テストコードがあり CI で回る  | いいえ（前提）   |
| Test-First | 先にテストを書く              | 一部だけ         |
| TDD        | 1 本ずつ交互 + 設計改善ループ | **これ**         |

## Red の合格条件

- `SyntaxError` / `ModuleNotFound` / インポート事故での失敗は **Red としてカウントしない**（テストを直す）。
- 「未実装」「アサーション不一致」など **仕様に関する失敗** が Red。

## Green の心得

- 過不足なくそのテストだけを満たす。**次の一般化は次のテストが強制するまで保留**。

## Refactor の心得

- 重複・命名・長さ・抽象漏れを見る。**テストが赤になったら最後の Green に戻る**。

## Anti-pattern 早見表

| NG                                 | 理由                                               |
| ---------------------------------- | -------------------------------------------------- |
| Red 未確認で進む                   | テストが本当に狙いを撃ってないかわからない         |
| Green でついで機能                 | 未テストコードが増える                             |
| Refactor で挙動変更                | 安全網が意味を失う                                 |
| テストが書きにくいのを無理やり書く | **設計が悪いサイン** → production 側の形を先に直す |
| 複数テスト同時                     | 壊れた時にどれが原因か分からない                   |
| Refactor スキップ                  | 技術的負債が複利                                   |

## 進捗の記録

| ファイル                                     | 役割                         |
| -------------------------------------------- | ---------------------------- |
| `test/testlist.md`（またはプロジェクト標準） | シナリオ・TC-ID・状態        |
| `test/TDD.md`                                | ダッシュボード・サイクルログ |
| `**/*.test.*` 等                             | 実行コード                   |

コミットメッセージに TC-ID を含めるとトレースしやすい。

## ミニ例（TypeScript + Vitest）

```ts
// fizzbuzz.test.ts
import { describe, it, expect } from "vitest";
import { fizzbuzz } from "./fizzbuzz";
describe("fizzbuzz", () => {
	it("returns '1' when passed 1", () => expect(fizzbuzz(1)).toBe("1"));
});
```

Red 後に `return "1"` だけ実装して Green → 次のケースで `String(n)` へ一般化、のように **三角測量** で進める。

## Workers / HTTP っぽいコード

fetch を `undici` / MSW / `SELF.fetch` スタブで切って **Red を安定させる**。統合テストは別サイクルで増やす。
