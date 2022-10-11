#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
COMPOSE=docker-compose

if ! [ -x "$(docker compose)" ]; then
    COMPOSE="docker compose"
fi

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
            bigtable) shift; fn_bigtable "@"; exit;; 
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
    sudo $COMPOSE down
    sudo rm -rf docker-volumes
}

fn_sql() {
    echo "use sql to explore postgres"
    $COMPOSE exec postgres psql -U postgres -d db
}

fn_bigtable() {
    echo "use cbt to explore bigtable"
    $COMPOSE exec bigtable bash
}

fn_init_dbs() {
    $COMPOSE up -d postgres redis bigtable
    $COMPOSE exec bigtable /init-bigtable.sh
}

fn_start_eth1indexer() {
    $COMPOSE up -d eth1indexer
    $COMPOSE logs -f --tail 10 eth1indexer
}

fn_start_exporter() {
    $COMPOSE up -d exporter
    $COMPOSE logs -f --tail 10 exporter
}

fn_start_statistics() {
    $COMPOSE up -d statistics
    $COMPOSE logs -f --tail 10 statistics
}

fn_start_frontend() {
    $COMPOSE up -d frontend-updater frontend
    $COMPOSE logs -f --tail 10 frontend
    echo "browse http://localhost:8080"
}

fn_explore_epoch() {
    $COMPOSE exec postgres psql -U postgres -d db --csv -c "select * from epochs where epoch = $1"
}

fn_explore_block() {
    echo "todo"
    # $COMPOSE exec bigtable cbt
}

fn_explore_address() {
    echo "todo"
    # $COMPOSE exec bigtable cbt
}

fn_main "$@"
