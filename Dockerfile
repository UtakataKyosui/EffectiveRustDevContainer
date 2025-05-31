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
        # Permission関連ツール
        sudo \
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

# ワークスペース用のディレクトリ作成とPermission設定
RUN mkdir -p /workspaces \
    && chown -R vscode:vscode /workspaces \
    && chmod -R 755 /workspaces

# Cargoディレクトリの作成とPermission設定
RUN mkdir -p /usr/local/cargo \
    && chown -R vscode:vscode /usr/local/cargo \
    && chmod -R 755 /usr/local/cargo

# Rustのtargetディレクトリとレジストリキャッシュ用のディレクトリ作成
RUN mkdir -p /home/vscode/.cargo/registry \
    && mkdir -p /home/vscode/.cargo/git \
    && chown -R vscode:vscode /home/vscode/.cargo \
    && chmod -R 755 /home/vscode/.cargo

# vscodeユーザーをsudoグループに追加（パスワードなしsudo有効化）
RUN usermod -aG sudo vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 非rootユーザーでの実行
USER vscode

# Cargoのキャッシュ設定
ENV CARGO_HOME=/home/vscode/.cargo
ENV PATH=/home/vscode/.cargo/bin:/usr/local/cargo/bin:$PATH

# Cargo設定ファイルの作成（Permission最適化）
RUN mkdir -p /home/vscode/.cargo \
    && echo '[build]' > /home/vscode/.cargo/config.toml \
    && echo 'target-dir = "/workspaces/target"' >> /home/vscode/.cargo/config.toml \
    && echo '[registries.crates-io]' >> /home/vscode/.cargo/config.toml \
    && echo 'protocol = "sparse"' >> /home/vscode/.cargo/config.toml

# 環境変数設定
ENV RUST_LOG=debug
ENV RUST_BACKTRACE=1
ENV USER=vscode
ENV HOME=/home/vscode

# umask設定（新しく作成されるファイル・ディレクトリのデフォルトPermission）
RUN echo "umask 022" >> /home/vscode/.bashrc