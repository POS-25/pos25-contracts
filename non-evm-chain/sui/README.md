# SUI POS25 contract

## Deploy the contract
### Managing Networks

- Switching network: `sui client switch --env [network alias]`
- Default network aliases: 
    - localnet: http://0.0.0.0:9000
    - devnet: https://fullnode.devnet.sui.io:443
    - testnet:  https://sui-testnet-rpc.allthatnode.com:443
- List all current network aliases: `sui client envs`
- Add new network alias: `sui client new-env --alias <ALIAS> --rpc <RPC>`

### Check Active Address

- Check current addresses in key store: `sui client addresses`
- Check active-address: `sui client active-address`
- The active address is the fee payer's address for deploying.

The Sui CLI command for deploying the package is the following:

```bash
sui client publish --gas-budget <gas_budget> [absolute file path to the package that needs to be published]
```

For the `gas_budget`, we can use a standard value like `100000000`.


