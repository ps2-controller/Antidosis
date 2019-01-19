pragma solidity ^0.5.0;
import //Ownable 
import "./tokenize-core.sol";

contract AssetTokenizationContract is TokenizeCore, Ownable{

	//contract variables
	address public underlyingToken;
	uint256 public totalSupply;
	string public name;
	string public symbol;
	uint8 public decimals;

	//mappings
	mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

	constructor AssetTokenizationContract is ERC20 (
		address _tokenToLockAddress, 
		uint256 _erc20Supply, 
		string _erc20Name, 
		string _erc20Symbol, 
		uint _erc20Decimals, 
		address _erc20DeploymentAddress, 
		uint _value, 
		uint _duration)
	{
		underlyingToken = _tokenToLockAddress;
		totalSupply = _erc20Supply;
		name = _erc20Name;
		symbol = _erc20Symbol;
		decimals = _erc20Decimals;
		DeploymentCore newDeploymentCore = new DeploymentCore;
		address distributionAddress = address(newDeploymentCore);
		balances[distributionAddress] = _erc20Supply;
	}


	function transfer(address _to, uint256 _value) returns (bool success) {
        // makes sure that once the underlying asset is unlocked, the tokens are destroyed
        require (msg.sender != underlyingToken);

        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      	return allowed[_owner][_spender];
    }


        function () {
        //if ether is sent to this address, send it back.
        throw;
    }

        function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }

}











