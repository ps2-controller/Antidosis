const ethers = require('ethers');
require('dotenv').config();




//testnet/mainnet
// const privateKey = process.env.privateKey;


//dev
const privateKey1 = process.env.privateKey1Dev;
const privateKey2 = process.env.privateKey2Dev;


//mainnet
//const defaultProvider = ethers.getDefaultProvider("homestead");

//rinkeby
//const defaultProvider = ethers.getDefaultProvider("rinkeby");


//dev
const url = "http://localhost:8545";
const defaultProvider = new ethers.providers.JsonRpcProvider(url);

const wallet1 = new ethers.Wallet(privateKey1, defaultProvider);
const wallet2 = new ethers.Wallet(privateKey2, defaultProvider);

module.exports = {
    wallet1: wallet1,
    wallet2: wallet2
}
