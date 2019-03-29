const ethers = require('ethers');
require('dotenv').config();

//testnet/mainnet
// const privateKey = process.env.privateKey;


//dev
const privateKey = process.env.privateKeyDev;


//mainnet
//const defaultProvider = ethers.getDefaultProvider("homestead");

//rinkeby
//const defaultProvider = ethers.getDefaultProvider("rinkeby");


//dev
const url = "http://localhost:8545";
const defaultProvider = new ethers.providers.JsonRpcProvider(url);

const wallet = new ethers.Wallet(privateKey, defaultProvider);
module.exports = {
    wallet: wallet
}