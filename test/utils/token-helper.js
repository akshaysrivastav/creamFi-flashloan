
const BigNumber = require('bignumber.js');

const tokenToDecimal = (amount, decimals) => {
  decimals = parseFloat(decimals);
  amount = parseFloat(amount);
  return amount * Math.pow(10, decimals);
}

const decimalToToken = (amount, decimals) => {
  decimals = parseFloat(decimals);
  amount = parseFloat(amount);
  return amount / Math.pow(10, decimals);
}

const tokenToDecimalBN = (amount, decimals) => {
  amount = new BigNumber(amount);
  decimals = new BigNumber(decimals);
  let ten = new BigNumber(10);
  return amount.times(ten.pow(decimals));  
}

const decimalToTokenBN = (amount, decimals) => {
  amount = new BigNumber(amount);
  decimals = new BigNumber(decimals);
  let ten = new BigNumber(10);
  return amount.div(ten.pow(decimals));
}

module.exports = {
  tokenToDecimal,
  decimalToToken,
  tokenToDecimalBN,
  decimalToTokenBN
};
