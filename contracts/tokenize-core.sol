pragma solidity ^0.5.0;
import 'openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol';


contract TokenizeCore is ERC721TokenReceiver {

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}
	//state variables
	TokenToLock[] locked721Tokens;

	//structs
	struct TokenToLock{
		address tokenToLockAddress;
		uint tokenToLockId;
	}

	mapping(address => TokenToLock) public ERC20ToToken;
	mapping(bytes32 => address) tokenToERC20;

	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4){
		(address memory _distributionAddress, 
			address memory _paymentAddress,
			address memory _taxAddress, 
			uint256 memory _erc20Supply,
			string memory _erc20Name, 
			string memory _erc20Symbol, 
			uint memory _erc20Decimals,
			uint memory _minimumShares, 
			bytes memory _deploymentData) = abi.decode(_data, (
				address, 
				address,
				address, 
				uint256, 
				string, 
				string, 
				uint, 
				uint,
				bytes));
		require(lock721Token(_operator, _distributionAddress, _paymentAddress, _taxAddress _tokenId, _erc20Supply, _erc20Name, _erc20Symbol, _erc20Decimals, _erc20DeploymentAddress, _minimumShares, _deploymentData), "Error receiving token");
		return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
	}

	function lock721Token internal (
		address _tokenToLockAddress, 
		address _distributionAddress, 
		address _paymentAddress,
		address _taxAddress,
		uint256 _tokenToLockId, 
		uint256 _erc20Supply, 
		string _erc20Name, 
		string _erc20Symbol, 
		uint _erc20Decimals,
		uint _minimumShares,   
		bytes _deploymentData) 
	{
		TokenToLock _tokenToLock = TokenToLock(_tokenToLockAddress, _tokenToLockId);
		locked721Tokens.push(_tokenToLock); //need to think about if this will cause space issues
		AssetTokenizationContract newAssetTokenizationContract = new AssetTokenizationContract(_tokenToLockAddress, _distributionAddress, _paymentAddress, _taxAddress, _tokenToLockId, _erc20Supply, _erc20Name, _erc20Symbol, _erc20Decimals, _minimumShares, _deploymentData);
		ERC20ToToken[address(newAssetTokenizationContract)] = _tokenToLock;

		bytes32 memory _tokenToLockHash = abi.encode(keccak256(_tokenToLockAddress, _tokenToLockId));
		tokenToERC20[_tokenToLockHash] = address(newAssetTokenizationContract);
	}


	function getERC20Address(address _tokenToLockAddress, uint _tokenToLockId) public view returns(address){
		bytes32 memory _tokenToLockHash = abi.encode(keccak256(_tokenToLockAddress, _tokenToLockId));
		return tokenToERC20[_tokenToLockHash];
	}


	function unlockToken(address _tokenToUnlockAddress, uint _tokenToUnlockId, address _claimant){
		require (msg.sender == tokenToERC20[abi.encode(keccak256(_tokenToUnlockAddress, _tokenToUnlockId))])
		_tokenToUnlockAddress.safeTransferFrom(address(this), _claimant, _tokenToUnlockId);
	}

}
