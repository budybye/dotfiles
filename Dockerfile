# docker run --rm --privileged --name -it 5432:5432
# ubuntu
FROM ubuntu:24.04

# rdp
RUN dpkg --configure -a && \
    apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies xrdp build-essential cmake \
    libfuse2 libssl-dev pkg-config apt-transport-https \
    ca-certificates zsh vim gh curl wget jq gzip ruby cargo \
    tree xsel xdotool ncdu mkcert pwgen gawk neofetch lsd fzf \
    ffmpeg mpd mpc ncmpcpp language-pack-ja-base language-pack-ja \
    manpages-ja fcitx5-mozc rsyslog ufw && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^s*REGDOMAIN=S*/REGDOMAIN=JP/' /etc/default/crda || true
# RUN LANG=C xdg-user-dirs-update --force
# RUN im-config -n fcitx5
RUN systemctl restart rsyslog
# RUN usermod -a -G ssl-cert,xrdp,input,audio ${USERNAME}
# RUN ufw allow 3389
RUN systemctl enable xrdp
# RUN systemctl start xrdp
RUN echo "xfce4-session" > ~/.xsession
# RUN update-alternatives --set x-session-manager /usr/bin/xfce4-session

CMD ["/usr/sbin/xrdp", "-nodaemon"]
