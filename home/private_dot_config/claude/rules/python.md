# Python

## Style

- PEP 8 準拠
- すべての関数シグネチャに型アノテーションを付ける
- `from __future__ import annotations` で新しい型構文を使用

## Data Structures

- `@dataclass(frozen=True)` で不変なデータクラス
- `NamedTuple` で不変なタプル型
- `dict` より `TypedDict` で構造化データを型付け

## Error Handling

- 具体的な例外をキャッチ（`except Exception` は避ける）
- カスタム例外は `Exception` を継承して定義
- コンテキストマネージャ (`with`) でリソースを管理

## Testing

- `pytest` を使用
- フィクスチャでテストデータを準備
- `parametrize` でテストケースを網羅
- `monkeypatch` / `unittest.mock` でモック

## Virtual Environment

- プロジェクトごとに仮想環境を使用
- 依存関係は `pyproject.toml` で管理
- `uv` または `pip` でインストール

## Tooling

- `ruff` — lint + format (black, isort の代替)
- `mypy` / `pyright` — 型チェック

## Anti-Patterns

- グローバル変数の可変状態
- `import *`
- 型チェックなしの `# type: ignore`
