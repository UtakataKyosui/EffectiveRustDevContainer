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

# /usr/local/rustupとCargoディレクトリの権限設定
RUN chown -R vscode:vscode /usr/local/rustup \
	&& chown -R vscode:vscode /usr/local/cargo \
	&& chmod -R 755 /usr/local/rustup \
	&& chmod -R 755 /usr/local/cargo

# vscodeユーザーのCargoディレクトリ設定
RUN mkdir -p /home/vscode/.cargo/registry \
	&& mkdir -p /home/vscode/.cargo/git \
	&& mkdir -p /home/vscode/.cargo/bin \
	&& chown -R vscode:vscode /home/vscode/.cargo \
	&& chmod -R 755 /home/vscode/.cargo

# vscodeユーザーをsudoグループに追加（パスワードなしsudo有効化）
RUN usermod -aG sudo vscode \
	&& echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# vscodeユーザーに切り替えてRust環境を設定
USER vscode

# Rustツールチェーンの設定
RUN rustup update \
	&& rustup component add clippy rustfmt rust-analyzer \
	&& rustup target add wasm32-unknown-unknown

# よく使用されるRustツールのインストール
RUN set -e; \
	# レジストリキャッシュを事前にクリア
	rm -rf /usr/local/cargo/registry || true; \
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
	cargo install cargo-criterion || echo "cargo-criterion installation failed, continuing..."; \
	\
	# インストール後に権限を再設定
	sudo chown -R vscode:vscode /usr/local/cargo || true

# rootに戻ってNode.jsのインストール
USER root

# Node.js（フロントエンド開発やツール用）
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
	&& apt-get install -y nodejs

# ワークスペース用のディレクトリ作成とPermission設定
RUN mkdir -p /workspaces \
	&& chown -R vscode:vscode /workspaces \
	&& chmod -R 755 /workspaces \
	&& mkdir -p /workspaces/target \
	&& chown -R vscode:vscode /workspaces/target \
	&& chmod -R 755 /workspaces/target

# 再度権限設定を確実にする（レジストリキャッシュも含めて）
RUN sudo chown -R vscode:vscode /usr/local/rustup \
	&& sudo chown -R vscode:vscode /usr/local/cargo \
	&& sudo chmod -R 755 /usr/local/rustup \
	&& sudo chmod -R 755 /usr/local/cargo

# 環境変数設定（重複削除）
ENV RUST_LOG=debug
ENV RUST_BACKTRACE=1
ENV USER=vscode
ENV HOME=/home/vscode

# Cargo設定ファイルの作成
RUN mkdir -p /usr/local/cargo \
	&& echo '[build]' > /usr/local/cargo/config.toml \
	&& echo 'target-dir = "/workspaces/target"' >> /usr/local/cargo/config.toml \
	&& echo '[registries.crates-io]' >> /usr/local/cargo/config.toml \
	&& echo 'protocol = "sparse"' >> /usr/local/cargo/config.toml

# .bashrcに環境設定を追加
RUN echo "umask 022" >> /home/vscode/.bashrc \
	&& echo 'export CARGO_HOME=/usr/local/cargo' >> /home/vscode/.bashrc \
	&& echo 'export RUSTUP_HOME=/usr/local/rustup' >> /home/vscode/.bashrc \
	&& echo 'export PATH=/usr/local/cargo/bin:/usr/local/rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin:$PATH' >> /home/vscode/.bashrc

# ワークディレクトリを設定
WORKDIR /workspaces
