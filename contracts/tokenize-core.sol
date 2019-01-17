pragma solidity ^0.5.0;
import "./erc721.sol";

contract erc20DeploymentInterface{
	address tokenToLockAddress;
	uint256 erc20Supply;
	string erc20Name;
	uint erc20Decimals;
}

contract TokenizeCore is ERC721 {

	//state variables
	bytes32[] locked721Tokens;

	mapping(bytes32 => address) tokenToOwner;

	function lock721Token public (address _tokenToLockAddress, uint256 _tokenToLockId, uint256 _erc20Supply, string _erc20Name, uint erc20Decimals, address erc20DeploymentAddress) {

		bytes32 _tokenToLockHash = keccak256(abi.encodePacked(_tokenToLockAddress, _tokenToLockId))
		locked721Tokens.push(_tokenToLockHash);
		tokenToOwner[_tokenToLockHash] = msg.sender;
		freezeErc721Token(_tokenToLockAddress, _tokenToLockId)
		mintErc20s(_tokenToLockAddress, _erc20Supply, _erc20Name, _erc20Decimals, erc20DeploymentAddress);


	}

	function mintErc20s internal (address _tokenToLockAddress, uint256 _erc20Supply, string _erc20Name, uint _erc20Decimals, address erc20DeploymentAddress){
		
		AssetTokenizationContract newAssetTokenizationContract = new AssetTokenizationContract;
		newAssetTokenizationContract.setUnderlyingToken(_tokenToLockAddress)
	}

	function freezeErc721Token(address _tokenToLockAddress, uint256 _tokenToLockId){
		_tokenToLockAddress.call.value(0 ether).gas(10)(abi.encodeWithSignature("transfer(string)", "MyName"));

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
