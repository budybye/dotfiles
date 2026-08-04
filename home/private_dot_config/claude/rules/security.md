# Security

## Pre-Commit Checklist

- [ ] ハードコードされたシークレットがないか (API keys, passwords, tokens)
- [ ] ユーザー入力がすべてバリデーションされているか
- [ ] SQLインジェクション対策 (パラメータ化クエリ)
- [ ] XSS対策 (出力エスケープ)
- [ ] CSRF対策 (トークン検証)
- [ ] 認証・認可が適切に実装されているか
- [ ] エラーメッセージが内部情報を漏洩しないか
- [ ] レート制限が実装されているか

## Secret Management

- シークレットはソースコードにハードコードしない
- 環境変数またはシークレットマネージャ (Bitwarden + age) を使用
- 起動時にシークレットの存在を検証する
- 漏洩の疑いがあれば即座にローテーションする

## OWASP Top 10 意識

1. Broken Access Control — 最小権限原則
2. Cryptographic Failures — 適切な暗号化アルゴリズム
3. Injection — 入力のサニタイズ
4. Insecure Design — 脅威モデリング
5. Security Misconfiguration — デフォルト設定の確認

## Incident Response

1. 作業を即座に中断
2. security-analist エージェントにエスカレーション
3. クリティカルな問題を修正してから再開
4. クレデンシャルをローテーション
5. 同種の脆弱性がないかコードベース全体を監査
