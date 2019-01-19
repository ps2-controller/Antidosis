pragma solidity ^0.5.0;
import //Ownable 
import "./tokenize-core.sol";

contract AssetTokenizationContract is TokenizeCore, Ownable{

	//contract variables
	address public underlyingToken;
	uint256 public totalSupply;
	string public name;
	string public symbol;

	//mappings
	mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

	constructor AssetTokenizationContract(address _tokenToLockAddress, uint256 _erc20Supply, string _erc20Name, string _erc20Symbol, uint _erc20Decimals, address _erc20DeploymentAddress, uint _value, uint _duration){
		underlyingToken = _tokenToLockAddress;
		totalSupply = _erc20Supply;
		name = _erc20Name;
		symbol = _erc20Symbol;

	}


	function transfer(address _to, uint256 _value) returns (bool success) {
    //Default assumes totalSupply can't be over max (2^256 - 1).
    //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
    //Replace the if with this one instead.
    //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    //same as above. Replace this line with the following if you want to protect against wrapping uints.
    //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

}