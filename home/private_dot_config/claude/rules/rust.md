# Rust

## Ownership & Borrowing

- 所有権の移動は意図的に。不要なクローンを避ける
- 参照で十分な場合は `&T` / `&mut T` を使う
- ライフタイムは明示が必要な場合のみ注釈。エリジョンルールに任せる

## Error Handling

- 回復可能: `Result<T, E>` + `?` 演算子
- 回復不能: `panic!` / `unwrap` はテストコードのみ許可
- エラー型は `thiserror` で定義、アプリケーションレベルは `anyhow`
- エラーチェーンでコンテキストを付与: `.context("failed to ...")`

## Design

- trait は小さく保つ（1-3メソッド）
- `impl Trait` を引数に使い、具象型への依存を避ける
- `derive` マクロを活用: `Debug`, `Clone`, `PartialEq`
- `Default` trait を実装してビルダーパターンの代替にする

## Safety

- `unsafe` は最小限に。使用時はSAFETYコメントで安全性の根拠を記述
- FFI 境界では必ず入力をバリデーション

## Performance

- `String` より `&str`、`Vec<T>` より `&[T]` を引数に
- `collect()` の型は明示する
- イテレータを活用し、不要なアロケーションを避ける

## Tooling

- `cargo fmt` — フォーマット
- `cargo clippy` — lint（警告はすべて対処）
- `cargo test` — テスト実行
