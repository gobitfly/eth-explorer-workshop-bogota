#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd $DIR

var_help="invalid args"

fn_main() {
    if test $# -eq 0; then
        echo "$var_help"
        return
    fi
    while test $# -ne 0; do
        case $1 in
            reset) shift; fn_reset "$@"; exit;;
            sql) shift; fn_sql "@"; exit;; 
            init-dbs) shift; fn_init_dbs "$@"; exit;;
            start-eth1indexer) shift; fn_start_eth1indexer "$@"; exit;;
            start-exporter) shift; fn_start_exporter "$@"; exit;;
            start-statistics) shift; fn_start_statistics "$@"; exit;;
            start-frontend) shift; fn_start_frontend "$@"; exit;;
            explore-epoch) shift; fn_explore_epoch "$@"; exit;;
            explore-block) shift; fn_explore_block "$@"; exit;;
            explore-address) shift; fn_explore_address "$@"; exit;;
            *) echo "$var_help"
        esac
        shift
    done
}

fn_reset() {
    echo "reset"
    sudo docker compose down
    sudo rm -rf docker-volumes
}

fn_sql() {
    docker compose exec postgres psql -U postgres -d db
}

fn_init_dbs() {
    docker compose up -d postgres redis bigtable
    docker compose exec bigtable /init-bigtable.sh
}

fn_start_eth1indexer() {
    docker compose up -d eth1indexer
    docker compose logs -f --tail 10 eth1indexer
}

fn_start_exporter() {
    docker compose up -d exporter
    docker compose logs -f --tail 10 exporter
}

fn_start_statistics() {
    docker compose up -d statistics
    docker compose logs -f --tail 10 statistics
}

fn_start_frontend() {
    docker compose up -d frontend-updater frontend
    docker compose logs -f --tail 10 frontend
    echo "browse http://localhost:8080"
}

fn_explore_epoch() {
    docker compose exec postgres psql -U postgres -d db --csv -c "select * from epochs where epoch = $1"
}

fn_explore_block() {
    echo "todo"
}

fn_explore_address() {
    echo "todo"
}

fn_main "$@"
