FROM ubuntu:24.04

ENV DOCKER=true

ARG USER=docker
ARG UID=1010
ARG GID=$UID
ARG HOME=/home/$USER

ARG DEV=dev
ARG DEV_UID=1234
ARG DEV_GID=$DEV_UID
ARG DEV_HOME=/home/$DEV

ENV TZ=Asia/Tokyo
ENV LANG=ja_JP.UTF-8
ENV LANGUAGE=ja_JP:ja
ENV LC_ALL=ja_JP.UTF-8

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    echo LANG=${LANG} >> /etc/default/locale && \
    echo LANGUAGE=${LANGUAGE} >> /etc/default/locale && \
    echo LC_ALL=${LC_ALL} >> /etc/default/locale

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies xrdp xorgxrdp dbus-x11 gzip xdotool xsel sshfs ufw sudo \
    language-pack-ja-base language-pack-ja manpages-ja fcitx5-mozc im-config \
    tree ncdu mkcert pwgen gawk neofetch lsd ffmpeg mpd mpc ncmpcpp age \
    build-essential libssl-dev pkg-config apt-transport-https avahi-daemon \
    libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
    cmake g++ ca-certificates zsh vim git gh curl wget jq python3 ruby cargo flatpak && \
    apt-get remove -y light-locker xscreensaver && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*

RUN groupadd -g $GID -f $USER && \
    useradd --uid $UID --gid $GID -m $USER -G sudo -s /usr/bin/zsh && \
    echo "$USER:$USER" | chpasswd && \
    echo "ALL ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p $HOME && \
    chown -R $USER:$USER $HOME

RUN groupadd -g $DEV_GID -f $DEV && \
    useradd --uid $DEV_UID --gid $DEV_GID -m $DEV -G sudo -s /usr/bin/zsh && \
    echo "$DEV:$DEV" | chpasswd && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo "$DEV ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p $DEV_HOME && \
    chown -R $DEV:$DEV $DEV_HOME

USER $USER
WORKDIR $HOME

RUN sudo sh -c "$(curl -fsSL get.chezmoi.io)" -- -b /usr/local/bin

RUN git clone https://github.com/budybye/dotfiles.git $HOME/dotfiles

RUN curl https://mise.run | sh && \
    ${HOME}/.local/bin/mise use -g bun@1.1.36 node@20.18 && \
    ${HOME}/.local/share/mise/installs/bun/1.1.36/bin/bun i -g @bitwarden/cli && \
    export PATH=${HOME}/.local/share/mise/shims:${PATH} && \
    bw --version || echo "bw command not found"

EXPOSE 3389
EXPOSE 22

RUN im-config -n fcitx5 && \
    groupadd -f input && \
    groupadd -f xrdp && \
    groupadd -f audio && \
    groupadd -f ssl-cert && \
    groupadd -f docker && \
    sudo usermod -aG input,xrdp,audio,ssl-cert,docker $USER && \
    systemctl enable xrdp && \
    echo "xfce4-session" > ~/.xsession && \
    sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session

# COPY ../install $HOME/bin/install
# RUN chmod +x $HOME/bin/install
# CMD ["$HOME/bin/install"]
# ENTRYPOINT ["$HOME/bin/install"]
