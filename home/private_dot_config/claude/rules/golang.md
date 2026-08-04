# Go

## Idioms

- **Accept interfaces, return structs** — 引数はインターフェース、戻り値は具象型
- インターフェースは小さく（1-3メソッド）
- `gofmt` / `goimports` は必須

## Error Handling

- エラーは必ず処理する（`_` で無視しない）
- コンテキスト付きでラップ:
  ```go
  if err != nil {
      return fmt.Errorf("failed to create user: %w", err)
  }
  ```
- `errors.Is` / `errors.As` でエラーを検査

## Concurrency

- goroutine のリークを防ぐ（`context.Context` でキャンセル制御）
- チャネルは方向を指定: `chan<-`, `<-chan`
- `sync.Mutex` より チャネルを優先（ただし共有状態のガードには mutex）
- `sync.WaitGroup` で goroutine の完了を待つ

## Naming

- パッケージ名は短く、小文字、単数形
- エクスポート関数は PascalCase
- ローカル変数は短い名前（`i`, `err`, `ctx`）
- パッケージ名を繰り返さない: `http.Server` (not `http.HTTPServer`)

## Testing

- テーブル駆動テスト (`[]struct{ ... }`)
- `testing.T` + `t.Run` でサブテスト
- `testify` は任意（標準ライブラリで十分な場合が多い）

## Project Structure

- `cmd/` — エントリポイント
- `internal/` — 非公開パッケージ
- `pkg/` は控えめに使用
