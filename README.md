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
