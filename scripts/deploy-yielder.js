/**
 * @dev Interactive script to deploy a Yielder contract
 */

const addresses = require('./common/addresses');

const Yielder = artifacts.require("Yielder");
const IERC20 = artifacts.require("IERC20");

module.exports = async (callback) => {
  try {
    let network = await web3.eth.net.getNetworkType();
    network = network === 'main' ? 'mainnet' : network;

    const contractAddresses = addresses[network];

    let accounts = await web3.eth.getAccounts();
    console.log(`Using account: ${accounts}`);

    console.log(`Deploying Yielder Contract...`);
    let YielderC = await Yielder.new(contractAddresses.aave.LendingPoolAddressesProvider);

    console.log(`\nLiquidator deployed at: ${YielderC.address}\n`);

    // const dai = '0x8f746eC7ed5Cc265b90e7AF0f5B07b4406C9dDA8';
    // const user = '0x6c24d5422cDFea5d1e844FC1634f0c30Af471DEe';

    // const token = await IERC20.at(dai);
    // let iniAllowance = await token.allowance(user, YielderC.address);
    // console.log(parseFloat(iniAllowance));

    // let amount = 10 ** 30;
    // amount = amount.toLocaleString('fullwide', {useGrouping: false});

    // let tx = await token.approve(YielderC.address, amount);
    // let fiAllowance = await token.allowance(user, YielderC.address);
    // console.log(parseFloat(fiAllowance));

    callback();
  } catch (err) {
    callback(err);
  }
};
