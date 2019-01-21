pragma solidity ^0.5.0;
// import Ownable 
import "./tokenize-core.sol";

contract AssetTokenizationContract is TokenizeCore, Ownable{

	//contract variables
	UnderlyingToken public contractUnderlyingToken;
	address distributionAddress;
	uint256 public totalSupply;
	string public name;
	string public symbol;
	uint8 public decimals;
	uint taxRate;
	uint defaultValue = 0;
	uint defaultDuration = 0;

	//structs
	struct UnderLyingToken{
		address underlyingTokenAddress;
		uint underlyingTokenId;
	}

	struct HarbingerSet{
		uint userValue;
		uint userDuration;
		bool initialized;
	}

	//mappings
	mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping(address => HarbingerSet) harbingerSetByUser;

	constructor AssetTokenizationContract is ERC20, TokenizeCore (
		address _underlyingTokenAddress, 
		address _distributionAddress,
		uint _underlyingTokenId,
		uint256 _erc20Supply, 
		string _erc20Name, 
		string _erc20Symbol, 
		uint _erc20Decimals,  
		bytes _deploymentData)
	{
		UnderlyingToken.underlyingTokenAddress = _underlyingTokenAddress;
		UnderlyingToken.underlyingTokenId = _underlyingTokenId;
		totalSupply = _erc20Supply;
		name = _erc20Name;
		symbol = _erc20Symbol;
		decimals = _erc20Decimals;
		_distributionAddress.onReceipt(_deploymentData);
		// set distribution address
		distributionAddress = _distributionAddress;
		balances[_distributionAddress] = _erc20Supply;
	}


	function transfer(address _to, uint256 _value) returns (bool success) {
        // makes sure that once the underlying asset is unlocked, the tokens are destroyed
        require (msg.sender != underlyingToken);
        require (harbingerSetByUser[_to].initialized == true);
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    	require (_from != underlyingToken);
        require (harbingerSetByUser[_to].initialized == true);
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

    	function setHarbinger(_userValue, _userDuration) {
		require (_userValue != 0);
		require (_userDuration != 0);
		if(harbingerSetByUser[msg.sender].initialized == false){
			harbingerSetByUser[msg.sender].initialized == true;
		}
		harbingerSetByUser[msg.sender].userValue = _userValue;
		harbingerSetByUser[msg.sender].userDuration = _userDuration;
	}

}











