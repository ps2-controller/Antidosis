pragma solidity ^0.5.0;
import "./erc721.sol";

contract erc20DeploymentInterface{
	address tokenToLockAddress;
	uint256 erc20Supply;
	string erc20Name;
	uint erc20Decimals;
}

contract TokenizeCore is ERC721TokenReceiver {

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}
	//state variables
	//TokenToLock[] locked721Tokens;

	//structs
	struct TokenToLock{
		address tokenToLockAddress;
		uint tokenToLockId;
	}

	mapping(address => TokenToLock) ERC20ToToken;
	mapping(bytes32 => address) tokenToERC20;

	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4){
		(address memory _distributionAddress, uint256 memory _erc20Supply,string memory _erc20Name, string memory _erc20Symbol, uint memory _erc20Decimals, address memory _erc20DeploymentAddress, bytes memory _deploymentData) = abi.decode(_data, (address, uint256, string, string, uint, address, bytes));
		require(lock721Token(_operator, _distributionAddress, _tokenId, _erc20Supply, _erc20Name, _erc20Symbol, _erc20Decimals, _erc20DeploymentAddress, _deploymentData), "Error receiving token");
		return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
	}

	function lock721Token internal (
		address _tokenToLockAddress, 
		address _distributionAddress, 
		uint256 _tokenToLockId, 
		uint256 _erc20Supply, 
		string _erc20Name, 
		string _erc20Symbol, 
		uint _erc20Decimals,   
		bytes _deploymentData) 
	{
		TokenToLock _tokenToLock = TokenToLock(_tokenToLockAddress, _tokenToLockId);
		//locked721Tokens.push(_tokenToLock);
		AssetTokenizationContract newAssetTokenizationContract = new AssetTokenizationContract(_tokenToLockAddress, _distributionAddress, _tokenToLockId, _erc20Supply, _erc20Name, _erc20Symbol, _erc20Decimals, _deploymentData);
		ERC20ToToken[_tokenToLock] = address(newAssetTokenizationContract);
		bytes32 memory _tokenToLockHash = abi.encode(keccak256(_tokenToLockAddress, _tokenToLockId));
		tokenToERC20[_tokenToLockHash] = address(newAssetTokenizationContract);
	}


	function getERC20Address(address _tokenToLockAddress, uint _tokenToLockId) public view returns(address){
		bytes32 memory _tokenToLockHash = abi.encode(keccak256(_tokenToLockAddress, _tokenToLockId));
		return tokenToERC20[_tokenToLockHash];
	}

	function unfreezeToken(address _tokenToUnlockAddress, uint _tokenToUnlockId, address _claimant){
		require (msg.sender == tokenToERC20[abi.encode(keccak256(_tokenToUnlockAddress, _tokenToUnlockId))])
		_tokenToUnlockAddress.safeTransferFrom(address(this), _claimant, _tokenToUnlockId);
	}


}
