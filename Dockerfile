# docker run --rm --privileged --name -it 5432:5432
# ubuntu
FROM ubuntu:24.04

# rdp
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies xrdp build-essential cmake libfuse2 libssl-dev pkg-config apt-transport-https ca-certificates zsh vim gh curl wget jq gzip ruby cargo tree xsel xdotool ncdu mkcert pwgen gawk neofetch lsd fzf ffmpeg mpd mpc ncmpcpp language-pack-ja-base language-pack-ja manpages-ja fcitx5-mozc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN systemctl enable xrdp

RUN echo "xfce4-session" > ~/.xsession

CMD ["/usr/sbin/xrdp", "-nodaemon"]
