
const cron = require('node-cron');
const Web3 = require("web3");
const HDWalletProvider = require("@truffle/hdwallet-provider");
require('dotenv').config()

const { listen } = require('./scripts/hunt');
const addresses = require('./scripts/common/addresses');

process.on('uncaughtException', err => {
  console.log('UNCAUGHT EXCEPTION! 💥 Shutting down...');
  console.log(err.name, err.message);
  process.exit(1);
});

const network = process.env.NETWORK || 'kovan';

let provider = new HDWalletProvider(process.env.MNEMONIC_OR_KEY, `https://${network}.infura.io/v3/${process.env.INFURA_ID}`);
const web3 = new Web3(provider);

const interval = 15;

console.log('Script Started...');
console.log(`\nListening every ${interval} seconds...`);

const contractAddresses = addresses[network];

let world = {};    // global object
world.web3 = web3;
world.contractAddresses = contractAddresses;

const start = async () => {
  try {
    world.accounts = await web3.eth.getAccounts();

    world.txIssuerWallet = web3.eth.accounts.privateKeyToAccount(process.env.PRIVATEKEY);
    world.txIssuerWallet.nonce = await web3.eth.getTransactionCount(world.txIssuerWallet.address, 'pending');
    console.log(`\nAccount for Liquidation txn: ${world.txIssuerWallet.address}`);

    listen(world)    // for testing
    // startCron();
  } catch (error) {
    console.error(error);
  }
}
start();

const startCron = () => {
  cron.schedule(`*/${interval} * * * * *`, () => {
    listen(world)
      .catch((error) => {
        console.error(error);
      });
  });
}

process.on('unhandledRejection', err => {
  console.log('UNHANDLED REJECTION! 💥 Shutting down...');
  console.log(err.name, err.message);
  process.exit(1);
});
