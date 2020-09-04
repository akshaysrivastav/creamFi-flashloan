/**
 * @dev Interactive script to deploy a Liquidator contract
 */

const Liquidator = artifacts.require("Liquidator");
const IERC20 = artifacts.require("IERC20");

module.exports = async (callback) => {
  try {
    console.log(`Deploying Liquidator Contract...`);
    let LiquidatorC = await Liquidator.new();

    console.log(`\nLiquidator deployed at: ${LiquidatorC.address}\n`);

    // const dai = '0x8f746eC7ed5Cc265b90e7AF0f5B07b4406C9dDA8';
    // const user = '0x6c24d5422cDFea5d1e844FC1634f0c30Af471DEe';

    // const token = await IERC20.at(dai);
    // let iniAllowance = await token.allowance(user, LiquidatorC.address);
    // console.log(parseFloat(iniAllowance));

    // let amount = 10 ** 30;
    // amount = amount.toLocaleString('fullwide', {useGrouping: false});

    // let tx = await token.approve(LiquidatorC.address, amount);
    // let fiAllowance = await token.allowance(user, LiquidatorC.address);
    // console.log(parseFloat(fiAllowance));

    callback();
  } catch (err) {
    callback(err);
  }
};
