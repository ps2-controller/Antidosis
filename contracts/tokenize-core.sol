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
	bytes32[] locked721Tokens;

	mapping(bytes32 => address) tokenToOwner;

	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4){
		require(lock721Token(_operator, _tokenId, abi.decode(_data, (uint256, string, string, uint, address, uint, uint))), "Error receiving token");
		return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
	}

	function lock721Token public (address _tokenToLockAddress, uint256 _tokenToLockId, uint256 _erc20Supply, string _erc20Name, string _erc20Symbol, uint _erc20Decimals, address _erc20DeploymentAddress, uint _value, uint _duration) {

		bytes32 _tokenToLockHash = keccak256(abi.encodePacked(_tokenToLockAddress, _tokenToLockId))
		locked721Tokens.push(_tokenToLockHash);
		tokenToOwner[_tokenToLockHash] = msg.sender;
		freezeErc721Token(_tokenToLockAddress, _tokenToLockId);
		mintErc20s(_tokenToLockAddress, _erc20Supply, _erc20Name, _erc20Symbol _erc20Decimals, _erc20DeploymentAddress, _value, _duration);


	}

	function mintErc20s internal (address _tokenToLockAddress, uint256 _erc20Supply, string _erc20Name, string _erc20Symbol, uint _erc20Decimals, address _erc20DeploymentAddress, uint _value, uint _duration){
		
		AssetTokenizationContract newAssetTokenizationContract = new AssetTokenizationContract(_tokenToLockAddress, _erc20Supply, _erc20Name, _erc20Symbol, _erc20Decimals, _erc20DeploymentAddress, _value, _duration);

	}






	function freezeErc721Token(address _tokenToLockAddress, uint256 _tokenToLockId){

	}

	function balanceOf(address _owner) external view returns (uint256) {
    // 1. Return the number of zombies `_owner` has here
 	}

  	function ownerOf(uint256 _tokenId) external view returns (address) {
    // 2. Return the owner of `_tokenId` here
  	}

  	function transferFrom(address _from, address _to, uint256 _tokenId) external payable {

  	}

  	function approve(address _approved, uint256 _tokenId) external payable {

 	}

}
