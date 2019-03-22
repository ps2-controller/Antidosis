
//this is just an idea under consideration to make an asset-tokenization standard
//and then allow for custom implementations of the asset-tokenization contract
//mintable from tokenize-core. This will most likely be a v2 type of thing.
//still thinking it through




//pragma solidity ^0.5.0;
//import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
//import "./asset-tokenization-contract.sol";
//import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

//contract AssetTokenizationDeployer is AssetTokenizationContract, Ownable {

//	function createAssetTokenizationContract(
//		address _tokenToLockAddress, 
//		address _distributionAddress, 
//		address _paymentAddress, 
//		address _taxAddress, 
//		uint _tokenToLockId, 
//		uint _erc20Supply, 
//		string _erc20Name, 
//		string _erc20Symbol, 
//		uint _erc20Decimals, 
//		uint _minimumShares, 
//		bytes _deploymentData)
//	{
//		AssetTokenizationContract newAssetTokenizationContract = new AssetTokenizationContract(_tokenToLockAddress, _distributionAddress, _paymentAddress, _taxAddress, _tokenToLockId, _erc20Supply, _erc20Name, _erc20Symbol, _erc20Decimals, _minimumShares, _deploymentData);
//	}
//}