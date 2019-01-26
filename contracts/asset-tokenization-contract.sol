pragma solidity ^0.5.0;
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import "./tokenize-core.sol";
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

//todo:
//add eip 161 support
//check consistency of requiring payment denominated in payment address
// set up distribution scheme
// set up all necessary interfaces and stuff
// set up duration logic
//set up taxing logic/requirements/penalties
//enforce appropriate permissioning for everything
//add taxAddress all the way through


//long term todo (nice-to-haves):
//allow the option of using eth instead of wrapped eth for underlying value

contract AssetTokenizationContract is TokenizeCore, Ownable{

	//contract variables
	//the ERC721 token locked to create the shares denominated in this ERC20 token
	UnderlyingToken public contractUnderlyingToken;
	// the address that contains deployment logic for the initial distribution of tokens
	address distributionAddress;
	// the token in which payments for shares are to be made
	address paymentAddress;
	address tokenizeCore;
	address taxAddress;


	uint256 public totalSupply;
	string public name;
	string public symbol;
	uint8 public decimals;
	uint taxRate;
	uint defaultValue = 0;
	uint defaultDuration = 0;
	uint minimumShares;
	uint distributionFlag = 0;

	//structs
	struct UnderlyingToken{
		address underlyingTokenAddress;
		uint underlyingTokenId;
	}


	struct HarbingerSet{
		// denominated in paymentAddress - i.e. .5 = .5 shares per Dai
		uint userValue;
		//duration in seconds
		uint userDuration;
		uint userStartTime;
		bool initialized;
	}


	//mappings
	mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => HarbingerSet) harbingerSetByUser;
    mapping (address => uint) escrowedByUser;

	constructor (
		address _underlyingTokenAddress, 
		address _distributionAddress,
		address _paymentAddress,
		address _taxAddress,
		uint _underlyingTokenId,
		uint256 _erc20Supply, 
		string memory _erc20Name, 
		string memory _erc20Symbol, 
		uint _erc20Decimals,
		uint _minimumShares,  
		bytes memory _deploymentData) public
	{
		tokenizeCore = msg.sender;
		paymentAddress = _paymentAddress;
		taxAddress = _taxAddress;
		minimumShares = _minimumShares;
		contractUnderlyingToken.underlyingTokenAddress = _underlyingTokenAddress;
		contractUnderlyingToken.underlyingTokenId = _underlyingTokenId;
		totalSupply = _erc20Supply;
		name = _erc20Name;
		symbol = _erc20Symbol;
		decimals = _erc20Decimals;
		balances[_distributionAddress] = _erc20Supply;
		distributeInitially(address(this),_distributionAddress, _deploymentData);
		// set distribution address
		distributionAddress = _distributionAddress;
	}

	function distributeInitially (address _ERC20TokenAddress, address _distributionAddress, bytes memory _deploymentData) internal {
		require(distributionFlag == 0);
		_distributionAddress.onReceipt(_ERC20TokenAddress, totalSupply, _deploymentData);
		distributionFlag++;
	}

	function transfer(address _to, uint256 _value) public returns (bool success) {
        // makes sure that once the underlying asset is unlocked, the tokens are destroyed
        require (msg.sender != tokenizeCore);
        require (balances[_to] + _value >= minimumShares && balances[msg.sender - _value >= minimumShares]);
        require (harbingerSetByUser[_to].initialized == true);
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function Transfer(address _from, address _to, uint256 _value) internal {
    	balances[_from] -= _value;
    	balances [_to] += _value;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    	//todo offer a version of this function where recipient can change their duration/value within the function call
    	// will be same params + uint _userDuration, uint _userValue; these will be set before determining escrow price
    	//make sure once the erc721 token is unlocked, tokens are destroyed
    	require (_from != contractUnderlyingToken);
    	//if there's a minimumShares, make sure it's enforced by both sender and receiver after the tx
    	require (balances[_to] + _value >= minimumShares && (balances[_from] - _value >= minimumShares || balances[_from] - _value == 0));
        //make sure recipient has harbinger tax value and duration set
        require (harbingerSetByUser[_to].initialized == true || _to == contractUnderlyingToken);
        
        // unless it's initial distribution, let's make sure we pay the _from when we're taking their shares
        // _to should send _from (how much _from values each share) * (number of shares being taken)
        if (msg.sender != address(this) && msg.sender != distributionAddress){
        	require (paymentAddress.transferFrom(_to, _from, (harbingerSetByUser[_from].userValue * _value)));
        }

        //but they've still gotta pay taxes on any previously held tokens!
        uint _senderDebt;
        _senderDebt = (now - harbingerSetByUser[_from].userStartTime) * harbingerSetByUser[_from].userValue * taxRate * (_value/balances[_from]); 
        //toconsider - instead of paying out the taxes, consider adding them to a state variable and paying it all out at once; 
        //changes the economics of it though, so need to think through this
        paymentAddress.transferFrom(address(this), taxAddress, _senderDebt);

        //now, whoever is having shares taken from them needs to be reimbursed whatever's untaxed from their original escrow
        uint _senderReimbursement;
        _senderReimbursement = (harbingerSetByUser[_from].userStartTime + harbingerSetByUser[_from].userDuration - now) * harbingerSetByUser[_from].userValue * taxRate * (_value/balances[_from]);
        paymentAddress.transferFrom((address(this), _from, _senderReimbursement));

        //let's clear out the recipient's escrow as well, so we can reset their userStartTime and make them a new escrow
        if (escrowedByUser[_to] > 0){

        	uint _recipientDebt;
        	_recipientDebt = (now - harbingerSetByUser[_to].userStartTime) * harbingerSetByUser[_to].userValue * taxRate; 
        	//toconsider - instead of paying out the taxes, consider adding them to a state variable and paying it all out at once; 
        	//changes the economics of it though, so need to think through this
        	paymentAddress.transferFrom(address(this), taxAddress, _recipientDebt);


        	uint _recipientReimbursement;
        	_recipientReimbursement = (harbingerSetByUser[_to].userStartTime + harbingerSetByUser[_to].userDuration - now) * harbingerSetByUser[_to].userValue * taxRate;
        	paymentAddress.transferFrom((address(this), _to, _recipientReimbursement));
    	}

        //recipient now needs to escrow, so one day they can pay taxes and get reimbursed and all that fun stuff
        paymentAddress.transferFrom(_to, address(this), harbingerSetByUser[_to].userValue * harbingerSetByUser[_to].userDuration * _value);
        escrowedByUser[_to] = harbingerSetByUser[_to].userValue * harbingerSetByUser[_to].userDuration * _value;
		harbingerSetByUser[_to].userStartTime = now;
        
        if (balances[_from] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    //function getDebtByUser(address _user) public view returns(uint){
    //	return escrowedByUser[_user] - (harbingerSetByUser[_user].value * taxRate * balances[_user] * 
    //}

    //can be used if paymentAddress has approveAndCall
    //function allowAndTransferFrom(address _from, address _to, uint256 _value, bytes _extraData){

    //}

    function balanceOf(address _owner) pure public returns (uint256 balance) {
        return balances[_owner];
    }

    // function approve(address _spender, uint256 _value) public returns (bool success) {
       // allowed[msg.sender][_spender] = _value;
       // Approval(msg.sender, _spender, _value);
       // return true;
    //}



    function allowance(address _owner, address _spender) pure public returns (uint256 remaining) {
      	return allowed[_owner][_spender];
    }


    function () external {
    //if ether is sent to this address, send it back.
    revert;
    }

    //function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
    //	allowed[msg.sender][_spender] = _value;
    //	Approval(msg.sender, _spender, _value);
//
  //      //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
    //    //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
      //  //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        //if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert; }
        //return true;
    //}

   	function setHarbinger (uint _userValue, uint _userDuration) public {
		require (_userValue != 0);
		require (_userDuration != 0);

		if(harbingerSetByUser[msg.sender].initialized == false){
			harbingerSetByUser[msg.sender].initialized == true;
		}
		harbingerSetByUser[msg.sender].userValue = _userValue;
		harbingerSetByUser[msg.sender].userDuration = _userDuration;
		// set user start time
	}

	function unlockToken() public {
		require (balances[msg.sender] == totalSupply);
		transferFrom(msg.sender, tokenizeCore, totalSupply);
		tokenizeCore.unlockToken(UnderlyingToken.underlyingTokenAddress, UnderlyingToken.underlyingTokenId, msg.sender);
	}

}











