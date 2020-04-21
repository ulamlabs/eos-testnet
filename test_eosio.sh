#!/bin/bash
RETRY_LIMIT=${RETRY_LIMIT:-10}
SAMPLE_SIZE=${1:-100}

rm -rf ./logs &> /dev/null
mkdir ./logs &> /dev/null

docker-compose rm -f &> /dev/null
x=0
echo timestamp,attempt,retries
while [ $x -lt $SAMPLE_SIZE ];
do
    echo == Run $((x+1))/$SAMPLE_SIZE == >&2

    docker-compose stop &> /dev/null
    docker-compose rm -f &> /dev/null
    timestamp=$(date +"%s")
    docker-compose up -d &> /dev/null
    sleep 5

    y=0
    while [ $y -lt $RETRY_LIMIT ];
    do	
        docker exec eos-testnet cleos get table eosio eosio delband &> /dev/null
        if [ $? -eq 0 ];
        then
            break
        fi
        ((y+=1))
        sleep 10
    done
    echo $y retries >&2
    if [ $y -eq $RETRY_LIMIT ];
    then
        echo ! Retry limit exceeded >&2
    fi
    echo $timestamp,$x,$y
    docker logs eos-testnet &> logs/failures_${y}_run_${x}.log
    ((x+=1))
done
