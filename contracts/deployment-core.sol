
pragma solidity ^0.5.0;
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

interface DeploymentCoreInterface{
	function onReceipt(bytes memory _deploymentData) public returns (bytes4);
}

contract DeploymentCoreExample is Ownable{


	address[] public recipients;

	function onReceipt(address _ERC20TokenAddress, uint _totalSupply, bytes memory _deploymentData) public returns (bytes4){
		distribute(_ERC20TokenAddress, _totalSupply);

		return bytes4(keccak256("onReceipt(address,uint,bytes)"));
	}

	function addRecipients(address[] memory _addressesToAdd) public onlyOwner{
		for(uint i = 0; i < address.length; i++){
			recipients.push(_addressesToAdd[i]);
		}
	}

	function distribute(address _ERC20TokenAddress, uint _totalSupply) internal {
		uint allocation = _totalSupply/(recipients.length);
		//need to think about error handling for when harbinger is not set by recipients; transfer will fail
		for(uint i = 0; i< recipients.length; i++){
			_ERC20TokenAddress.transfer(recipients[i], allocation);
		}

	}


}