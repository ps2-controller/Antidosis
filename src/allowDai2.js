//setup - wallet, ethers, data
require('dotenv').config();
const ethers = require('ethers');
const contractAbiData = require ('./data/abis.js');
const wallets = require('./../ethersConfig.js');
const wallet2 = wallets.wallet2;
const contractAddressData = require('./data/deployedContractAddresses.js');

//user input setup
const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

//contract addresses
let daiContractAddress = contractAddressData.daiContractAddress;

//abis
let daiContractAbi = contractAbiData.daiContractAbi;
let assetTokenizationContractAbi = contractAbiData.assetTokenizationContractAbi;

//user input
let assetTokenizationContractAddress;
let amountToAllow;

q();

async function q(){
    
    await rl.question('Asset Tokenization Contract Address:', (ans) => {

        assetTokenizationContractAddress = ans;

        q2();
    });
}

async function q2(){
    let daiContract = new ethers.Contract(daiContractAddress, daiContractAbi, wallet2);
    await rl.question('Amount to allow:', async (ans) => {
        if (ans == 0){
            amountToAllow = daiContract.balanceOf(wallet2.signingKey.address);
        } else{
            amountToAllow = ans; 
        }
        await daiContract.approve(assetTokenizationContractAddress, amountToAllow);
        console.log(await daiContract.allowance(wallet2.signingKey.address, assetTokenizationContractAddress));
        process.exit();
    });
}