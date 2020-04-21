#!/bin/bash
set -x

# `eosio` account is already precreated on fresh node, it's public and private
# key is as defined in EOS_PUBLIC_KEY and EOS_PRIVATE_KEY variables
# by importing it to our wallet we take over eosio account
# In eos, one account can have just one contract attached to it,
# we need to create bunch of accounts and post contracts to them to have whole node operational
# At the end we will create normal staked account that will act as our buffer account.

retry() {
    until "$@"; do
       echo "retry"
       sleep 10
    done
}

deploy_contract() {
  cleos set contract $1 $2 -j -d -s -x 3600 > /tmp/trx
  retry cleos sign -k $EOS_PRIVATE_KEY -p /tmp/trx
}

# https://eosio.stackexchange.com/a/5052/3555
curl -X POST http://127.0.0.1:8888/v1/producer/schedule_protocol_feature_activations -d '{"protocol_features_to_activate": ["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}'

cleos wallet create -f /tmp/pass
cleos wallet import --private-key $EOS_PRIVATE_KEY

for x in eosio.bpay eosio.msig eosio.names eosio.ram eosio.ramfee eosio.saving eosio.stake eosio.token eosio.vpay eosio.rex eosio.wrap
do
  cleos create account eosio ${x} $EOS_PUBLIC_KEY
done

deploy_contract eosio /tmp/eosio.contracts/build/contracts/eosio.system/

for x in eosio.msig eosio.token eosio.wrap
do
  deploy_contract ${x} /tmp/eosio.contracts/build/contracts/${x}/
done

sleep 1

retry cleos push action eosio.token create '[ "eosio", "90000000000.0000 EOS" ]' -p eosio.token@active
retry cleos push action eosio.token issue '[ "eosio", "90000000000.0000 EOS", "memo" ]' -p eosio@active
retry cleos push action eosio setpriv '["eosio.msig", 1]' -p eosio@active
retry cleos push action eosio init '["0", "4,EOS"]' -p eosio@active
# create main staked account
# Please remember that resource pricing depends not only on how much CPU power
# is available, but also how many resources were staked by all users of the
# network
# CPU_max = V_limit * 172800 * (A_su/A_sau)
# - where CPU max is max CPU time available for the user
# - V_limit - virtual CPU limit, calculated based on how long it takes to mine
#   a block
# - A_su - amount staked by given account
# - A_sau - amount staked by all accounts
# https://steemit.com/eos/@dexeosio/eosio-why-cpu-bandwidth-varies

retry cleos system newaccount eosio --transfer $EOS_TEST_ACCOUNT $EOS_PUBLIC_KEY --stake-net "675000000.0000 EOS" --stake-cpu "6750000000.0000 EOS" --buy-ram-kbytes 8192
retry cleos transfer eosio $EOS_TEST_ACCOUNT "50000000000.0000 EOS"

# register and vote for producer to make chain activated
# otherwise we can't undelegate resources
retry cleos system regproducer eosio $EOS_PUBLIC_KEY
retry cleos system voteproducer prods $EOS_TEST_ACCOUNT eosio

# ONLY_BILL_FIRST_AUTHORIZER
# https://github.com/EOSIO/eos/blob/master/libraries/chain/protocol_feature_manager.cpp#L107
retry cleos push action eosio activate '["8ba52fe7a3956c5cd3a656a3174b931d3bb2abb45578befc59f283ecd816a405"]' -p eosio@active

# Enable all mainnet protocol features:
# - RAM_RESTRICTIONS
# - FIX_LINKAUTH_RESTRICTION
# - ONLY_LINK_TO_EXISTING_PERMISSION
# - DISALLOW_EMPTY_PRODUCER_SCHEDULE
retry cleos push action eosio activate '["4e7bf348da00a945489b2a681749eb56f5de00b900014e137ddae39f48f69d67"]' -p eosio@active
retry cleos push action eosio activate '["e0fb64b1085cc5538970158d05a009c24e276fb94e1a0bf6a528b48fbc4ff526"]' -p eosio@active
retry cleos push action eosio activate '["1a99a59d87e06e09ec5b028a9cbb7749b4a5ad8819004365d02dc4379a8b7241"]' -p eosio@active
retry cleos push action eosio activate '["68dcaa34c0517d19666e6b33add67351d8c5f69e999ca1e37931bc410a297428"]' -p eosio@active
