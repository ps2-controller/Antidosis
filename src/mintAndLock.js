const ethers = require('ethers');
const wallets = require('./../ethersConfig.js');

//rinkeby provider
//const provider = ethers.getDefaultProvider(network="rinkeby");
const contractAddressData = require('./data/deployedContractAddresses.js');
const contractAbiData = require ('./data/abis.js');

// console.log(wallets);
const wallet1 = wallets.wallet1;

let dummy721AddressInstance = contractAddressData.dummy721Address;
let dummy721AbiInstance = contractAbiData.dummy721Abi;

let dummy721ContractWallet = new ethers.Contract(dummy721AddressInstance, dummy721AbiInstance, wallet1);   
let tokenizeCoreAddressInstance = contractAddressData.tokenizeCoreAddress;
let tokenizeCoreAbiInstance = contractAbiData.tokenizeCoreAbi;

//dev
const addressesToUse = ['0x289eF7Fbb566463197bDa8Dc3D22CF7cE407c44A', '0xEd8915aB3ACcB024861728409A214CE6d09ABd19'];
let erc20Supply = ethers.utils.bigNumberify("1000000000000000000000000");
let erc20Name = 'lolol';
let erc20Symbol = 'LOL';
let erc20Decimals = 18;
let minimumShares = 1;
let taxRate = 1;

mintAndLock();

async function mintAndLock(){
    try{
        await dummy721ContractWallet.functions.mintUniqueTokenTo(wallet1.signingKey.address, {gasLimit: 100000});
        await dummy721ContractWallet.once("minted", async (res) => {
            let tokenId = res.toNumber();
            await setTimeout(async (tokenId, addressesToUse, erc20Supply, erc20Name, erc20Symbol, erc20Decimals, minimumShares, taxRate) => {
                let _data = ethers.utils.defaultAbiCoder.encode(
                    [
                        'address[2] memory', 'uint256', 'string memory', 'string memory', 'uint8', 'uint256', 'uint256'
                    ], 
                    [
                        addressesToUse, erc20Supply, erc20Name, erc20Symbol, erc20Decimals, minShares, taxRate
                    ]
                );
                try{
                    await dummy721ContractWallet['safeTransferFrom(address,address,uint256,bytes)'](wallet1.signingKey.address, tokenizeCoreAddressInstance, tokenId, _data, {gasLimit: 5000000});
                    let tokenizeCoreContract = new ethers.Contract(tokenizeCoreAddressInstance, tokenizeCoreAbiInstance, wallet1);
                    await tokenizeCoreContract.once("receivedToken", (res) => {
                        console.log("Token ID: " + res.toNumber());
                    });
                    await tokenizeCoreContract.once("lockingToken", (res) => {
                        console.log(res);
                    });
                    await tokenizeCoreContract.once("newAssetTokenizationContractCreated", (res) => {
                        console.log("Asset Tokenization Contract Address: " + res);
                        process.exit();
                        
                    });
                } catch(err){
                    console.log(err);
                    return err;
                }
            }, 2000, tokenId, addressesToUse, erc20Supply, erc20Name, erc20Symbol, erc20Decimals, minimumShares, taxRate);
        });

    } catch(err){
        console.log(err);
    }
}





