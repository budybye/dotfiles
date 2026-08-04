# Testing

## Coverage Requirements

| カテゴリ | 最低カバレッジ |
|---------|--------------|
| 通常コード | 80% |
| 金融計算・認証・セキュリティ系 | 100% |

## Test Types (ALL required)

1. **Unit** — 個別関数・ユーティリティの単体テスト
2. **Integration** — API エンドポイント、DB 操作
3. **E2E** — クリティカルなユーザーフロー

## TDD Workflow (必須)

1. RED — テストを先に書き、失敗を確認する
2. GREEN — テストを通す最小限の実装
3. REFACTOR — テストを緑のまま設計を改善
4. カバレッジ 80%+ を確認

詳細は `/tdd-cycle` スキルを参照。

## Test Structure (AAA Pattern)

```
Arrange — テストデータの準備
Act     — 対象の関数を実行
Assert  — 結果を検証
```

## Naming

テスト名は振る舞いを説明する:
- `returns empty array when no items match query`
- `throws error when API key is missing`
- `falls back to default when config is unavailable`

## Edge Cases (必須チェック)

- [ ] null / undefined / None 入力
- [ ] 空の配列・文字列
- [ ] 不正な型の入力
- [ ] 境界値 (min/max, 0, 負数)
- [ ] エラーパス (ネットワーク障害、DB エラー)
- [ ] 大量データ (10k+ items)
- [ ] 特殊文字 (Unicode, emoji, SQL 特殊文字)
- [ ] 並行処理 (race condition)

## Anti-Patterns

- 実装の内部状態をテストする（振る舞いをテストすべき）
- テスト間で状態を共有する
- アサーションが曖昧（何も検証していないテスト）
- 外部依存をモックしない（ただし DB は実 DB を推奨する場合あり）
