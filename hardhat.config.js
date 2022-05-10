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
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
};
