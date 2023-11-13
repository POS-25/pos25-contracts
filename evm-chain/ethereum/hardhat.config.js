require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("dotenv").config();

const privateKey = process.env.PRIVATE_KEY;
const providerTestnetUrl = process.env.PROVIDER_TESTNET_URL;
const providerMainnetUrl = process.env.PROVIDER_MAINNET_URL;
const etherScanApiKey = process.env.ETHERSCAN_API_KEY; //use for verify smart contract

module.exports = {
    solidity: "0.8.19",
    networks: {
        goerli: {
            // This will allow us to use our private key for signing later
            accounts: [`0x${privateKey}`],
            // This is the testnet chain ID
            chainId: 5,
            // provider url
            url: providerTestnetUrl
        },
        mainnet: {
            // This will allow us to use our private key for signing later
            accounts: [`0x${privateKey}`],
            // This is the mainnet chain ID
            chainId: 1,
            // provider url
            url: providerMainnetUrl
        },
    },
    etherscan: {
        apiKey: etherScanApiKey
    },
};