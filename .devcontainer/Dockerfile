FROM ubuntu:24.04

ARG USERNAME=budybye
ARG USER_ID=1010
ARG USER_GID=$USER_ID

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
    rm -rf /var/cache/apt /var/lib/apt/lists/* && \
    usermod -aG sudo $USERNAME && \
    sudo snap remove firefox

RUN groupadd -g $USER_GID -f $USERNAME && \
    useradd --uid $USER_ID --gid $USER_GID -m $USERNAME -G sudo -s /usr/bin/zsh && \
    echo "$USERNAME:$USERNAME" | chpasswd && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /home/$USERNAME && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME/.local/share/chezmoi

RUN sudo sh -c "$(curl -fsSL get.chezmoi.io)" -- -b /usr/local/bin

RUN sudo sed -i 's/^\s*REGDOMAIN=S*/REGDOMAIN=JP/' /etc/default/crda || true && \
    LANG=C xdg-user-dirs-update --force && \
    im-config -n fcitx5 && \
    setupcon -k --force || true

RUN groupadd -f input && \
    groupadd -f xrdp && \
    groupadd -f audio && \
    groupadd -f ssl-cert && \
    usermod -aG input xrdp audio ssl-cert $USERNAME && \
    systemctl enable xrdp && \
    systemctl start xrdp && \
    update-alternatives --set x-session-manager /usr/bin/xfce4-session && \
    echo "xfce4-session" > ~/.xsession

EXPOSE 3389

# COPY ./bin/setup.sh /usr/bin/
# RUN mv /usr/bin/setbup.sh /usr/bin/setup.sh
# RUN chmod +x /usr/bin/setup.sh
# ENTRYPOINT ["/usr/bin/setup.sh"]
