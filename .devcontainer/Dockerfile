FROM ubuntu:26.04 AS base

# パッケージのインストールを非対話形式で行う
ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKER=true

ENV TZ=Asia/Tokyo
ENV LANG=ja_JP.UTF-8
ENV LC_ALL=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja

RUN apt-get update -y && \
    apt-get install -y --fix-broken

# 日本語環境を設定
RUN apt-get install -y \
    language-pack-ja \
    language-pack-ja-base \
    manpages-ja \
    tzdata \
    fcitx5-mozc \
    locales

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    locale-gen ja_JP.UTF-8 && \
    echo LANGUAGE=${LANGUAGE} >> /etc/default/locale && \
    echo LANG=${LANG} >> /etc/default/locale && \
    echo LC_ALL=${LC_ALL} >> /etc/default/locale

RUN apt-get install -y \
    xfce4 \
    xfce4-clipman-plugin \
    xfce4-cpugraph-plugin \
    xfce4-netload-plugin \
    xfce4-screenshooter \
    xfce4-taskmanager \
    xfce4-terminal \
    xfce4-xkb-plugin

RUN apt-get install -y \
    dbus-x11 \
    xorgxrdp \
    xrdp && \
    apt remove -y light-locker xscreensaver

# 必須パッケージをインストール
RUN apt-get install -y \
    zsh \
    make \
    curl \
    sudo \
    wget \
    git \
    gh \
    gzip \
    age \
    gnupg \
    wget \
    xsel \
    xdotool \
    vim \
    tree \
    jq \
    ncdu \
    pwgen \
    gawk \
    mpd \
    mpc \
    ncmpcpp \
    mkcert \
    ufw \
    byobu \
    openssh-server \
    avahi-daemon

# 開発用パッケージをインストール 言語のビルドに必要なパッケージ
RUN apt-get install -y \
    g++ \
    cmake \
    build-essential \
    libssl-dev \
    pkg-config \
    libfreetype6-dev \
    libfontconfig1-dev \
    libxcb-xfixes0-dev \
    libxkbcommon-dev \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    command-not-found \
    rustup \
    python3 \
    ruby \
    flatpak

# ENTRYPOINT を/usr/bin/にコピーしてシンボリックリンクを作成
COPY ./entrypoint.sh /usr/bin/
RUN ln -s /usr/bin/entrypoint.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint

# ubuntuユーザー設定
RUN usermod -aG sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu

USER ubuntu
WORKDIR /home/ubuntu
# GitHub の dotfiles repository を Chezmoi source にする
ARG DOTFILES_REF=main
RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN \
    if [ -n "${GITHUB_TOKEN:-}" ]; then \
        git -c http.extraheader="AUTHORIZATION: bearer ${GITHUB_TOKEN}" \
            clone --depth=1 --branch "${DOTFILES_REF}" https://github.com/budybye/dotfiles.git; \
    else \
        git clone --depth=1 --branch "${DOTFILES_REF}" https://github.com/budybye/dotfiles.git; \
    fi
# mise rate limit 回避に GITHUB_TOKEN 設定
RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN \
    export MISE_GITHUB_TOKEN="${GITHUB_TOKEN:-}" && \
    cd dotfiles && make init

USER root
# Docker は systemd-cat を使う im-config を実行しない
RUN apt-get purge -y im-config
# build 後の apt cache を削除
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*

# マルチステージビルド
FROM base
EXPOSE 3389
ENTRYPOINT ["entrypoint"]
CMD ["ubuntu", "ubuntu", "yes"]
# $1 ユーザー名
# $2 パスワード
# $3 sudo-no-passwd yes or other
