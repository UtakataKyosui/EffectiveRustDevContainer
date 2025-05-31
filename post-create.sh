#!/bin/bash

# DevContainer起動後に実行されるスクリプト

echo "🚀 DevContainer環境をセットアップ中..."

# 実行権限を設定
chmod +x "$0"

# 不足している可能性のあるRustツールを確認・インストール
echo "🔧 Rustツールの確認・補完インストール中..."
MISSING_TOOLS=""

# 必要なツールの確認
if ! command -v cargo-watch &> /dev/null; then
    echo "📦 cargo-watch をインストール中..."
    cargo install cargo-watch || echo "⚠️ cargo-watch のインストールに失敗"
fi

if ! command -v cargo-generate &> /dev/null; then
    echo "📦 cargo-generate をインストール中..."
    cargo install cargo-generate || echo "⚠️ cargo-generate のインストールに失敗"
    MISSING_TOOLS="$MISSING_TOOLS cargo-generate"
fi

if ! command -v cargo-edit &> /dev/null; then
    echo "📦 cargo-edit をインストール中..."
    cargo install cargo-edit || echo "⚠️ cargo-edit のインストールに失敗"
    MISSING_TOOLS="$MISSING_TOOLS cargo-edit"
fi

if [ -n "$MISSING_TOOLS" ]; then
    echo "⚠️ 一部のツールのインストールに失敗しました:$MISSING_TOOLS"
    echo "💡 後で手動インストールできます: cargo install <tool-name>"
fi

# データベース接続テスト（PostgreSQLが起動するまで待機）
echo "📊 PostgreSQL接続テスト中..."
for i in {1..30}; do
    if pg_isready -h postgres -p 5432 -U postgres; then
        echo "✅ PostgreSQLに接続成功"
        break
    fi
    echo "⏳ PostgreSQLの起動を待機中... ($i/30)"
    sleep 2
done

# データベースの初期化
if [ -f "migrations" ] || [ -f "diesel.toml" ]; then
    echo "🔧 Dieselマイグレーションを実行中..."
    diesel migration run || echo "⚠️ マイグレーション実行に失敗または該当なし"
fi

if [ -f "sqlx-data.json" ] || ls migrations/*.sql 1> /dev/null 2>&1; then
    echo "🔧 SQLxマイグレーションを実行中..."
    sqlx migrate run || echo "⚠️ SQLxマイグレーション実行に失敗または該当なし"
fi

# Rustプロジェクトの依存関係をプリビルド
if [ -f "Cargo.toml" ]; then
    echo "📦 Rust依存関係をプリビルド中..."
    cargo fetch
    # 依存関係の事前コンパイル（初回ビルド時間短縮）
    cargo build --release || echo "⚠️ プリビルドに失敗"
fi

# Git設定（必要に応じて）
if [ ! -f ~/.gitconfig ]; then
    echo "🔧 Git設定を初期化中..."
    git config --global init.defaultBranch main
    git config --global core.autocrlf input
    git config --global pull.rebase false
fi

# 開発用エイリアスの設定
echo "🔧 便利なエイリアスを設定中..."
cat >> ~/.bashrc << 'EOF'

# Rust開発用エイリアス
alias cb='cargo build'
alias cr='cargo run'
alias ct='cargo test'
alias cc='cargo check'
alias cf='cargo fmt'
alias ccl='cargo clippy'
alias cw='cargo watch -x run'
alias cwr='cargo watch -x "run --release"'
alias cwt='cargo watch -x test'

# データベース用エイリアス
alias db='psql $DATABASE_URL'
alias dbmigrate='sqlx migrate run'
alias dbreset='sqlx database reset -f'

# Git用エイリアス（日本語対応）
alias gst='git status'
alias gco='git checkout'
alias gcm='git commit -m'
alias gps='git push'
alias gpl='git pull'
alias glog='git log --oneline --graph --decorate'

EOF

# Zsh設定（インストール済みの場合）
if [ -f ~/.zshrc ]; then
    cat >> ~/.zshrc << 'EOF'

# Rust開発用エイリアス
alias cb='cargo build'
alias cr='cargo run'
alias ct='cargo test'
alias cc='cargo check'
alias cf='cargo fmt'
alias ccl='cargo clippy'
alias cw='cargo watch -x run'
alias cwr='cargo watch -x "run --release"'
alias cwt='cargo watch -x test'

# データベース用エイリアス
alias db='psql $DATABASE_URL'
alias dbmigrate='sqlx migrate run'
alias dbreset='sqlx database reset -f'

# Git用エイリアス
alias gst='git status'
alias gco='git checkout'
alias gcm='git commit -m'
alias gps='git push'
alias gpl='git pull'
alias glog='git log --oneline --graph --decorate'

EOF
fi

# プロジェクト固有の初期化
if [ -f "scripts/setup.sh" ]; then
    echo "🔧 プロジェクト固有のセットアップを実行中..."
    chmod +x scripts/setup.sh
    ./scripts/setup.sh
fi

echo "✅ DevContainer環境のセットアップが完了しました！"
echo ""
echo "🎉 利用可能なコマンド："
echo "  - cb: cargo build"
echo "  - cr: cargo run"
echo "  - ct: cargo test"
echo "  - cw: cargo watch -x run"
echo "  - db: PostgreSQL接続"
echo ""
echo "🔧 開発ツール："
echo "  - Rust Analyzer（コード補完・エラー検出）"
echo "  - GitLens（Git統合）"
echo "  - Conventional Commits（コミットメッセージ支援）"
echo "  - PostgreSQL Explorer（データベース管理）"
echo ""
echo "🚀 開発開始準備完了！"