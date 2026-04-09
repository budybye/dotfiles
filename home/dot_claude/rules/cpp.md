# C++

## Core Guidelines

- C++ Core Guidelines に準拠
- モダン C++ (C++17 以上) の機能を活用

## Memory Management (RAII)

- リソース管理は RAII パターンで行う
- `std::unique_ptr` — 単一所有権
- `std::shared_ptr` — 共有所有権（必要な場合のみ）
- 生ポインタの `new` / `delete` は使わない
- `std::make_unique` / `std::make_shared` でスマートポインタを生成

## Safety

- `const` を積極的に使う（変数、引数、メンバ関数）
- 範囲 for ループを使う（添字アクセスより安全）
- `static_cast` を使う（C スタイルキャスト禁止）
- `nullptr` を使う（`NULL` / `0` ではなく）
- バッファオーバーフローに注意: `std::string`, `std::vector`, `std::array` を使用

## Error Handling

- 例外 vs エラーコード: プロジェクトの方針に従う
- `noexcept` を適切にマーク
- `std::optional` で値の不在を表現
- `std::expected` (C++23) または Result 型パターン

## Design

- ヘッダとソースの分離
- 前方宣言でコンパイル依存を減らす
- 仮想デストラクタを持つ基底クラスには `virtual ~Base() = default`
- Rule of Five / Rule of Zero

## Tooling

- `clang-format` — フォーマット
- `clang-tidy` — 静的解析
- `sanitizers` (ASan, UBSan, TSan) — ランタイム検出
- `CMake` — ビルドシステム
