//setup - wallet, ethers, data
require('dotenv').config();
const ethers = require('ethers');
const contractAbiData = require ('./data/abis.js');
const wallets = require('./../ethersConfig.js');
const wallet1 = wallets.wallet1;
const wallet2 = wallets.wallet2

//user input setup
const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

//abis
let assetTokenizationContractAbiInstance = contractAbiData.assetTokenizationContractAbi;

//user input
let assetTokenizationContractAddress;
let recipient;
let walletToUse;
let sender;

q();

async function q(){
    await rl.question('Asset Tokenization Contract Address: ', (ans) => {
        assetTokenizationContractAddress = ans;
        q2();
    });
}

async function q2(){
    console.log(`Wallet 1 Address: ${wallet1.signingKey.address} \n Wallet 2 Address: ${wallet2.signingKey.address}`);
    await rl.question('Enter the address of the sending wallet:', (ans) => {
        sender = ans;
        if(ans == wallet1.signingKey.address){
            walletToUse = wallet1;
            q3();
        }else{
            walletToUse = wallet2;
            q3();
        }
    });
}

async function q3(){
    await rl.question('Recipient address: ', (ans) => {
        recipient = ans;
        q4();
    });
}

async function q4(){
    await rl.question('Amount to send:', (ans) => {
        transferTokens(assetTokenizationContractAddress, recipient, ans);
    });
}

async function transferTokens(assetTokenizationContractAddress, recipientAddress, amount){
    let assetTokenizationContractInstance = new ethers.Contract(assetTokenizationContractAddress, assetTokenizationContractAbiInstance, walletToUse);
    await assetTokenizationContractInstance.transferFrom(sender, recipient, amount);
    await assetTokenizationContractInstance.once("testTransfer", (res) => {
        console.log(res.toNumber());
        process.exit();
    });
    // let balance = await assetTokenizationContractInstance.balances[wallet1.signingKey.address];
    // await console.log("your balance is " + balance);
}