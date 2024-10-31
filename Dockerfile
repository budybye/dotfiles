# docker run --rm --privileged --name -it 5432:5432
# ubuntu
FROM ubuntu:24.04

# rdp
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends xfce4 xfce4-goodies xrdp && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN systemctl enable xrdp

RUN echo "xfce4-session" > ~/.xsession

CMD ["/usr/sbin/xrdp", "-nodaemon"]
