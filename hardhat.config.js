require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");

const { testnetPrivateKey } = require("./config.secret.js");

module.exports = {
  solidity: "0.8.18",
  defaultNetwork: "hardhat",
  paths: {
    sources: "./src/contracts", // Ensure this path is correct
  },
  networks: {
    hardhat: {},
    local: {
      url: "http://0.0.0.0:8547",
    },
    sepolia: {
      url: "https://sepolia.gateway.tenderly.co",
      chainId: 11155111,
      accounts: [testnetPrivateKey],
    },
  },
};
