require('dotenv').config();
const ethers = require('ethers');
const contractAbiData = require ('./data/abis.js');
const wallets = require('./../ethersConfig.js');
const wallet1 = wallets.wallet1;

const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
});

q();


async function q(){
    await rl.question('AssetTokenizationContract Address:', (ans) => {
        q2(ans);
    });
}

async function q2(ans){
    await rl.question('Address to Check:', (ans1) => {
        if(ans1 == 0){
            addressToCheck = wallet1.signingKey.address;
            check(ans, wallet1.signingKey.address);
        } else{
            check(ans, ans1);
        }
    });
}

async function check(assetTokenizationContractAddress, addressToCheck){
    assetTokenizationContract = new ethers.Contract(assetTokenizationContractAddress, contractAbiData.assetTokenizationContractAbi, wallet1);
    let harbergerSet = await assetTokenizationContract.harbergerSetByUser(addressToCheck);
    await console.log("User value: " + harbergerSet[0].toNumber() + "\nUser duration: " + harbergerSet[1].toNumber() + "\nUser start time: " + harbergerSet[2].toNumber());
    process.exit();
}