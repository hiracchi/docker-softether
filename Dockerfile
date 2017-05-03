FROM hiracchi/ubuntu-ja:16.04
MAINTAINER Toshiyuki HIRANO <hiracchi@gmail.com>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/hiracchi/docker-softether" \
      org.label-schema.version=$VERSION


COPY vpn_server.config /tmp/vpn_server.config

# packages install
RUN rm -rf /var/lib/apt/lists/* \
  && apt-get update \
  && apt-get install -y \
    build-essential \
    git \
    gcc make binutils libc-dev zlib1g-dev openssl libssl-dev libreadline-dev libncurses-dev \
  && apt -y autoclean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /usr/local/src \
  # build softether ----------------------------------------------------
  && (cd /usr/local/src; git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git softether) \
  && (cd /usr/local/src/softether; echo "1\n2" | ./configure && make && make install && make clean) \
  # remove build tools -------------------------------------------------
  && apt remove -y \
      build-essential git gcc make \
  && apt -y autoremove \
  # setup --------------------------------------------------------------
  && mkdir -p /work \
  && mv /tmp/vpn_server.config /work/vpn_server.config \
  && ln -sf /work/vpn_server.config /usr/vpnserver/vpn_server.config \
  && rm -rf /usr/local/src/softether

# 443 for OpenVPN over TLS
# 500 4500 for L2TP/IPSec
# 1701 for L2TP tunnel
# 4500 for NAT traversal
# 5555 for SoftEtherVPN
EXPOSE 443/tcp 500/udp 4500/udp 1701/udp 5555/tcp
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/vpnserver", "start"]

