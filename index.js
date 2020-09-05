
const { ethers } = require("ethers");
const HDWalletProvider = require("@truffle/hdwallet-provider");
require('dotenv').config()

// const { listen } = require('./scripts/yield');
const addresses = require('./scripts/common/addresses');

process.on('uncaughtException', err => {
  console.log('UNCAUGHT EXCEPTION! 💥 Shutting down...');
  console.log(err.name, err.message);
  process.exit(1);
});

const network = process.env.NETWORK || 'kovan';

const web3Provider = new HDWalletProvider(process.env.PRIVATEKEY, `https://${network}.infura.io/v3/${process.env.INFURA_ID}`);
const provider = new ethers.providers.Web3Provider(web3Provider);

console.log('\nScript Started...');

const contractAddresses = addresses[network];

let world = {};    // global object
world.provider = provider;
world.contractAddresses = contractAddresses;

const start = async () => {
  try {

    let accountAddr = await provider.getSigner().getAddress();
    let nonce = await provider.getTransactionCount(accountAddr);
    world.account = {
      address: accountAddr,
      nonce: nonce
    }

    console.log(`\nUsing Account: ${accountAddr}`);

    listen(world)    // for testing
    // startCron();
  } catch (error) {
    console.error(error);
  }
}
start();

process.on('unhandledRejection', err => {
  console.log('UNHANDLED REJECTION! 💥 Shutting down...');
  console.log(err.name, err.message);
  process.exit(1);
});
