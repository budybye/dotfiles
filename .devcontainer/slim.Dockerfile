ARG BASE_IMAGE=ubuntu:26.04
FROM ${BASE_IMAGE} AS base

# パッケージのインストールを非対話形式で行う
ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKER=true
ENV REMOTE_CONTAINERS=true

ENV TZ=Asia/Tokyo
ENV LANG=ja_JP.UTF-8
ENV LC_ALL=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja

# 日本語環境を設定
# language-pack-ja* は Ubuntu 専用なので、apt に存在する場合だけ入れる
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    manpages-ja \
    tzdata \
    locales && \
    if apt-cache show language-pack-ja >/dev/null 2>&1; then \
        apt-get install -y --no-install-recommends \
        language-pack-ja \
        language-pack-ja-base; \
    fi && \
    rm -rf /var/lib/apt/lists/*

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    sed -i 's/^# *\(ja_JP.UTF-8 UTF-8\)/\1/' /etc/locale.gen && \
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

# software-properties-common は Debian 13 (trixie) 以降に無いので、apt に存在する場合だけ入れる
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    g++ \
    cmake \
    build-essential \
    libssl-dev \
    pkg-config \
    python3 \
    rustup \
    ruby && \
    if apt-cache show software-properties-common >/dev/null 2>&1; then \
        apt-get install -y --no-install-recommends software-properties-common; \
    fi && \
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

# アプリユーザー設定。Debian 系の base image には ubuntu ユーザーが無いので無ければ作る
# CMD は exec 形式で ARG を展開できない。APP_USER を変えたら run 時の引数も合わせる
ARG APP_USER=ubuntu
RUN if ! id "${APP_USER}" >/dev/null 2>&1; then \
        useradd --create-home --shell /usr/bin/zsh "${APP_USER}"; \
    fi && \
    usermod -aG sudo "${APP_USER}" && \
    echo "${APP_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p "/home/${APP_USER}" && \
    chown -R "${APP_USER}:$(id -gn "${APP_USER}")" "/home/${APP_USER}"

# アプリユーザーで dotfiles を適用
USER ${APP_USER}
WORKDIR /home/${APP_USER}
ARG DOTFILES_REF=main
ARG DOTFILES_REV=unknown
RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN \
    echo "dotfiles revision: ${DOTFILES_REV}" && \
    if [ -n "${GITHUB_TOKEN:-}" ]; then \
        auth="$(printf 'x-access-token:%s' "${GITHUB_TOKEN}" | base64 -w0)"; \
        git -c "http.extraheader=AUTHORIZATION: basic ${auth}" \
            clone --depth=1 --branch "${DOTFILES_REF}" https://github.com/budybye/dotfiles.git; \
    else \
        git clone --depth=1 --branch "${DOTFILES_REF}" https://github.com/budybye/dotfiles.git; \
    fi && \
    if [ "${DOTFILES_REV}" != "unknown" ]; then \
        test "$(git -C dotfiles rev-parse HEAD)" = "${DOTFILES_REV}"; \
    fi
RUN --mount=type=secret,id=github_token,env=GITHUB_TOKEN \
    export MISE_GITHUB_TOKEN="${GITHUB_TOKEN:-}" && \
    cd dotfiles && make init

USER root
# build 後の apt cache を削除
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*

EXPOSE 22
ENTRYPOINT ["entrypoint"]
CMD ["ubuntu", "ubuntu", "no"]
# $1 ユーザー名
# $2 パスワード
# $3 sudo グループに追加するか yes or other（NOPASSWD は付かない）
