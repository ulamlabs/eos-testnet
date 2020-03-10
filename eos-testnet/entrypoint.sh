#!/bin/bash
set -x
action=$1
shift

export EOS_TEST_ACCOUNT=${EOS_TEST_ACCOUNT:-"eostest12345"}
export EOS_PRIVATE_KEY=${EOS_PRIVATE_KEY:-"5JeaxignXEg3mGwvgmwxG6w6wHcRp9ooPw81KjrP2ah6TWSECDN"}
export EOS_PUBLIC_KEY=${EOS_PUBLIC_KEY:-"EOS8VhvYTcUMwp9jFD8UWRMPgWsGQoqBfpBvrjjfMCouqRH9JF5qW"}
envsubst '$$EOS_PUBLIC_KEY' < /app/genesis.json.template > /app/genesis.json

case $action in
start)
    ( sleep 3 ; bash /app/bootstrap.sh ) &
    nodeos -d /data --config-dir /app -e -p eosio --contracts-console --verbose-http-errors --genesis-json="/app/genesis.json" --filter-on "*"
    ;;
*)
    exec $action "$@"
    ;;
esac
