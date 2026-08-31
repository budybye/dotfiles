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
    lsd \
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
    python3 \
    ruby \
    flatpak

# devユーザー設定
ARG DEV=dev
ARG DEV_PW=dev

RUN groupadd -g 1024 -f $DEV && \
    useradd --uid 1024 --gid 1024 -m $DEV -G sudo -s /usr/bin/zsh && \
    echo "$DEV:$DEV_PW" | chpasswd && \
    echo "$DEV ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/$DEV && \
    chown -R $DEV:$DEV /home/$DEV

# ubuntuユーザー設定
RUN usermod -aG sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu

# ENTRYPOINT を/usr/bin/にコピーしてシンボリックリンクを作成
COPY ./entrypoint.sh /usr/bin/
RUN ln -s /usr/bin/entrypoint.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint

# GitHub の dotfiles repository を Chezmoi source にする
RUN git clone https://github.com/budybye/dotfiles.git /home/ubuntu/dotfiles
WORKDIR /home/ubuntu/dotfiles
USER ubuntu
RUN make init

# 不要なパッケージ キャッシュを削除（make init 内の apt-get の後）
RUN sudo apt-get autoremove -y && \
    sudo apt-get clean && \
    sudo rm -rf /var/cache/apt /var/lib/apt/lists/*

# マルチステージビルド
FROM base
EXPOSE 3389
ENTRYPOINT ["entrypoint"]
CMD ["ubuntu", "ubuntu", "yes"]
# $1 ユーザー名
# $2 パスワード
# $3 sudo-no-passwd yes or other
