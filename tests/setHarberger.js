//setup - wallet, ethers, data
require('dotenv').config();
const ethers = require('ethers');
const contractAbiData = require ('./data/abis.js');
const wallets = require('./config/ethersConfig.js');
const wallet1 = wallets.wallet1;

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
let userValue;
let userDuration;

q();

async function q(){
    
    await rl.question('AssetTokenizationContract Address:', (ans) => {
        assetTokenizationContractAddress = ans;
        q2();
    });
}

async function q2(){
    await rl.question('Harberger Value:', (ans) => {
        userValue = ans;
        q3();
    });
}

async function q3(){
    await rl.question('Harberger Duration:', (ans) => {
        userDuration = ans;
        rl.close();
        setHarbergerValues(assetTokenizationContractAddress, userValue, userDuration);
    });
}

async function setHarbergerValues(assetTokenizationContractAddress, userValue, userDuration){
    let assetTokenizationContractInstance = new ethers.Contract(assetTokenizationContractAddress, assetTokenizationContractAbiInstance, wallet1);
    await assetTokenizationContractInstance.setHarberger(userValue, userDuration);
    let harbergerSet = await assetTokenizationContractInstance.harbergerSetByUser(wallet1.signingKey.address);
    await console.log("Harberger values set");
};

