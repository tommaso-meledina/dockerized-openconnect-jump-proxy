#!/bin/bash

SCRIPT_NAME=$0

WAIT_TIME_SECONDS=5
DEFAULT_VPN_AUTH_GROUP="development"
DEFAULT_VPN_OS="win"
DEFAULT_VPN_USER_AGENT='AnyConnect Windows 4.9.00086'

log() {
  message=$1
  if [ -n message ];then
    echo "$SCRIPT_NAME - $message"
  fi
}

set -e

log "Starting openconnect..."

VPN_AUTH_GROUP=${VPN_AUTH_GROUP:-$DEFAULT_VPN_AUTH_GROUP}

VPN_OS=${VPN_OS:-$DEFAULT_VPN_OS}

VPN_USER_AGENT=${VPN_USER_AGENT:-$DEFAULT_VPN_USER_AGENT}

echo "$VPN_PW" | openconnect \
  -v \
  --authgroup $VPN_AUTH_GROUP \
  -u "$VPN_USER" \
  --passwd-on-stdin \
  --servercert "$VPN_SERVER_CERT" \
  --os="$VPN_OS" \
  --background \
  --useragent="$VPN_USER_AGENT" \
  "$VPN_SERVER"

log "openconnect kicked off, waiting $WAIT_TIME_SECONDS seconds..."
sleep $WAIT_TIME_SECONDS

log "...done waiting, starting squid"

SQUID_PORT=${SQUID_PORT:-3128}
sed "s/{{SQUID_PORT}}/${SQUID_PORT}/g" /etc/squid/squid.conf.template > /etc/squid/squid.conf

log "About to start squid on port $SQUID_PORT"

squid -N -d1