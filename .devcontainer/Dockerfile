# 軽量なDebian基盤イメージを使用
FROM mcr.microsoft.com/vscode/devcontainers/rust:1-bullseye

# 必要なパッケージのインストール
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        # PostgreSQL クライアント
        postgresql-client \
        # 開発ツール
        git \
        curl \
        wget \
        unzip \
        build-essential \
        pkg-config \
        libssl-dev \
        # デバッグ用
        gdb \
        # 追加のLinuxツール
        htop \
        tree \
        jq \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Rustツールチェーンのアップデートと必要なコンポーネント追加
RUN rustup update \
    && rustup component add clippy rustfmt rust-analyzer \
    && rustup target add wasm32-unknown-unknown

# よく使用されるRustツールのインストール（エラー時のビルド継続とキャッシュ効率化）
RUN set -e; \
    # 必須ツール（エラー時は停止）
    cargo install cargo-watch; \
    cargo install sqlx-cli; \
    cargo install diesel_cli --no-default-features --features postgres; \
    \
    # オプションツール（エラー時も継続）
    cargo install cargo-generate || echo "cargo-generate installation failed, continuing..."; \
    cargo install cargo-expand || echo "cargo-expand installation failed, continuing..."; \
    cargo install cargo-audit || echo "cargo-audit installation failed, continuing..."; \
    cargo install cargo-edit || echo "cargo-edit installation failed, continuing..."; \
    cargo install cargo-tarpaulin || echo "cargo-tarpaulin installation failed, continuing..."; \
    cargo install cargo-criterion || echo "cargo-criterion installation failed, continuing..."

# Node.js（フロントエンド開発やツール用）
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# ワークスペース用のディレクトリ作成
RUN mkdir -p /workspaces

# 非rootユーザーでの実行
USER vscode

# Cargoのキャッシュ設定
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH

# 環境変数設定
ENV RUST_LOG=debug
ENV RUST_BACKTRACE=1