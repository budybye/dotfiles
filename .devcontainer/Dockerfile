FROM ubuntu:24.04

# パッケージのインストールを非対話形式で行う
ENV DEBIAN_FRONTEND=noninteractive
# dockerコンテナ内で実行されていることを示す
ENV DOCKER=true

# パッケージを更新
RUN apt-get -y update
RUN apt-get -y upgrade

# タイムゾーンを設定
# ロケールを設定
# fcitx5を設定
# 日本語入力を設定
RUN apt-get install -y \
    language-pack-ja \
    language-pack-ja-base \
    manpages-ja \
    tzdata \
    fcitx5-mozc \
    im-config \
    locales

ENV TZ=Asia/Tokyo
ENV LANG=ja_JP.UTF-8
ENV LC_ALL=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    locale-gen ja_JP.UTF-8 && \
    echo LANGUAGE=${LANGUAGE} >> /etc/default/locale && \
    echo LANG=${LANG} >> /etc/default/locale && \
    echo LC_ALL=${LC_ALL} >> /etc/default/locale && \
    im-config -n fcitx5

# xfce4をインストール
RUN apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xfce4-session \
    xfce4-clipman-plugin

# xrdpをインストール
RUN apt-get install -y \
    xrdp \
    xorgxrdp \
    tigervnc-standalone-server \
    dbus-x11
# xrdp用の不要なパッケージを削除
RUN apt-get remove -y light-locker xscreensaver

# 必須パッケージをインストール
RUN apt-get install -y \
    init \
    systemd \
    sudo \
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

# 不要なパッケージ キャッシュを削除
RUN apt-get autoremove -y
RUN apt-get clean
RUN rm -rf /var/cache/apt /var/lib/apt/lists/*

# xrdp用の設定
RUN mkdir -p /var/run/dbus && \
    cp /etc/X11/xrdp/xorg.conf /etc/X11 && \
    sed -i "s/console/anybody/g" /etc/X11/Xwrapper.config && \
    sed -i "s/xrdp\/xorg/xorg/g" /etc/xrdp/sesman.ini && \
    echo "xfce4-session" >> /etc/skel/.Xsession

# ユーザーを作成 デフォルトはubuntu
# ARG USER=budybye
# ARG UID=1010
# ARG GID=$UID
ARG USER=ubuntu
ARG HOME=/home/$USER

# デフォルトのシェルをzshに変更
# パスワードはubuntu
# sudoのパスワードはなし
# ホームディレクトリを作成
RUN chsh -s /usr/bin/zsh && \
    echo "$USER:$USER" | chpasswd && \
    echo "ALL ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p $HOME && \
    chown -R $USER:$USER $HOME

# devcontainer用ユーザーを作成
ARG DEV=dev
ARG DEV_UID=1234
ARG DEV_GID=$DEV_UID
ARG DEV_HOME=/home/$DEV

RUN groupadd -g $DEV_GID -f $DEV && \
    useradd --uid $DEV_UID --gid $DEV_GID -m $DEV -G sudo -s /usr/bin/zsh && \
    echo "$DEV:$DEV" | chpasswd && \
    mkdir -p $DEV_HOME && \
    chown -R $DEV:$DEV $DEV_HOME

# デフォルトユーザーとホームをワークディレクトリに設定
# ここからsudoを使えるようになる
USER $USER
WORKDIR $HOME

# chezmoiをインストール
RUN sudo sh -c "$(curl -fsSL get.chezmoi.io)" -- -b /usr/local/bin
# dotfilesをクローン
RUN git clone https://github.com/budybye/dotfiles.git ${HOME}/dotfiles

# miseをインストール
# miseでnodeをインストール
# npmでbwをインストール
# パスを環境変数に追加
RUN curl https://mise.run | sh && \
    export PATH=${HOME}/.local/bin:${PATH} && \
    mise use -g node@20.18.1 && \
    export PATH=${HOME}/.local/share/mise/shims:${PATH} && \
    export PATH=${HOME}/.local/share/mise/installs/node/20.18.1/bin:${PATH} && \
    npm i -g @bitwarden/cli && \
    bw --version || echo "bw command not found" && \
    echo "export PATH=${PATH}" >> ${HOME}/.zshenv

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . ${HOME}/.cargo/env && \
    cargo install cargo-binstall@1.6.9 && \
    cargo binstall -y starship sheldon fd-find xh bat && \
    echo 'export PATH=${HOME}/.cargo/bin:${PATH}' >> ${HOME}/.zshenv

# Xrdp用のグループを作成 xsessionをxfce4-sessionに設定
RUN groupadd -f xrdp && \
    groupadd -f ssl-cert && \
    groupadd -f input && \
    groupadd -f audio && \
    sudo usermod -aG input,xrdp,audio,ssl-cert $USER && \
    echo "xfce4-session" > ~/.xsession && \
    echo "dbus-launch --exit-with-session /usr/bin/xfce4-session" > ~/.startwm.sh && \
    chmod 755 ~/.startwm.sh && \
    sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session

# xrdpのポートを公開
EXPOSE 3389
EXPOSE 22

# コンテナ起動時に実行するスクリプトを設定 /sbin/initを実行してる
COPY ./entrypoint.sh /usr/local/bin/entrypoint
RUN sudo chmod +x /usr/local/bin/entrypoint
ENTRYPOINT ["entrypoint"]
# エントリーポイントの最後に渡す引数コマンド
# CMD ["/sbin/init"]
CMD ["/usr/bin/zsh", "--login"]
# /usr/bin/zsh を実行してるのでコンテナが起動し続ける
