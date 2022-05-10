const {ethers} = require('hardhat')

module.exports = async function({getNamedAccounts, deployment}){
    const {deployer} = await getNamedAccounts()
    const randomIpfsNftContract = await ethers.getContract('RandomIpfsNFT', deployer)
    const randomIpfsNftTx = await randomIpfsNftContract.requestDoggie()
    const randomIpfsNftTxReceipt = await randomIpfsNftTx.wait(1)
}

module.exports.tags = ["all", "mint"]


//havent deploy this mint script