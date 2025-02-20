FROM ubuntu:24.04 AS base

# パッケージのインストールを非対話形式で行う
ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKER=true

ENV TZ=Asia/Tokyo
ENV LANG=ja_JP.UTF-8
ENV LC_ALL=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja

RUN apt-get -y update
RUN apt-get -y upgrade

# 日本語環境を設定
RUN apt-get install -y \
    language-pack-ja \
    language-pack-ja-base \
    manpages-ja \
    tzdata \
    fcitx5-mozc \
    im-config \
    locales

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    locale-gen ja_JP.UTF-8 && \
    echo LANGUAGE=${LANGUAGE} >> /etc/default/locale && \
    echo LANG=${LANG} >> /etc/default/locale && \
    echo LC_ALL=${LC_ALL} >> /etc/default/locale && \
    im-config -n fcitx5

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
    dbus-x11

RUN apt-get install -y \
    sudo \
    wget \
    xorgxrdp \
    xrdp && \
    apt remove -y light-locker xscreensaver

# 必須パッケージをインストール
RUN apt-get install -y \
    zsh \
    make \
    curl \
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
    ffmpeg \
    mpd \
    mpc \
    ncmpcpp \
    neofetch \
    mkcert \
    ufw \
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
    python3 \
    ruby \
    flatpak

RUN apt-get install -y \
    fortune-mod \
    figlet \
    cmatrix \
    command-not-found \
    oneko \
    cowsay \
    lolcat \
    nyancat \
    translate-shell

# 不要なパッケージ キャッシュを削除
RUN apt-get autoremove -y
RUN apt-get clean
RUN rm -rf /var/cache/apt /var/lib/apt/lists/*

# devユーザー設定
ARG DEV=dev

RUN groupadd -g 1024 -f $DEV && \
    useradd --uid 1024 --gid 1024 -m $DEV -G sudo -s /usr/bin/zsh && \
    echo "$DEV:$DEV" | chpasswd && \
    echo "$DEV ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/$DEV && \
    chown -R $DEV:$DEV /home/$DEV

# RUN git clone https://github.com/budybye/dotfiles.git /home/dev/dotfiles
# USER ${USER_NAME}
# ユーザーを切り替え dotfiles ディレクトリに移動
# WORKDIR /home/${USER_NAME}/dotfiles
# ホームディレクトリに dotfiles をクローンしてインストール
# RUN make init

# ubuntuユーザー設定
RUN usermod -aG sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu

# エントリーポイント　を用意
COPY ./entrypoint.sh /usr/bin/
RUN ln -s /usr/bin/entrypoint.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint

# ホームディレクトリに dotfiles をクローン
RUN git clone https://github.com/budybye/dotfiles.git /home/ubuntu/dotfiles
USER ubuntu
WORKDIR /home/ubuntu/dotfiles
RUN make init

FROM base
# USER root

EXPOSE 3389
# エントリーポイントを実行
ENTRYPOINT ["entrypoint"]
# デフォルト引数 ユーザー名、パスワード、sudo-no-passwd yes or other
CMD ["ubuntu", "ubuntu", "yes"]
