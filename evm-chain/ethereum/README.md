# EVM POS25 contracts
- Ethereum
- Base
- Scroll
- Bitgert 
- Avalanche
- Linea
- ZkSync
- Nautilus

## Deploy the contract
### Managing Networks

- Switching network: hardhat.config.js
```
    networks: {
        goerli: {
            // This will allow us to use our private key for signing later
            accounts: [`0x${privateKey}`],
            // This is the testnet chain ID
            chainId: 5,
            url: providerTestnetUrl
        },
        mainnet: {
            // This will allow us to use our private key for signing later
            accounts: [`0x${privateKey}`],
            // This is the mainnet chain ID
            chainId: 1,
            url: providerMainnetUrl
        },
    },
```

- .env
```
    PRIVATE_KEY =
    PROVIDER_TESTNET_URL =
    PROVIDER_MAINNET_URL =
    ETHERSCAN_API_KEY =
```

- Clone the repository:
```bash
git clone https://github.com/POS-25/pos25-contracts
```
- Cd to ethereum:
```bash
cd ethereum
```
- Installing packages with npm:
```bash
npm install
```

- Compiling smart contract:
```bash
npx hardhat compile
```

- Deploying & Verifying smart contract:
```bash
npx hardhat run --network <goerli | mainnet> scripts/deploy.js
```