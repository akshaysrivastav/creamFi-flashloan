const axios = require('axios').default;

const getGasPrice = async (world) => {
  try {
    const network = await world.web3.eth.net.getNetworkType();
    if (network !== 'main') {
      return world.web3.utils.toWei('10', 'gwei');
    }

    let res = await axios.get('https://ethgasstation.info/json/ethgasAPI.json');
    let data = res.data;
    let proposedGP = parseFloat(data['fast']) / 10;   // convert to gWei
    proposedGP = proposedGP.toFixed();
    return world.web3.utils.toWei(proposedGP, 'gwei');
  } catch (error) {
    throw(error);
  }
}

module.exports = {
  getGasPrice
}
