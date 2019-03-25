//imports
require('dotenv').config();
const ethers = require('ethers');
const provider = ethers.getDefaultProvider(network="rinkeby");
const contractAddressData = require('./data/deployedContractAddresses.js');
const contractAbiData = require ('./data/abis.js');
const wallets = require('./config/ethersConfig.js');
const wallet1 = wallets.wallet1;
const wallet2 = wallets.wallet2;

let dummy721AddressInstance = contractAddressData.dummy721Address;
let dummy721AbiInstance = contractAbiData.dummy721Abi;

let dummy721ContractWallet1 = new ethers.Contract(dummy721AddressInstance, dummy721AbiInstance, wallet1);   
let dummy721ContractWallet2 = new ethers.Contract(dummy721AddressInstance, dummy721AbiInstance, wallet2);
let tokenizeCoreAddressInstance = contractAddressData.tokenizeCoreAddress;
let tokenizeCoreAbiInstance = contractAbiData.tokenizeCoreAbi;
let tokenizeCoreContract = new ethers.Contract(tokenizeCoreAddressInstance, tokenizeCoreAbiInstance, wallet2);




//dummy variables
// let addressesToUse = [contractAddressData.deploymentCoreExampleAddress, '0x1D329f63dbd2DfCa686a87c90D4Fe4b802F3E34D', '0xEd8915aB3ACcB024861728409A214CE6d09ABd19'];

//dev
let addressesToUse = [contractAddressData.deploymentCoreExampleAddress, '0x289eF7Fbb566463197bDa8Dc3D22CF7cE407c44A', '0xEd8915aB3ACcB024861728409A214CE6d09ABd19'];

console.log(addressesToUse);
let erc20Supply = 100;
//let erc20Supply = 100000000000000000000;
let erc20Name = 'lolol';
let erc20Symbol = 'LOL';
let erc20Decimals = 18;
let minimumShares = 1;
//let minimumShares = 1000000000000000000;
let taxRate = 1;
let deploymentData = ["0x00","0xaa", "0xff"];
let tokenId = 21;



tokenDeploy (tokenId, addressesToUse, erc20Supply, erc20Name, erc20Symbol, erc20Decimals, minimumShares, taxRate, deploymentData);

// transferERC721Token();


async function transferERC721Token(){
    try{
        let b = await dummy721ContractWallet1.functions.mintUniqueTokenTo(wallet1.signingKey.address, tokenId, {gasLimit: 100000});
        console.log(b);
        tokenId++;
    } catch(err){
        console.log(err);
    }
}

async function tokenDeploy (tokenId, addressesToUse, erc20Supply, erc20Name, erc20Symbol, erc20Decimals, minimumShares, taxRate, deploymentData){
    let _data = ethers.utils.defaultAbiCoder.encode(
        [
            'address[]', 'uint256', 'string memory', 'string memory', 'uint8', 'uint256', 'uint256', 'bytes'
        ], 
        [
            addressesToUse, erc20Supply, erc20Name, erc20Symbol, erc20Decimals, minimumShares, taxRate, deploymentData
        ]
    );

    try{
        let c = await dummy721ContractWallet1["safeTransferFrom(address,address,uint256,bytes)"](wallet1.signingKey.address, tokenizeCoreAddressInstance, tokenId, _data, {gasLimit: 1000000});
        console.log(c);
    } catch(err){
        console.log(err);
    }
}



// let deployementCoreExample = new ethers.Contract(contractAddressData.deploymentCoreExampleAddress, contractAbiData.deploymentCoreExampleAbi, wallet1);
// let recipientAddress1 = '0x73Fe843A2Ef562e239ca889794B18C0013e8b47F';
// let recipientAddress2 = '0xB3aE76e84aa83050a1A7434347B823E85290aDfB';
// let recipientAddress3 = '0x4398Ea594C750347B0b6bc41EaEFfc169e52cc67';
// addRecipientsExample(recipientAddress1, recipientAddress2, recipientAddress3);

//TODO add example addresses to deploymentcore by calling addRecipients on it from the address that made it
// async function addRecipientsExample(address1, address2, address3){
//     let arrayToAdd = [];
//     arrayToAdd.push(address1);
//     arrayToAdd.push(address2);
//     arrayToAdd.push(address3);
//     console.log(arrayToAdd);
//     try{
//     let added = await deployementCoreExample.addRecipients(arrayToAdd, {gasLimit: 1000000})
//     console.log(added);
//     } catch (err) {
//         console.log(err);
//     }
// }