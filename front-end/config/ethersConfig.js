const ethers = require('ethers');
require('dotenv').config();


const privateKey1 = process.env.privateKey1;
const privateKey2 = process.env.privateKey2;

//const apiAccessToken = '';
const defaultProvider = ethers.getDefaultProvider("rinkeby");

const wallet1 = new ethers.Wallet(privateKey1, defaultProvider);
const wallet2 = new ethers.Wallet(privateKey2, defaultProvider);
module.exports = {
    wallet1: wallet1,
    wallet2: wallet2
}