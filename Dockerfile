FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies xrdp build-essential cmake dbus-x11 \
    libfuse2 libssl-dev pkg-config apt-transport-https \
    ca-certificates xorgxrdp zsh vim gh curl wget jq gzip ruby cargo \
    tree xsel xdotool ncdu mkcert pwgen gawk neofetch lsd fzf \
    ffmpeg mpd mpc ncmpcpp language-pack-ja-base language-pack-ja \
    manpages-ja fcitx5-mozc rsyslog ufw sudo && \
    apt remove -y light-locker xscreensaver && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/cache/apt /var/lib/apt/lists

EXPOSE 3389
RUN systemctl enable xrdp && \
    echo "xfce4-session" > ~/.xsession

# COPY ./bin/setup.sh /usr/bin/
# RUN mv /usr/bin/setbup.sh /usr/bin/setup.sh
# RUN chmod +x /usr/bin/setup.sh
# ENTRYPOINT ["/usr/bin/setup.sh"]
