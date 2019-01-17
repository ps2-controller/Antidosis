pragma solidity ^0.5.0;
import //Ownable 
import "./tokenize-core.sol";

contract AssetTokenizationContract is TokenizeCore, Ownable{

	//contract variables
	address underlyingToken;

	function setUnderlyingToken onlyOwner (_tokenToLockAddress){
		underlyingToken = _tokenToLockAddress;
	}
}