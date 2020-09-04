const axios = require('axios').default;

const getGasPrice = async (world) => {
  try {
    const chainId = await world.web3.eth.getChainId();
    if (chainId !== 1) {
      return world.web3.utils.toWei('1', 'gwei');
    }

    let res = await axios.get('https://ethgasstation.info/json/ethgasAPI.json');
    let data = res.data;
    let proposedGP = (parseFloat(data['fast']) + parseFloat(data['average'])) / (10 * 2);   // convert to gWei then average
    proposedGP = proposedGP.toFixed();
    return world.web3.utils.toWei(proposedGP, 'gwei');
  } catch (error) {
    throw(error);
  }
}

module.exports = {
  getGasPrice
}
