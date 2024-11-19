FROM ubuntu:24.04

ARG USER=docker
ARG UID=1010
ARG GID=1010
ARG HOME=/home/$USER

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

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
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p $HOME && \
    chown -R $USER:$USER $HOME

USER $USER
WORKDIR $HOME/.local/share/chezmoi

RUN sudo sh -c "$(curl -fsSL get.chezmoi.io)" -- -b /usr/local/bin

RUN curl -fsSL https://mise.run | sh && \
    export PATH="${HOME}/.local/bin:${PATH}" && \
    mise use -g bun node@20 -y --verbose && \
    ${HOME}/.local/share/mise/installs/bun/1.1.34/bin/bun install -g @bitwarden/cli

RUN im-config -n fcitx5 && \
    setupcon -k --force || true

RUN groupadd -f input && \
    groupadd -f xrdp && \
    groupadd -f audio && \
    groupadd -f ssl-cert && \
    sudo usermod -aG input,xrdp,audio,ssl-cert $USERNAME && \
    systemctl enable xrdp && \
    sudo update-alternatives --set x-session-manager /usr/bin/xfce4-session && \
    echo "xfce4-session" > ~/.xsession

EXPOSE 3389

# COPY ./bin/setup.sh /usr/bin/
# RUN mv /usr/bin/setbup.sh /usr/bin/setup.sh
# RUN chmod +x /usr/bin/setup.sh
# ENTRYPOINT ["/usr/bin/setup.sh"]
