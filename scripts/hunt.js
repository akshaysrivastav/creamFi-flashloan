
const { getGasPrice } = require('./common/eth-gas');

const iBzxJson = require(`../build/contracts/IBZx.json`);
const LiquidatorJson = require(`../build/contracts/Liquidator.json`);

const listen = async (world) => {
  try {
    const web3 = world.web3;
    const Bzx = new web3.eth.Contract(iBzxJson.abi, world.contractAddresses.Bzx);

    let activeLoans = await Bzx.methods.getActiveLoans(0, 100, true).call();
    activeLoans.forEach(async (loan) => {
      if (loan.loanToken == '0x8f746eC7ed5Cc265b90e7AF0f5B07b4406C9dDA8') {
        // console.table(loan.maxLiquidatable);
        // console.table(loan);
      }
      // console.table(loan);
      processLiquidatableLoan(world, loan);
    })
    console.log(`\nCount - ${activeLoans.length}`);

  } catch (error) {
    throw error;
  }
}

// process the loan and create txn params
const processLiquidatableLoan = (world, loan) => {
  if (parseFloat(loan.maxLiquidatable) === 0) { return; }

  const flashLoanPlatformSwitch = getSwitchForFlashLoan(world, loan.loanToken);

  const txParams = {};

  if (flashLoanPlatformSwitch.length === 1) {
    txParams.flashLoanPlatform = flashLoanPlatformSwitch[0];
  } else if (flashLoanPlatformSwitch.length === 2) {
    txParams.flashLoanPlatform = process.env.FLASHLOAN_PREFERENCE
  } else {
    throw new Error(`Unhandled Platforms`);
  }

  createLiquidationTxn(world, loan, txParams);
}

const createLiquidationTxn = async (world, loan, txParams) => {
  try {

    const Liquidator = new world.web3.eth.Contract(LiquidatorJson.abi, world.contractAddresses.Liquidator);
    const collateralReceiver = process.env.COLLATERAL_RECEIVER || world.accounts[0];

    let data;
    if (txParams.flashLoanPlatform === 1) {
      data = Liquidator.methods['startWithDyDx'](world.contractAddresses.dydx.solo, loan.loanToken, loan.collateralToken,
        world.contractAddresses.Bzx, loan.loanId, collateralReceiver, loan.maxLiquidatable)
        .encodeABI();
    } else {
      const iTokenAddress = getITokenAddressFromLoanToken(world, loan.loanToken);

      data = Liquidator.methods['startWithBzx'](iTokenAddress, loan.loanToken, loan.collateralToken,
        world.contractAddresses.Bzx, loan.loanId, collateralReceiver, loan.maxLiquidatable)
        .encodeABI();
    }

    let gasPrice = await getGasPrice(world);

    let tx = {
      nonce: world.web3.utils.toHex(world.txIssuerWallet.nonce),
      gasPrice: gasPrice,
      gasLimit: world.web3.utils.toHex(6000000),
      to: world.contractAddresses.Liquidator,
      value: 0,
      data: data
    };
    world.txIssuerWallet.nonce++;

    let signedTx = await world.web3.eth.accounts.signTransaction(tx, world.txIssuerWallet.privateKey);
    sendSignedTx(world, signedTx);

  } catch (error) {
    throw error;
  }
}

const sendSignedTx = (world, signedTx) => {
  world.web3.eth.sendSignedTransaction(signedTx.rawTransaction, (error, transactionHash) => {
    if (error) {
      console.error('error');
      console.error(error);
    }
    else {
      console.log(transactionHash)
    }
  });
}

const getSwitchForFlashLoan = (world, loanTokenAddress) => {
  let platformSwitch = [];   // Default

  // For dYdX - 1
  const dydxFlashLoanTokens = world.contractAddresses.dydx.flashLoanTokens;
  dydxFlashLoanTokens.forEach(dydxFlashLoanToken => {
    if (loanTokenAddress.toLowerCase() === dydxFlashLoanToken.toLowerCase()) {
      platformSwitch.push(1);
    }
  });

  // For BZX - 2
  const bzxTokens = world.contractAddresses.iTokenList;
  bzxTokens.forEach(bzxToken => {
    if (loanTokenAddress.toLowerCase() === bzxToken[2].toLowerCase()) {
      platformSwitch.push(2);
    }
  });

  return platformSwitch;
}

const getITokenAddressFromLoanToken = (world, loanTokenAddr) => {
  const bzxTokens = world.contractAddresses.iTokenList;
  for (let i = 0; i < bzxTokens.length; i++) {
    let bzxToken = bzxTokens[i];

    if (loanTokenAddr.toLowerCase() === bzxToken[2].toLowerCase()) {
      return bzxToken[1];
    }
  }
}

module.exports = {
  listen: listen
};
