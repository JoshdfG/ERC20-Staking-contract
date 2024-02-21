import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config({ path: ".env" });
/** @type import('hardhat/config').HardhatUserConfig */

//URL from alchemy
const URL = process.env.URL;

//private of the wallet
const KEY = process.env.PRIVATE_KEY;

module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: URL,
      accounts: [`0x${KEY}`],
    },
  },
};
