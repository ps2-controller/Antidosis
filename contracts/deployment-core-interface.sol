
pragma solidity ^0.5.0;

interface DeploymentCoreInterface{
	function onReceipt(uint _totalSupply, bytes calldata _deploymentData) external returns (bytes4);
}