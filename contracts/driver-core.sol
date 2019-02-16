pragma solidity ^0.5.0;

interface DriverCoreInterface{
	function executeCall(bytes calldata _logic) external returns (bytes4);
}

