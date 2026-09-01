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
    locales

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    locale-gen ja_JP.UTF-8 && \
    echo LANGUAGE=${LANGUAGE} >> /etc/default/locale && \
    echo LANG=${LANG} >> /etc/default/locale && \
    echo LC_ALL=${LC_ALL} >> /etc/default/locale

# CLI パッケージをインストール
RUN apt-get install -y \
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
    jq \
    ncdu \
    gawk \
    mkcert \
    byobu \
    openssh-server \
    ca-certificates \
    apt-transport-https

# 開発用パッケージをインストール
RUN apt-get install -y \
    g++ \
    cmake \
    build-essential \
    libssl-dev \
    pkg-config \
    software-properties-common \
    python3 \
    ruby
    
# ENTRYPOINT を/usr/bin/にコピーしてシンボリックリンクを作成
COPY ./run.sh /usr/bin/
RUN ln -s /usr/bin/run.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint

# devユーザー設定
# ARG DEV=dev
# ARG DEV_PW=dev

# RUN groupadd -g 1024 -f $DEV && \
#     useradd --uid 1024 --gid 1024 -m $DEV -G sudo -s /usr/bin/zsh && \
#     echo "$DEV:$DEV_PW" | chpasswd && \
#     echo "$DEV ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
#     mkdir -p /home/$DEV && \
#     chown -R $DEV:$DEV /home/$DEV

# ubuntuユーザー設定
RUN usermod -aG sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/ubuntu && \
    chown -R ubuntu:ubuntu /home/ubuntu

# ubuntuユーザで実行
# ホームディレクトリに dotfiles をクローン
# dotfiles へ移動して make init を実行
USER ubuntu
WORKDIR /home/ubuntu
RUN git clone https://github.com/budybye/dotfiles.git
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
CMD ["ubuntu", "ubuntu", "yes"]
# $1 ユーザー名
# $2 パスワード
# $3 sudo-no-passwd yes or other
