# Dockerized OpenConnect Jump Proxy

This project allows to run an OpenConnect VPN and a two proxies (HTTP and SOCKS) inside a container, effectively spinning up an ephemeral, lightweight jump proxy that can be leveraged by the host OS.

## Purpose

VPN clients are often invasive, they require to be ran with admin privileges and they alter network settings, sometimes hindering normal network connectivity.
Running VPN clients in an isolated context ensures the integrity of the host system while still allowing it to reach the secure remote locations when needed.

This project offers a small turn-key solution for spinning up a container running both the VPN client and the proxy.

## Usage

1. Build the Docker image

```bash
docker build -t openconnect-jump-proxy .
```
2. (Optional) Set the relevant environment variables

```bash
export VPN_USER="some-user"
export VPN_PW="super-secret-pw"
export VPN_SERVER="127.0.0.1"
export VPN_SERVER_CERT="Base64 server cert"
export SQUID_PORT="port where the HTTP proxy shall be listening"
export SOCKS_PORT="port where the SOCKS proxy shall be listening"
```

3. Run the Docker container

```bash
docker run -it --rm \
  --name openconnect-jump-proxy \
  -e VPN_USER="$VPN_USER" \
  -e VPN_PW="$VPN_PW" \
  -e VPN_SERVER="$VPN_SERVER" \
  -e VPN_SERVER_CERT="$VPN_SERVER_CERT" \
  -e SQUID_PORT="$SQUID_PORT" \
  -p ${SQUID_PORT:-3128}:${SQUID_PORT:-3128} \
  -p ${SOCKS_PORT:-1080}:${SOCKS_PORT:-1080} \
  --cap-add=NET_ADMIN \
  --network=host \
  openconnect-jump-proxy
```

4. (Optional) add host mappings to the container `/etc/hosts` file (replaces step `3`)

```bash
docker run -it --rm \
  --name openconnect-jump-proxy \
  -e VPN_USER="$VPN_USER" \
  -e VPN_PW="$VPN_PW" \
  -e VPN_SERVER="$VPN_SERVER" \
  -e VPN_SERVER_CERT="$VPN_SERVER_CERT" \
  -e SQUID_PORT="$SQUID_PORT" \
  -p ${SQUID_PORT:-3128}:${SQUID_PORT:-3128} \
  -p ${SOCKS_PORT:-1080}:${SOCKS_PORT:-1080} \
  --cap-add=NET_ADMIN \
  --network=host \
  --add-host=some-domain.whatever:127.0.0.2 \
  --add-host=some-other-domain.whatever:127.0.0.3 \
  openconnect-jump-proxy
```

5. (Optional) test that everything is working

```bash
curl -k -x http://localhost:$SQUID_PORT https://vpn-fronted-host
```

```bash
curl -k --socks5-hostname 127.0.0.1:1080 https://vpn-fronted-host
```

6. (Optional - victory lap) write an _alias_ for the run command

```bash
alias ojp="docker run -it --rm \
  --name openconnect-jump-proxy \
  -e VPN_USER="$VPN_USER" \
  -e VPN_PW="$VPN_PW" \
  -e VPN_SERVER="$VPN_SERVER" \
  -e VPN_SERVER_CERT="$VPN_SERVER_CERT" \
  -e SQUID_PORT="$SQUID_PORT" \
  -p ${SQUID_PORT:-3128}:${SQUID_PORT:-3128} \
  -p ${SOCKS_PORT:-1080}:${SOCKS_PORT:-1080} \
  --cap-add=NET_ADMIN \
  --network=host \
  openconnect-jump-proxy"
```

### Configuration

The tool allows to set the following configuration elements, by passing (`-e`) the desired values to the `docker run` command:

| Environment variable | Description                                                                  | Default value                  |
|----------------------|------------------------------------------------------------------------------|--------------------------------|
| `VPN_USER`           | Value to be used for the `--username` option for the `openconnect` command   | None (mandatory input)         |
| `VPN_PW`             | Value to be passed as password to the `openconnect` command                  | None (mandatory input)         |
| `VPN_SERVER`         | Value to be passed as endpoint server address to the `openconnect` command   | None (mandatory input)         |
| `VPN_SERVER_CERT`    | Value to be used for the `--servercert` option for the `openconnect` command | None (mandatory input)         |
| `SQUID_PORT`         | Port where the HTTP proxy shall be listening, on the host network            | `3128`                         |
| `SOCKS_PORT`         | Port where the SOCKS proxy shall be listening, on the host network           | `1080`                         |
| `VPN_AUTH_GROUP`     | Value to be used for the `--auth-group` option for the `openconnect` command | `development`                  |
| `VPN_OS`             | Value to be used for the `--os` option for the `openconnect` command         | `win`                          |
| `VPN_USER_AGENT`     | Value to be used for the `--useragent` option for the `openconnect` command  | `AnyConnect Windows 4.9.00086` |





