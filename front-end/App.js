//imports
require('dotenv').config();
const ethers = require('ethers');
const provider = ethers.getDefaultProvider(network="rinkeby");
const contractAddressData = require('./data/deployedContractAddresses.js');
const contractAbiData = require ('./data/abis.js');
const wallets = require('./config/ethersConfig.js');
const wallet = wallets.wallet;

let dummy721AddressInstance = contractAddressData.dummy721Address;
let dummy721AbiInstance = contractAbiData.dummy721Abi;

let dummy721ContractWallet = new ethers.Contract(dummy721AddressInstance, dummy721AbiInstance, wallet);   
let tokenizeCoreAddressInstance = contractAddressData.tokenizeCoreAddress;
let tokenizeCoreAbiInstance = contractAbiData.tokenizeCoreAbi;

//dev
const addressesToUse = ['0x289eF7Fbb566463197bDa8Dc3D22CF7cE407c44A', '0xEd8915aB3ACcB024861728409A214CE6d09ABd19'];
let erc20Supply = 100;
let erc20Name = 'lolol';
let erc20Symbol = 'LOL';
let erc20Decimals = 18;
let minimumShares = 1;
let taxRate = 1;

mintAndLock();

async function mintAndLock(){
    try{
        await dummy721ContractWallet.functions.mintUniqueTokenTo(wallet.signingKey.address, {gasLimit: 100000});
        let tokenId;
        await dummy721ContractWallet.once("minted", async (res) => {
            let tokenId = await res.toNumber();
            await setTimeout(async (tokenId, addressesToUse, erc20Supply, erc20Name, erc20Symbol, erc20Decimals, minimumShares, taxRate) => {
                let _data = ethers.utils.defaultAbiCoder.encode(
                    [
                        'address[2] memory', 'uint256', 'string memory', 'string memory', 'uint8', 'uint256', 'uint256'
                    ], 
                    [
                        addressesToUse, erc20Supply, erc20Name, erc20Symbol, erc20Decimals, minimumShares, taxRate
                    ]
                );
            
                try{
                    await dummy721ContractWallet['safeTransferFrom(address,address,uint256,bytes)'](wallet.signingKey.address, tokenizeCoreAddressInstance, tokenId, _data, {gasLimit: 5000000});
                    let tokenizeCoreContract = new ethers.Contract(tokenizeCoreAddressInstance, tokenizeCoreAbiInstance, wallet);
                    await tokenizeCoreContract.once("receivedToken", (res) => {
                        console.log(res);
                    });
                    await tokenizeCoreContract.once("lockingToken", (res) => {
                        console.log(res);
                    });
                    await tokenizeCoreContract.once("newAssetTokenizationContractCreated", (res) => {
                        console.log(res);
                        process.exit();
                    });
                } catch(err){
                    console.log(err);
                }
            }, 5000, tokenId, addressesToUse, erc20Supply, erc20Name, erc20Symbol, erc20Decimals, minimumShares, taxRate);
        });

    } catch(err){
        console.log(err);
    }
}









// let deployementCoreExample = new ethers.Contract(contractAddressData.deploymentCoreExampleAddress, contractAbiData.deploymentCoreExampleAbi, wallet);
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