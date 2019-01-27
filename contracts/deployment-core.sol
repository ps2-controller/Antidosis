
pragma solidity ^0.5.0;
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';

interface DeploymentCoreInterface{
	function onReceipt(bytes calldata _deploymentData) external returns (bytes4);
}

contract DeploymentCore is Ownable{


	address[] public recipients;

	function onReceipt(address _ERC20TokenAddress, uint _totalSupply, bytes memory _deploymentData) public returns (bytes4){
		distribute(_ERC20TokenAddress, _totalSupply);

		return bytes4(keccak256("onReceipt(address,uint,bytes)"));
	}

	function addRecipients(address[] memory _addressesToAdd) public onlyOwner{
		for(uint i = 0; i < _addressesToAdd.length; i++){
			recipients.push(_addressesToAdd[i]);
		}
	}

	function distribute(address _ERC20TokenAddress, uint _totalSupply) internal {
		uint allocation = _totalSupply/(recipients.length);
		//need to think about error handling for when harberger is not set by recipients; transfer will fail
		for(uint i = 0; i< recipients.length; i++){
			ERC20 instanceERC20 = ERC20(_ERC20TokenAddress);
			instanceERC20.transfer(recipients[i], allocation);
		}

	}


}