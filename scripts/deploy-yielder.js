/**
 * @dev Interactive script to deploy a Yielder contract
 */

const addresses = require('./common/addresses');
const { getGasPrice } = require('./common/eth-gas');

const Yielder = artifacts.require("Yielder");

module.exports = async (callback) => {
  try {
    let world = {};
    world.web3 = web3;

    let network = await web3.eth.net.getNetworkType();
    network = network === 'main' ? 'mainnet' : network;

    const contractAddresses = addresses[network];

    let accounts = await web3.eth.getAccounts();
    console.log(`\nUsing account: ${accounts}`);

    let gasPrice = await getGasPrice(world);
    if (network === 'mainnet' && process.env.MAINNET_GAS_PRICE) {
      gasPrice = process.env.MAINNET_GAS_PRICE;
    }

    let txParams = {
      gasPrice
    }

    console.log(`\nDeploying Yielder Contract...`);
    let YielderC = await Yielder.new(contractAddresses.aave.LendingPoolAddressesProvider, txParams);

    console.log(`\nYielder deployed at: ${YielderC.address}\n`);

    callback();
  } catch (err) {
    callback(err);
  }
};
