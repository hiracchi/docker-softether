FROM hiracchi/ubuntu-ja
MAINTAINER Toshiyuki HIRANO <hiracchi@gmail.com>

# packages install
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    gcc make binutils libc-dev zlib1g-dev openssl libssl-dev libreadline-dev libncurses-dev \
    && apt -y autoclean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src
RUN git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git softether

WORKDIR /usr/local/src/softether
RUN echo "1\n2" | ./configure && make && make install && make clean

# remove build tools
# RUN apt remove -y \
#    build-essential \
#    git gcc make \
#    && apt -y autoremove

WORKDIR /
RUN mkdir -p /work
COPY vpn_server.config /work/vpn_server.config
RUN ln -sf /work/vpn_server.config /usr/vpnserver/vpn_server.config
RUN rm -rf /usr/local/src/softether

COPY vpnserver /etc/init.d/vpnserver
RUN chmod +x /etc/init.d/vpnserver

COPY run_service.sh /root/run_service.sh
RUN chmod +x /root/run_service.sh

# 443 for OpenVPN over TLS
# 500 4500 for L2TP/IPSec
# 1701 for L2TP tunnel
# 4500 for NAT traversal
# 5555 for SoftEtherVPN
EXPOSE 443/tcp 500/udp 4500/udp 1701/udp 5555/tcp
ENTRYPOINT /root/run_service.sh

