# EOS Testnet Docker Image

![Docker](https://github.com/ulamlabs/eos-testnet/workflows/Docker/badge.svg) [![](https://images.microbadger.com/badges/version/ulamlabs/eos-testnet.svg)](https://microbadger.com/images/ulamlabs/eos-testnet "Get your own version badge on microbadger.com")

Docker image which bootstraps a custom EOS testnet node. 

## Environment variables

Docker image makes use of these environment variables:

- `EOS_PUBLIC_KEY` - public key for `eosio` account, defaults to `EOS8VhvYTcUMwp9jFD8UWRMPgWsGQoqBfpBvrjjfMCouqRH9JF5qWz`,
- `EOS_PRIVATE_KEY` - private key for `eosio` account, defaults to `5JeaxignXEg3mGwvgmwxG6w6wHcRp9ooPw81KjrP2ah6TWSECDN`,
- `EOS_TEST_ACCOUNT` - account name for test account, defaults to `eostest12345`. Test account is initialized with balance of 50000000000.0000 EOS. There is 9000000000.0000 EOS staked on both CPU and NET. Account has 8192 KB of RAM

## Usage
### `test_eosio.sh`

Script for debugging `eosio.system` contract deployment timeout issue. It will try to bring up EOS testnet and count how many attempts it took for the system contract to be successfully deployed. I placed an arbitrary limit of 10 retries before killing the container. In my experience, if 10 attempts aren't enough, any further ones won't make any difference and container must be killed. This limit can be overriden by setting `RETRY_LIMIT` env variable. `test_eosio.sh` takes 1 argument which is sample size, defaults to 100.

```
$ ./test_eosio.sh 500 1> eosio.csv
```

### `ensure_eosio.sh`

Script which tries to workaround the issue with contract deployment by retrying the process until it succeeds. You can use it to bootstrap the testnet.

```
$ ./ensure_eosio.sh
```
