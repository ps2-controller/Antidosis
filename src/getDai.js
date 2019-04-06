//setup - wallet, ethers, data
const ethers = require('ethers');
const contractAbiData = require ('./data/abis.js');
const wallets = require('./../ethersConfig.js');
const wallet1 = wallets.wallet1;
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

//user input
let addressToReceive;
let amount;

q();

async function q(){
    await rl.question('Address to receive Dai:', (ans) => {
        if(ans == 0){
            addressToReceive = wallet1.signingKey.address;
        } else{
            addressToReceive = ans;
        }
        q2();
    });
}

async function q2(){
    await rl.question('Amount:', (ans) => {
        amount = ans;
        faucet(addressToReceive, amount);
    });
}

async function faucet(address, amount){
    let daiContract = new ethers.Contract(daiContractAddress, daiContractAbi, wallet1);
    await daiContract.createTokens(address, amount);
    let newBalance = await daiContract.balanceOf(address);
    await console.log("The new Dai balance of account " + address + " is " + newBalance);
    process.exit();
}