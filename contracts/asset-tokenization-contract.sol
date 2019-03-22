pragma solidity ^0.5.0;
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import "./deployment-core.sol";
import "./tokenize-core.sol";
import "./driver-core.sol";

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

contract AssetTokenizationContract is Ownable {

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

    ERC20 paymentAddressInstance = ERC20(paymentAddress);
    

    //structs
    struct UnderlyingToken{
        address underlyingTokenAddress;
        uint underlyingTokenId;
    }


    struct HarbergerSet{
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
    mapping (address => HarbergerSet) harbergerSetByUser;
    mapping (address => uint) escrowedByUser;
    mapping (address => uint) accruedReimbursementByUser;

    constructor (
        address _underlyingTokenAddress, 
        uint _underlyingTokenId) public
    {
        tokenizeCore = msg.sender;
        contractUnderlyingToken.underlyingTokenAddress = _underlyingTokenAddress;
        contractUnderlyingToken.underlyingTokenId = _underlyingTokenId;

    }

    modifier tokenizeCoreOnly{
        require(msg.sender == tokenizeCore);
        _;
    }

    function setERC20(string memory _erc20Name, string memory _erc20Symbol, uint8 _erc20Decimals) public tokenizeCoreOnly {
        name = _erc20Name;
        symbol = _erc20Symbol;
        decimals = _erc20Decimals;
    }

    function setMainInfo(address _paymentAddress, address _taxAddress, uint256 _minimumShares, uint256 _taxRate) public tokenizeCoreOnly {

        paymentAddress = _paymentAddress;
        taxAddress = _taxAddress;
        minimumShares = _minimumShares;
        taxRate = _taxRate;
    }

    function setDistributionInfo(address _distributionAddress, uint256 _erc20Supply, bytes memory _deploymentData) public tokenizeCoreOnly {
        //Actually, I don't think distribution flag is needed since it's tokenizeCoreOnly; 
        //will think more about this later
        require(distributionFlag == 0);
        totalSupply = _erc20Supply;
        balances[_distributionAddress] = _erc20Supply;
        // set distribution address
        distributionAddress = _distributionAddress;
        //distribute initially
        DeploymentCoreInterface instanceDeploymentCore = DeploymentCoreInterface(_distributionAddress);
            if(instanceDeploymentCore.onReceipt(totalSupply, _deploymentData) == true){
                distributionFlag++;
            }
            else{
                return "err: unable to distribute initial tokens";
            }
    }


   function setHarberger (uint _userValue, uint _userDuration) public {
        require (_userValue != 0);
        require (_userDuration != 0);

        if(harbergerSetByUser[msg.sender].initialized == false){
        harbergerSetByUser[msg.sender].initialized == true;
        }
        harbergerSetByUser[msg.sender].userValue = _userValue;
        harbergerSetByUser[msg.sender].userDuration = _userDuration;
    // set user start time
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        // makes sure that once the underlying asset is unlocked, the tokens are destroyed
        require (msg.sender != tokenizeCore);
        require (_value > 0, "value must be greater than 0");
        require ((harbergerSetByUser[_to].initialized == true) || (_to == tokenizeCore));
        require (balances[_to] + _value >= minimumShares && ((balances[msg.sender] - _value >= minimumShares) || balances[msg.sender] - _value == 0));


        if (balances[msg.sender] >= _value && _value > 0) {
            doTransfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        /*todo offer a version of this function where recipient can change their duration/value within the function call
        will be same params + uint _userDuration, uint _userValue; these will be set before determining escrow price
        */

        //make sure once the erc721 token is unlocked, tokens are destroyed
        require (_from != tokenizeCore, "");
        require (_value > 0, "value must be greater than 0");

        //make sure recipient has harberger tax value and duration set
        require (harbergerSetByUser[_to].initialized == true || _to == tokenizeCore, "recipient must have harberger tax set");

        //if there's a minimumShares, make sure it's enforced by both sender and receiver after the tx
        require (balances[_to] + _value >= minimumShares && (balances[_from] - _value >= minimumShares || balances[_from] - _value == 0));

        
        
        // unless it's initial distribution, let's make sure we pay the _from when we're taking their shares
        // _to should send _from (how much _from values each share) * (number of shares being taken)
        //if you want this to be synchronous, call approveAndCall if implemented on the token contract, then call this function
        if (msg.sender != address(this) && msg.sender != distributionAddress){
            require (paymentAddressInstance.transferFrom(_to, _from, (harbergerSetByUser[_from].userValue * _value)), "Payment to token owner failed");
        }

        //but they've still gotta pay taxes on any previously held tokens!
        uint _senderDebt;
        _senderDebt = (now - harbergerSetByUser[_from].userStartTime) * harbergerSetByUser[_from].userValue * taxRate * escrowedByUser[_from]*(_value/balances[_from]); 
        //toconsider - instead of paying out the taxes, consider adding them to a state variable and paying it all out at once; 
        //changes the economics of it though, so need to think through this
        paymentAddressInstance.transfer(taxAddress, _senderDebt);
        escrowedByUser[_from] -= _senderDebt;

        //now, whoever is having shares taken from them needs to be reimbursed whatever's untaxed from their original escrow
        uint _senderReimbursement;
        _senderReimbursement = (harbergerSetByUser[_from].userStartTime + harbergerSetByUser[_from].userDuration - now) * harbergerSetByUser[_from].userValue * taxRate * escrowedByUser[_from] * (_value/balances[_from]);
        escrowedByUser[_from] -= _senderReimbursement;
        accruedReimbursementByUser[_from] += _senderReimbursement;

        //let's clear out the recipient's escrow as well, so we can reset their userStartTime and make them a new escrow
        uint _recipientDebt;
        _recipientDebt = (now - harbergerSetByUser[_to].userStartTime) * harbergerSetByUser[_to].userValue * taxRate; 
        //toconsider - instead of paying out the taxes, consider adding them to a state variable and paying it all out at once; 
        //changes the economics of it though, so need to think through this
        paymentAddressInstance.transferFrom(address(this), taxAddress, _recipientDebt);


        uint _recipientReimbursement;
        _recipientReimbursement = (harbergerSetByUser[_to].userStartTime + harbergerSetByUser[_to].userDuration - now) * harbergerSetByUser[_to].userValue * taxRate;
        escrowedByUser[_to] -= _recipientReimbursement;
        accruedReimbursementByUser[_to] += _recipientReimbursement;
            
        

        //recipient now needs to escrow, so one day they can pay taxes and get reimbursed and all that fun stuff
        paymentAddressInstance.transferFrom(_to, address(this), (harbergerSetByUser[_to].userValue * harbergerSetByUser[_to].userDuration * _value));
        escrowedByUser[_to] = harbergerSetByUser[_to].userValue * harbergerSetByUser[_to].userDuration * _value;
        harbergerSetByUser[_to].userStartTime = now;
        
        if (balances[_from] >= _value && _value > 0) {
            doTransfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function doTransfer(address _from, address _to, uint256 _value) internal {
        require((_to != address(0)) && (_to != address(this)));
        require(_value <= balances[_from]);
        balances[_from] -= _value;
        balances [_to] += _value;
        emit Transfer(_from, _to, _value);
    }


    function withdrawReimbursement(uint amount) public {
        require(accruedReimbursementByUser[msg.sender] >= amount);
        accruedReimbursementByUser[msg.sender] -= amount;
        paymentAddressInstance.transfer(msg.sender, amount);
    }
    /*
    allows this contract to call an arbitrary function on a passed "driver" contract
    example implementation: "onlyOwner" is a smart contract address with a voting
    mechanism governed by owners of this contract's erc20 tokens
    they can vote on decisions affecting the underlying 721
    */
    function execute(bytes memory _logic, address _driver) public onlyOwner{
        DriverCoreInterface instanceDriverCore = DriverCoreInterface(_driver);
        instanceDriverCore.executeCall(_logic);
    }

    //function getDebtByUser(address _user) public view returns(uint){
    //	return escrowedByUser[_user] - (harbergerSetByUser[_user].value * taxRate * balances[_user] * 
    //}

    //can be used if paymentAddress has approveAndCall
    //function allowAndTransferFrom(address _from, address _to, uint256 _value, bytes _extraData){

    //}

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    // required bc of erc20
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }


    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    function () external {
    //if ether is sent to this address, send it back.
  
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


    function unlockToken() public {
        require (balances[msg.sender] == totalSupply);
        transferFrom(msg.sender, tokenizeCore, totalSupply);
        TokenizeCore instanceTokenizeCore = TokenizeCore(tokenizeCore);
        instanceTokenizeCore.unlockToken(contractUnderlyingToken.underlyingTokenAddress, contractUnderlyingToken.underlyingTokenId, msg.sender);
    }


    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount
    );

    event Approval(
    address indexed _owner,
    address indexed _spender,
    uint256 _amount
    );

}











