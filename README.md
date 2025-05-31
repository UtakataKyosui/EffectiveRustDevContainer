# Rust DevContainer 開発環境

このDevContainer環境は、Rust開発を効率的に行うために最適化された開発環境です。PostgreSQLデータベース、豊富な拡張機能、そして生産性向上ツールを含んでいます。

## 🚀 特徴

### 開発ツール
- **Rust Analyzer**: 高度なコード補完、エラー検出、リファクタリング
- **LLDB Debugger**: ステップデバッグ、ブレークポイント
- **Clippy**: Rustの高品質なリンター
- **rustfmt**: 自動コードフォーマット

### Git & コミット支援
- **GitLens**: 高度なGit統合
- **Conventional Commits**: 規約に従ったコミットメッセージの作成支援
- **Git Commit Plugin**: コミットメッセージテンプレート
- **Git Graph**: 視覚的なGitブランチ管理

### データベース
- **PostgreSQL 15**: 本格的なリレーショナルデータベース
- **SQLTools**: データベース管理とクエリ実行
- **PostgreSQL Explorer**: GUI でのデータベース探索

### パフォーマンス最適化
- **Cargoキャッシュ**: 依存関係のビルド時間短縮
- **ターゲットキャッシュ**: コンパイル結果の永続化
- **マルチステージビルド**: コンテナサイズの最適化

## 📋 前提条件

- Docker Desktop
- Visual Studio Code
- Dev Containers 拡張機能

## 🛠️ セットアップ手順

1. **リポジトリのクローン**
   ```bash
   git clone <your-repository>
   cd <your-project>
   ```

2. **DevContainerファイルの配置**
   プロジェクトルートに以下のファイル構造を作成：
   ```
   .devcontainer/
   ├── devcontainer.json
   ├── Dockerfile
   └── post-create.sh
   docker-compose.yml
   ```

3. **VS Codeでの起動**
   - VS Codeでプロジェクトフォルダを開く
   - `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"
   - または通知の「Reopen in Container」をクリック

4. **自動セットアップ**
   初回起動時に以下が自動実行されます：
   - PostgreSQLの起動と接続テスト
   - Rust依存関係のプリビルド
   - データベースマイグレーション（該当ファイルが存在する場合）
   - 便利なエイリアスの設定

## 🎯 利用可能なコマンド（エイリアス）

### Rust開発
```bash
cb          # cargo build
cr          # cargo run  
ct          # cargo test
cc          # cargo check
cf          # cargo fmt
ccl         # cargo clippy
cw          # cargo watch -x run
cwr         # cargo watch -x "run --release"
cwt         # cargo watch -x test
```

### データベース操作
```bash
db          # psql $DATABASE_URL
dbmigrate   # sqlx migrate run
dbreset     # sqlx database reset -f
```

### Git操作
```bash
gst         # git status
gco         # git checkout
gcm         # git commit -m
gps         # git push
gpl         # git pull
glog        # git log --oneline --graph --decorate
```

## 🔧 インストール済みツール

### Rustツールチェーン
- `cargo-watch`: ファイル変更の監視と自動実行
- `cargo-generate`: プロジェクトテンプレート
- `cargo-expand`: マクロ展開の確認
- `cargo-audit`: セキュリティ監査
- `cargo-edit`: 依存関係の管理
- `cargo-tarpaulin`: テストカバレッジ
- `sqlx-cli`: SQLxコマンドラインツール
- `diesel_cli`: Dieselマイグレーションツール

### 開発支援
- PostgreSQL クライアント
- Node.js 18 (フロントエンド開発用)
- Git, curl, wget, jq など基本ツール

## 🌐 ポート設定

- **3000**: Web アプリケーション
- **8000**: API サーバー  
- **8080**: 開発サーバー
- **5432**: PostgreSQL

## 🗄️ データベース設定

### 接続情報
- **Host**: postgres
- **Port**: 5432
- **Database**: rust_app
- **Username**: postgres
- **Password**: postgres
- **接続文字列**: `postgres://postgres:postgres@postgres:5432/rust_app`

### マイグレーション
SQLxまたはDieselのマイグレーションファイルが存在する場合、コンテナ起動時に自動実行されます。

## 📊 VS Code拡張機能

### コア開発
- Rust Analyzer
- LLDB Debugger
- Crates (依存関係管理)

### Git支援
- GitLens
- Git Graph
- Conventional Commits
- Git Commit Plugin

### データベース
- PostgreSQL
- SQLTools

### 生産性向上
- TODO Highlight
- TODO Tree
- Path Intellisense
- Auto Rename Tag
- REST Client

## 🎨 カスタマイズ

### 追加の拡張機能
`.devcontainer/devcontainer.json`の`extensions`配列に追加：

```json
"extensions": [
  "your-extension-id"
]
```

### 環境変数の追加
`containerEnv`セクションに追加：

```json
"containerEnv": {
  "YOUR_ENV_VAR": "value"
}
```

### 起動時スクリプトの追加
`.devcontainer/post-create.sh`を編集して、カスタムセットアップを追加できます。

## 🚨 トラブルシューティング

### PostgreSQL接続エラー
```bash
# コンテナの状態確認
docker-compose ps

# PostgreSQLログの確認
docker-compose logs postgres

# 手動接続テスト
pg_isready -h postgres -p 5432 -U postgres
```

### ビルドキャッシュのクリア
```bash
# Dockerイメージの再ビルド
docker-compose build --no-cache

# Cargoキャッシュのクリア
cargo clean
```

### 権限エラー
```bash
# post-create.shに実行権限付与
chmod +x .devcontainer/post-create.sh
```

## 📝 プロジェクト構造例

```
your-rust-project/
├── .devcontainer/
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── post-create.sh
├── docker-compose.yml
├── src/
│   └── main.rs
├── migrations/
│   └── *.sql
├── Cargo.toml
└── README.md
```

## 🤝 貢献

この開発環境の改善提案やバグ報告は、イシューまたはプルリクエストでお知らせください。

## 📄 ライセンス

MIT License

---

**Happy Coding! 🦀✨**