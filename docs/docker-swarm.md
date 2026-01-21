# Docker Swarm

This guide describes how to run this image as a Docker-in-Docker (DIND) swarm worker and join it to an existing Swarm cluster.

## Prerequisites

- A Docker Swarm manager already initialized (`docker swarm init` or an existing cluster).
- A join token from the manager:
  - `docker swarm join-token worker`
- A dedicated network/subnet for the container (see the compose file).

## Compose file

Use one of the Swarm worker compose files as a template:

- `docs/compose-files/docker-compose.swarm-worker.yml`
- `docs/compose-files/docker-compose.swarm-worker-unprivileged.yml`

That file is already structured for a static IP and privileged mode.

## Quick start

1) Prepare host paths (example):

```
mkdir -p /mnt/user/system/dind-swarm-worker/{certs,etc}
mkdir -p /var/lib/docker/dind-var/dind-swarm-worker
```

2) Create a config file (either in Portainer or a `.env` file) using the header in `docs/compose-files/docker-compose.swarm-worker.yml`. At minimum set:

- `HOST_HOSTNAME`
- `HOST_CONTAINERNAME`
- `DIND_SUBNET`
- `DIND_IP_ADDRESS`
- `CONFIG_PATH`
- `CERTS_PATH`
- `DATA_PATH`

3) Deploy the container (compose example):

```
docker compose -f docs/compose-files/docker-compose.swarm-worker.yml up -d
```

If you want unprivileged mode, use:

```
docker compose -f docs/compose-files/docker-compose.swarm-worker-unprivileged.yml up -d
```

4) Join the Swarm cluster from inside the container:

```
docker compose -f docs/compose-files/docker-compose.swarm-worker.yml exec -T dind-swarm-worker \
  docker swarm join --token <WORKER_TOKEN> <MANAGER_IP>:2377
```

For the unprivileged compose file, the service name is the same:

```
docker compose -f docs/compose-files/docker-compose.swarm-worker-unprivileged.yml exec -T dind-swarm-worker \
  docker swarm join --token <WORKER_TOKEN> <MANAGER_IP>:2377
```

5) Verify from a manager:

```
docker node ls
```

## Notes

- The default swarm worker uses `privileged: true` and mounts `/var/lib/docker` from the host path specified by `DATA_PATH`.
- The unprivileged variant requires the `cap_add`, `security_opt`, and `/dev/net/tun` settings to match rootless mode.
- If you enable TLS for the daemon (`DOCKER_TLS_CERTDIR=/certs`), ensure the certs path is writable for the container.
- For NVIDIA GPU support, add the relevant environment variables and runtime settings as shown in the swarm worker compose file.
