FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    openconnect \
    squid \
    iproute2 \
    iputils-ping \
    curl \
    python3 \
    python3-pip \
    microsocks \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install px-proxy

ENV PATH="/usr/local/bin:${PATH}"

COPY squid.conf /etc/squid/squid.conf.template

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
