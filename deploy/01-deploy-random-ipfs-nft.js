const { network, ethers } = require("hardhat");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;
  const chainId = network.config.chainId;
  let vrfCoordinatorV2Address, subscriptionId;
  const FUND_AMOUNT = "10000000000000000000";
  let tokenUris = [
    "ipfs://QmaVkBn2tKmjbhphU7eyztbvSQU5EXDdqRyXZtRhSGgJGo",
    "ipfs://QmYQC5aGZu2PTH8XzbJrbDnvhj3gVs7ya33H9mqUNvST3d",
    "ipfs://QmZYmH5iDbD6v3U2ixoVAjioSzvWJszDzYdbeCLquGSpVm",
  ];

  if (chainId == 31337) {
    //make a fake chainlink vfr node
    const vrfCoordinatorV2MockContract = await ethers.getContract(
      "VRFCoordinatorV2Mock"
    );
    vrfCoordinatorV2Address = vrfCoordinatorV2MockContract.address;
    const tx = await vrfCoordinatorV2MockContract.createSubscription();
    const txReceipt = await tx.wait(1);
    subscriptionId = txReceipt.events[0].args.subId;
    await vrfCoordinatorV2MockContract.fundSubscription(
      subscriptionId,
      FUND_AMOUNT
    );
  } else {
    //use real one
    vrfCoordinatorV2Address = "0x6168499c0cFfCaCD319c818142124B7A15E857ab";
    subscriptionId = "4012";
  }

  args = [
    vrfCoordinatorV2Address,
    "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
    subscriptionId,
    "500000",
    tokenUris
  ];

  const randomIpfsNftContract = await deploy("RandomIpfsNFT", {
      from:deployer,
      log: true,
      args: args,
      gasPrice: ethers.utils.parseUnits('50', 'gwei'),
  })

  console.log(randomIpfsNftContract.address);
};
