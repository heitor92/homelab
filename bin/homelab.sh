#!/bin/bash

PROJECT_ROOT="$(pwd)"

change_directory() {
    # Muda para o diretório raiz
    cd "$SERVICE_DIR" || exit 1
}

docker_compose() {
    docker compose $PARAMS
}

# create_network(){
#     docker network create "$NETWORK_NAME"
# }


main() {

    SERVICE=$1
    SERVICE_DIR="$PROJECT_ROOT/.docker/service/$SERVICE"
    if [ ! -d "$SERVICE_DIR" ]; then
        echo "Erro: O diretório $SERVICE_DIR não existe."
        exit 1
    else
        change_directory
        PARAMS="${@:2}"
        # # Verifica se a rede existe
        # if ! docker network ls | grep -q "$NETWORK_NAME"; then
        #     create_network
        # fi
        docker_compose
        # exit 0
    fi



}

main "$@"


