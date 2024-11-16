FROM ubuntu:24.04

ARG USERNAME=budybye
ARG USER_ID=1010
ARG USER_GID=$USER_ID

ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies xrdp xorgxrdp dbus-x11 gzip xdotool xsel sshfs ufw \
    language-pack-ja-base language-pack-ja manpages-ja fcitx5-mozc im-config \
    tree ncdu mkcert pwgen gawk neofetch lsd ffmpeg mpd mpc ncmpcpp age \
    build-essential libssl-dev pkg-config apt-transport-https avahi-daemon \
    libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
    cmake g++ ca-certificates zsh vim git gh curl wget jq python3 ruby cargo flatpak && \
    apt-get remove -y light-locker xscreensaver && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*

RUN groupadd -g $USER_GID -f $USERNAME && \
    useradd --uid $USER_ID --gid $USER_GID -m $USERNAME -G sudo -s /bin/bash && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p /home/$USERNAME && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME/.local/share/chezmoi

RUN sh -c "$(curl -fsSL get.chezmoi.io)" -- -b /usr/local/bin

RUN sudo systemctl enable xrdp && echo "xfce4-session" > ~/.xsession

EXPOSE 3389

# COPY ./bin/setup.sh /usr/bin/
# RUN mv /usr/bin/setbup.sh /usr/bin/setup.sh
# RUN chmod +x /usr/bin/setup.sh
# ENTRYPOINT ["/usr/bin/setup.sh"]
