#!/bin/bash

SCRIPT_NAME=$0

WAIT_TIME_SECONDS=5

log() {
  message=$1
  if [ -n message ];then
    echo "$SCRIPT_NAME - $message"
  fi
}

set -e

log "Starting openvpn..."

# check dei file con msg di errore

openvpn --config /etc/openvpn/client.ovpn --auth-user-pass /etc/openvpn/auth.txt

log "openvpn kicked off, waiting $WAIT_TIME_SECONDS seconds..."
sleep $WAIT_TIME_SECONDS

log "...done waiting, starting squid"

SQUID_PORT=${SQUID_PORT:-3128}
PX_PORT=${PX_PORT:-3129}
PX_HOST=${PX_HOST:-127.0.0.1}

sed "s/{{SQUID_PORT}}/${SQUID_PORT}/g" /etc/squid/squid.conf.template > /etc/squid/squid.conf

if [ -z "$OUTBOUND_PROXY_PAC_URL" ]; then
  log "No OUTBOUND_PROXY_PAC_URL specified, not amending squid configuration"
else
  log "OUTBOUND_PROXY_PAC_URL specified as $OUTBOUND_PROXY_PAC_URL, amending squid configuration"
  echo "" >> /etc/squid/squid.conf
  echo "cache_peer 127.0.0.1 parent $PX_PORT 0 no-query default" >> /etc/squid/squid.conf
  echo "" >> /etc/squid/squid.conf
  echo "never_direct allow all" >> /etc/squid/squid.conf
  echo "" >> /etc/squid/squid.conf
fi

log "About to start squid on port $SQUID_PORT"

squid -N -d1 &

log "squid kicked off"

if [ -z "$OUTBOUND_PROXY_PAC_URL" ]; then
  log "No OUTBOUND_PROXY_PAC_URL specified, skipping px-proxy startup"
else
  log "OUTBOUND_PROXY_PAC_URL specified as $OUTBOUND_PROXY_PAC_URL, will start a px-proxy"
  log "waiting $WAIT_TIME_SECONDS seconds..."
  sleep $WAIT_TIME_SECONDS
  log "...done waiting, starting px-proxy with PAC location $OUTBOUND_PROXY_PAC_URL on port $PX_PORT"
  px --pac="$OUTBOUND_PROXY_PAC_URL" --listen"$PX_HOST" --port="$PX_PORT" --debug &
fi

wait -n
