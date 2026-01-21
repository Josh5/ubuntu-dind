# Ubuntu DIND


## Developing

From the root of this project, run these commands:

1) Create the development data directory
    ```
    mkdir -p ./tmp/data/dind/{certs,etc,var}
    ```

2) Create a `.env` file
    ```
    cp -v .env.example .env
    ```

3) Modify the `.env` file with the path to the development data directory
    ```
    sed -i "s|^DATA_PATH=.*|DATA_PATH=${PWD:?}/tmp/data/dind|" .env
    ```

4) Create the custom docker network.
    a) Bridge
    ```
    sudo docker network create dind-private
    ```

5) Build the docker image.
    ```
    sudo docker compose build
    ```

6) Modify any additional config options in the `.env` file.

7) Run the dev compose stack
    ```
    sudo docker compose up -d
    ```
    To test this is working, run this:
    ```
    sudo docker run --rm -ti \
        --network dind-private \
        --env DOCKER_TLS_CERTDIR="/certs" \
        --env DOCKER_HOST="tcp://docker:2376" \
        --volume ./tmp/data/dind/certs/ca:/certs/ca \
        --volume ./tmp/data/dind/certs/client:/certs/client \
        docker:latest version
    ```
    or this if not configured with certs:
    ```
    sudo docker run --rm -ti \
        --network dind-private \
        --env DOCKER_TLS_CERTDIR="" \
        --env DOCKER_HOST="tcp://docker:2375" \
        docker:latest version
    ```
