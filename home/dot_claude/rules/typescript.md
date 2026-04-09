# TypeScript / JavaScript

## Types

- 公開API（export関数、publicメソッド）には明示的な型注釈を付ける
- ローカル変数は型推論に任せる
- `interface` — 拡張可能なオブジェクト型に使用
- `type` — union, intersection, utility types に使用
- `enum` より string literal union を優先
- **`any` 禁止** — `unknown` で受けて narrowing する。型依存の値は generics を使う

## React

- props は named interface/type で定義
- callback props は明示的に型付け
- `React.FC` は使わない

## Immutability

- spread operator で更新（直接変更しない）
- `Readonly<T>` でパラメータの不変性を強制
- `const` を基本とし、再代入が必要な場合のみ `let`

## Validation

- Zod でスキーマベースのバリデーション
- `z.infer<typeof schema>` で型を導出

## Error Handling

- async/await + try-catch
- `unknown` 型のエラーは `instanceof` で narrowing してからアクセス

## Quality

- `console.log` は本番コードで使わない（専用ロガーを使用）
- ESM (import/export) を使用
- `.js`/`.jsx` では JSDoc で型情報を補完
