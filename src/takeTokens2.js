//setup - wallet, ethers, data
const ethers = require('ethers');
const contractAbiData = require ('./data/abis.js');
const wallets = require('./../ethersConfig.js');
const wallet2 = wallets.wallet2;

//user input setup
const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
});

//abis
let assetTokenizationContractAbiInstance = contractAbiData.assetTokenizationContractAbi;

//user input
let assetTokenizationContractAddress;
let transferAmount;

q();

async function q(){
    await rl.question('AssetTokenizationContract Address:', (ans) => {
        assetTokenizationContractAddress = ans;
        q2();
    });
}

async function q2(){
    await rl.question('Amount:', (ans) => {
        transferAmount = ans;
        takeTokens(assetTokenizationContractAddress, transferAmount);
    });
}

async function takeTokens(assetTokenizationContractAddress, amount){
    let assetTokenizationContractInstance = new ethers.Contract(assetTokenizationContractAddress, assetTokenizationContractAbiInstance, wallet2);
    await assetTokenizationContractInstance.transferFrom(assetTokenizationContractAddress, wallet2.signingKey.address, amount);
    await assetTokenizationContractInstance.once("testTransfer", (res) => {
        console.log(res.toNumber());
        process.exit();
    });
    // let balance = await assetTokenizationContractInstance.balances[wallet2.signingKey.address];
    // await console.log("your balance is " + balance);
};