# Docker Compose

Follow these instructions to configure a `docker-compose.yml` for `ubuntu-dind`.

> __Note__
>
> These instructions assume that you have Docker and Docker Compose installed.
> Depending on how you installed them, the command may be `docker compose` or `docker-compose`.

## Prepare directories

> __Warning__
>
> These commands are meant to be run as your user. Do not run them as root.
> If you do run these commands as root, you may need to manually fix ownership.

Create a directory for your compose project:
```shell
mkdir -p /opt/container-services/ubuntu-dind
```

Create a directory for your data:
```shell
mkdir -p /opt/container-data/ubuntu-dind/{certs,etc,var}
```

## Choose a compose file

Copy one of the templates below to `/opt/container-services/ubuntu-dind/docker-compose.yml`:

- Default (CPU only): `docs/compose-files/docker-compose.default.yml`
- NVIDIA GPUs: `docs/compose-files/docker-compose.nvidia.yml`
- Swarm worker example: `docs/compose-files/docker-compose.swarm-worker.yml`

## Configure environment

Create `/opt/container-services/ubuntu-dind/.env` with values that match your paths:
```
DATA_PATH=/opt/container-data/ubuntu-dind
```

## GPU configuration

### AMD/Intel (DRI)

For AMD/Intel GPUs, pass through `/dev/dri` devices and add the render group.
Example snippet for a service:
```yaml
    devices:
      - /dev/dri:/dev/dri
    group_add:
      - render
```

If you have multiple GPUs and want to isolate a specific card, identify it first:
```shell
lspci | grep -E 'VGA|3D'
ls -la /sys/class/drm/card*
ls -la /sys/class/drm/renderD*
```
Then map only the needed `/dev/dri/card*` and `/dev/dri/renderD*` nodes:
```yaml
    devices:
      - /dev/dri/card1:/dev/dri/card1
      - /dev/dri/renderD128:/dev/dri/renderD128
```

### NVIDIA

Use the NVIDIA compose template and ensure the NVIDIA Container Toolkit is installed on the host.
If you need to pin a specific GPU, set `NVIDIA_VISIBLE_DEVICES`:
```yaml
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=all
```

## Run

```shell
cd /opt/container-services/ubuntu-dind
docker compose up -d --force-recreate
```
