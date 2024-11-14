FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies xrdp xorgxrdp dbus-x11 gzip xdotool xsel \
    language-pack-ja-base language-pack-ja manpages-ja fcitx5-mozc \
    tree ncdu mkcert pwgen gawk neofetch lsd ffmpeg mpd mpc ncmpcpp age \
    build-essential libssl-dev pkg-config apt-transport-https \
    libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev \
    cmake g++ ca-certificates zsh vim git gh curl wget jq python3 ruby cargo && \
    apt-get remove -y light-locker xscreensaver && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/cache/apt /var/lib/apt/lists/*

EXPOSE 3389

RUN systemctl enable xrdp && echo "xfce4-session" > ~/.xsession

# COPY ./bin/setup.sh /usr/bin/
# RUN mv /usr/bin/setbup.sh /usr/bin/setup.sh
# RUN chmod +x /usr/bin/setup.sh
# ENTRYPOINT ["/usr/bin/setup.sh"]
