FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    openconnect \
    squid \
    iproute2 \
    iputils-ping \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY squid.conf /etc/squid/squid.conf.template

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
