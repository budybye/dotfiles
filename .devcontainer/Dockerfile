FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKER=true

RUN apt-get -y update
RUN apt-get -y upgrade

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
    echo LC_ALL=${LC_ALL} >> /etc/default/locale

RUN apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xfce4-session \
    xfce4-clipman-plugin \
    tigervnc-standalone-server \
    xrdp \
    xorgxrdp \
    dbus-x11 \
    gzip \
    xdotool \
    xsel \
    openssh-server \
    ufw \
    sudo

RUN apt-get install -y \
    zsh \
    make \
    curl \
    git \
    gh \
    age \
    wget \
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
    g++ \
    cmake \
    build-essential \
    libssl-dev \
    pkg-config \
    apt-transport-https \
    avahi-daemon \
    libfreetype6-dev \
    libfontconfig1-dev \
    libxcb-xfixes0-dev \
    libxkbcommon-dev \
    ca-certificates \
    python3 \
    ruby \
    cargo \
    flatpak

RUN apt-get remove -y light-locker xscreensaver && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*

ARG USER=docker
ARG UID=1010
ARG GID=$UID
ARG HOME=/home/$USER

RUN groupadd -g $GID -f $USER && \
    useradd --uid $UID --gid $GID -m $USER -G sudo -s /usr/bin/zsh && \
    echo "$USER:$USER" | chpasswd && \
    echo "ALL ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p $HOME && \
    chown -R $USER:$USER $HOME

ARG DEV=dev
ARG DEV_UID=1234
ARG DEV_GID=$DEV_UID
ARG DEV_HOME=/home/$DEV

RUN groupadd -g $DEV_GID -f $DEV && \
    useradd --uid $DEV_UID --gid $DEV_GID -m $DEV -G sudo -s /usr/bin/zsh && \
    echo "$DEV:$DEV" | chpasswd && \
    mkdir -p $DEV_HOME && \
    chown -R $DEV:$DEV $DEV_HOME

USER $USER
WORKDIR $HOME

RUN sudo sh -c "$(curl -fsSL get.chezmoi.io)" -- -b /usr/local/bin

RUN git clone https://github.com/budybye/dotfiles.git ${HOME}/dotfiles

RUN curl https://mise.run | sh && \
    ${HOME}/.local/bin/mise use -g node@20.18.1 && \
    ${HOME}/.local/share/mise/installs/node/20.18.1/bin/npm i -g @bitwarden/cli && \
    export PATH=${HOME}/.local/share/mise/shims:${HOME}/.local/share/mise/installs/node/20.18.1/bin:${PATH} && \
    echo "${PATH}" >> ~/.bashrc && \
    bw --version || echo "bw command not found"

EXPOSE 3389
EXPOSE 22

RUN mkdir -p /var/run/dbus && \
    cp /etc/X11/xrdp/xorg.conf /etc/X11 && \
    sed -i "s/console/anybody/g" /etc/X11/Xwrapper.config && \
    sed -i "s/xrdp\/xorg/xorg/g" /etc/xrdp/sesman.ini && \
    echo "xfce4-session" >> /etc/skel/.Xsession

RUN im-config -n fcitx5 && \
    groupadd -f xrdp && \
    groupadd -f ssl-cert && \
    groupadd -f input && \
    groupadd -f audio && \
    groupadd -f docker && \
    sudo usermod -aG input,xrdp,audio,ssl-cert,docker $USER && \
    echo "xfce4-session" > ~/.xsession && \
    echo "dbus-launch --exit-with-session usr/bin/xfce4-session" > ~/.startwm.sh && \
    chmod 755 ~/.startwm.sh && \
    sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session && \
    sudo systemctl enable xrdp

# COPY ../install $HOME/bin/install
# RUN chmod +x $HOME/bin/install
# CMD ["$HOME/bin/install"]
# ENTRYPOINT ["$HOME/bin/install"]
