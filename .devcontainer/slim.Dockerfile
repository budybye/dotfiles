FROM ubuntu:26.04 AS base

# パッケージのインストールを非対話形式で行う
ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKER=true
ENV REMOTE_CONTAINERS=true

ENV TZ=Asia/Tokyo
ENV LANG=ja_JP.UTF-8
ENV LC_ALL=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja

# 日本語環境を設定
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    language-pack-ja \
    language-pack-ja-base \
    manpages-ja \
    tzdata \
    locales && \
    rm -rf /var/lib/apt/lists/*

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    locale-gen ja_JP.UTF-8 && \
    echo LANGUAGE=${LANGUAGE} >> /etc/default/locale && \
    echo LANG=${LANG} >> /etc/default/locale && \
    echo LC_ALL=${LC_ALL} >> /etc/default/locale

# CLI パッケージをインストール
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    zsh \
    make \
    curl \
    git \
    gh \
    gzip \
    age \
    gnupg \
    sudo \
    wget \
    vim \
    tree \
    ncdu \
    gawk \
    byobu \
    openssh-server \
    ca-certificates \
    apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# 開発用パッケージをインストール
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    g++ \
    cmake \
    build-essential \
    libssl-dev \
    pkg-config \
    software-properties-common \
    python3 \
    rustup \
    ruby && \
    rm -rf /var/lib/apt/lists/*
    
# ENTRYPOINT を/usr/bin/にコピーしてシンボリックリンクを作成
COPY ./run.sh /usr/bin/
RUN ln -s /usr/bin/run.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint

# devユーザー設定
ARG DEV=dev
ARG DEV_UID=1024
ARG DEV_GID=1024

RUN groupadd -f -g "${DEV_GID}" "${DEV}" && \
    useradd \
      --uid "${DEV_UID}" \
      --gid "${DEV_GID}" \
      --create-home \
      --shell /usr/bin/zsh \
      "${DEV}" && \
    echo "${DEV} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ubuntuユーザー設定
RUN usermod -aG sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu

# ubuntu user で dotfiles を適用
USER ubuntu
WORKDIR /home/ubuntu
ARG DOTFILES_REF=main
RUN git clone --depth=1 --branch "${DOTFILES_REF}" https://github.com/budybye/dotfiles.git
RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN \
    cd dotfiles && make init

USER root
# build 後の apt cache を削除
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*

# マルチステージビルド
FROM base
EXPOSE 22
ENTRYPOINT ["entrypoint"]
CMD ["ubuntu", "ubuntu", "no"]
# $1 ユーザー名
# $2 パスワード
# $3 sudo-no-passwd yes or other
