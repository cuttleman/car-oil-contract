import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades";

const config: HardhatUserConfig = {
  solidity: "0.8.12",
  networks: {
    bsctestnet: {
      chainId: 97,
      url: "https://data-seed-prebsc-1-s2.binance.org:8545",
      accounts: [
        "d26bd173291675f8f1e479bf933fb6ced9fa2dd79dbc2f8481aad23a0d556ef5",
      ],
    },
  },
};

export default config;
