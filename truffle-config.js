
const HDWalletProvider = require('@truffle/hdwallet-provider');
require("dotenv").config({
  path: __dirname + '/.env'
});

module.exports = {
  networks: {
    development: {
     host: "127.0.0.1",
     port: 8545,
     network_id: "*",
    },

    kovan: {
      provider: () => new HDWalletProvider(
          process.env.MNEMONIC_OR_KEY,
          `https://kovan.infura.io/v3/${process.env.INFURA_ID}`,
          0, //address_index
          10, // num_addresses
          true // shareNonce
      ),
      network_id: 42, // Kovan's id
      //gas: 7017622, //
      //confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 50, // # of blocks before a deployment times out  (minimum/default: 50)
      // skipDryRun: false // Skip dry run before migrations? (default: false for public nets )
    },

    mainnet: {
      provider: () => new HDWalletProvider(
          process.env.MNEMONIC_OR_KEY,
          `https://mainnet.infura.io/v3/${process.env.INFURA_ID}`,
          0, //address_index
          10, // num_addresses
          true // shareNonce
      ),
      network_id: 1, // mainnet's id
      gas: 8000000, // max gaslimit
      gasPrice: +process.env.MAINNET_GAS_PRICE || 1000*1000*1000, // default 1 gwei
      //confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 50, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: false // Skip dry run before migrations? (default: false for public nets )
    }
  },

  mocha: {
    // timeout: 100000
  },

  compilers: {
    solc: {
      version: "0.5.16",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: true,
         runs: 200
       },
      //  evmVersion: "byzantium"
      }
    }
  },

  plugins: [
    "solidity-coverage",
    "truffle-plugin-verify"
  ],

  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY
  },
}
