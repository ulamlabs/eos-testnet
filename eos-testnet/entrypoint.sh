#!/bin/bash
set -x
action=$1
shift

export EOS_TEST_ACCOUNT=${EOS_TEST_ACCOUNT:-"eostest12345"}
export EOS_PRIVATE_KEY=${EOS_PRIVATE_KEY:-"5JeaxignXEg3mGwvgmwxG6w6wHcRp9ooPw81KjrP2ah6TWSECDN"}
export EOS_PUBLIC_KEY=${EOS_PUBLIC_KEY:-"EOS8VhvYTcUMwp9jFD8UWRMPgWsGQoqBfpBvrjjfMCouqRH9JF5qW"}

sed -i "s|\$EOS_PUBLIC_KEY|$EOS_PUBLIC_KEY|g" /app/genesis.json
sed -i "s|\$EOS_PUBLIC_KEY|$EOS_PUBLIC_KEY|g" /app/config.ini
sed -i "s|\$EOS_PRIVATE_KEY|$EOS_PRIVATE_KEY|g" /app/config.ini

case $action in
start)
    ( sleep 3 ; bash /app/bootstrap.sh ) &
    nodeos -d /data --config-dir /app --genesis-json="/app/genesis.json"
    ;;
*)
    exec $action "$@"
    ;;
esac
