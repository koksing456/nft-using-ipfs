require("hardhat-deploy");
require("dotenv").config();
require("@nomiclabs/hardhat-waffle")

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.7",
  network: {
    hardhat: {
      chainId: 31337,
    },
    rinkeby: {
      chainId: 4,
      url: process.env.RINKEBY_PRC_URL,
      
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};
