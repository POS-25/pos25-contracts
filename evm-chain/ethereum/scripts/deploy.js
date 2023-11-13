const { run, network, ethers } = require("hardhat")

async function main() {
    // Get the contract factory for the "Pos25" smart contract
    const Pos25 = await ethers.getContractFactory("Pos25")

    // Print a message indicating the deployment of the contract
    console.log("Deploying contract ....");

    // Deploy the "Pos25" contract
    const pos25 = await Pos25.deploy();

    // Wait for the deployment transaction to be confirmed
    await pos25.deploymentTransaction()?.wait(1);

    // Get the address of the deployed contract
    const posAddress = await pos25.getAddress()

    // Print the contract address
    console.log(`Contract Address: ${posAddress}`)

    // Check if an API Key is available
    // You can modify the code logic for different chainId and an available API Key in another scan.
    if (process.env.ETHERSCAN_API_KEY) {
        // Wait for an additional deployment transaction
        await pos25.deploymentTransaction()?.wait(10);

        // Call the "verify" function to verify the contract onchain
        await verify(posAddress, [])
    }
}

// Function to verify the contract on Etherscan
async function verify(contractAddress, args) {
    console.log("Verifying contract ...");
    try {
        // Use Hardhat to initiate the contract verification process
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args
        })

    } catch (error) {
        console.log(error.message);
        // Handle errors, check if the contract is already verified, or log other errors
        if (error.message.toLowerCase().includes("already verified")) {
            console.log("Already verified")
        } else {
            console.log(error);
        }
    }
}

// Execute the main function and log any errors
main().then(() => process.exit(0)).catch((error) => {
    console.error(error);
    process.exit(0);
})