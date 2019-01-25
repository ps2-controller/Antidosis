
pragma solidity ^0.5.0;
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract DeploymentCoreExample is Ownable{

	interface DeploymentCoreInterface{
		function onReceipt(bytes _deploymentData) returns (bytes4);
	}

	public address[] recipients;

	function onReceipt(address _ERC20TokenAddress, uint _totalSupply, bytes _deploymentData) public returns (bytes4){
		distribute(_ERC20TokenAddress, _totalSupply);

		return bytes4(keccak256("onReceipt(address,uint,bytes)"));
	}

	function addRecipients(address[] _addressesToAdd) onlyOwner{
		for(i = 0; i < address.length; i++){
			recipients.push(_addressesToAdd[i]);
		}
	}

	function distribute(address _ERC20TokenAddress, uint _totalSupply) internal {
		uint allocation = _totalSupply/(recipients.length);
		//need to think about error handling for when harbinger is not set by recipients; transfer will fail
		for(i = 0; i< recipients.length; i++){
			_ERC20TokenAddress.transfer(_recipients[i], allocation);
		}

	}


}