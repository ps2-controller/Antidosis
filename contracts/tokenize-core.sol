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
	

	//state variables
	TokenToLock[] locked721Tokens;

	//structs
	struct TokenToLock{
		address tokenToLockAddress;
		uint tokenToLockId;
	}

	mapping(TokenToLock => address) tokenToERC20;

	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4){
		(address memory _distributionAddress, uint256 memory _erc20Supply,string memory _erc20Name, string memory _erc20Symbol, uint memory _erc20Decimals, address memory _erc20DeploymentAddress, uint memory _value, uint memory _duration) = abi.decode(_data, (address, uint256, string, string, uint, address, uint, uint));
		require(lock721Token(_operator, _distributionAddress, _tokenId, _erc20Supply, _erc20Name, _erc20Symbol, _erc20Decimals, _erc20DeploymentAddress, _value, _duration), "Error receiving token");
		return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
	}

	function lock721Token public (
		address _tokenToLockAddress, 
		address _distributionAddress, 
		uint256 _tokenToLockId, 
		uint256 _erc20Supply, string _erc20Name, 
		string _erc20Symbol, 
		uint _erc20Decimals, 
		address _erc20DeploymentAddress, 
		uint _value, 
		uint _duration) 
	{
		TokenToLock _tokenToLock = TokenToLock(_tokenToLockAddress, _tokenToLockId);
		locked721Tokens.push(_tokenToLock);
		tokenToERC20[_tokenToLock] = _erc20DeploymentAddress;
		freezeErc721Token(_tokenToLockAddress, _tokenToLockId);
		mintErc20s(_tokenToLockAddress, _erc20Supply, _erc20Name, _erc20Symbol _erc20Decimals, _erc20DeploymentAddress, _value, _duration);
	}

	function mintErc20s internal (
		address _tokenToLockAddress,  
		uint256 _erc20Supply, 
		string _erc20Name, 
		string _erc20Symbol, 
		uint _erc20Decimals, 
		address _erc20DeploymentAddress, 
		uint _value, 
		uint _duration)
	{
		AssetTokenizationContract newAssetTokenizationContract = new AssetTokenizationContract(_tokenToLockAddress, _erc20Supply, _erc20Name, _erc20Symbol, _erc20Decimals, _erc20DeploymentAddress, _value, _duration);
	}






	function freezeErc721Token(address _tokenToLockAddress, uint256 _tokenToLockId){

	}

}
