pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/IERC20.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import "./driver-core.sol";
import "./tokenize-core-interface.sol";



contract AssetTokenizationContract is IERC20, Ownable {

    address public paymentAddress;
    IERC20 paymentAddressInstance;
    address public tokenizeCore;
    address public taxAddress;
    uint256 private _totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public taxRate;
    uint256 public minimumShares;

    uint256 accruedTaxes;


    UnderlyingToken public contractUnderlyingToken; 
    struct UnderlyingToken{
        address underlyingTokenAddress;
        uint256 underlyingTokenId;
    }

    mapping (address => HarbergerSet) public harbergerSetByUser; 
    struct HarbergerSet{
        uint256 userValue; // denominated in paymentAddress - i.e. .5 = .5 shares per (Dai * 10^18)
        uint256  userDuration; //duration in seconds
        uint256  userStartTime;
        bool initialized;
    }

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    mapping (address => uint) public escrowedByUser;
    mapping (address => uint) public accruedReimbursementByUser;

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

    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }

    function setERC20(string calldata _erc20Name, string calldata _erc20Symbol, uint8 _erc20Decimals) external tokenizeCoreOnly {
        name = _erc20Name;
        symbol = _erc20Symbol;
        decimals = _erc20Decimals;
    }

    function setMainInfo(address _paymentAddress, address _taxAddress, uint256 _minimumShares, uint256 _taxRate, uint256 _erc20Supply) external tokenizeCoreOnly {
        paymentAddress = _paymentAddress;
        paymentAddressInstance = IERC20(_paymentAddress);
        taxAddress = _taxAddress;
        minimumShares = _minimumShares;
        taxRate = _taxRate;
        _totalSupply = _erc20Supply;
        balances[address(this)] = _erc20Supply;
    }

   function setHarberger (uint _userValue, uint _userDuration) public {
        require (_userValue != 0);
        require (_userDuration != 0);

        if(harbergerSetByUser[msg.sender].initialized != true){
        harbergerSetByUser[msg.sender].initialized = true;
        } else{
        //close out existing position
        uint256 taxedPortion = (now - harbergerSetByUser[msg.sender].userStartTime) / harbergerSetByUser[msg.sender].userDuration;
        paymentAddressInstance.transfer(taxAddress, taxRate * harbergerSetByUser[msg.sender].userValue * taxedPortion);
        paymentAddressInstance.transfer(msg.sender, taxRate * harbergerSetByUser[msg.sender].userValue * (1-taxedPortion));
        }

        harbergerSetByUser[msg.sender].userValue = _userValue;
        harbergerSetByUser[msg.sender].userDuration = _userDuration;
        harbergerSetByUser[msg.sender].userStartTime = now;
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
        will be overloaded function, same params + uint _userDuration, uint _userValue; these will be set before determining escrow price
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
        //TODO: if you want this to be synchronous, call approveAndCall if implemented on the token contract, then call this function
        if (_from != address(this)){
            require (paymentAddressInstance.transferFrom(msg.sender, _from, (harbergerSetByUser[_from].userValue * _value)), "Payment to token owner failed");
        }

        //but they've still gotta pay taxes on any previously held tokens!
        if(_from != address(this)){
        accruedTaxes += (_value / balances[_from]) * escrowedByUser[_from] * (now - harbergerSetByUser[_from].userStartTime) / harbergerSetByUser[_from].userDuration;
        paymentAddressInstance.transfer(_from, (_value / balances[_from]) * escrowedByUser[_from] * (1 - (now - harbergerSetByUser[_from].userStartTime) / harbergerSetByUser[_from].userDuration));
        escrowedByUser[_from] -= (_value / balances[_from]) * escrowedByUser[_from];
        harbergerSetByUser[_from].userStartTime = now;
        }

        require(((harbergerSetByUser[_to].userStartTime + harbergerSetByUser[_to].userDuration) - now) >= 0);
        //TODO: wherever possible take this out of the reimbursement and avoid a transfer where possible for efficiency
        paymentAddressInstance.transferFrom(_to, address(this), taxRate * _value * harbergerSetByUser[_to].userValue * ((harbergerSetByUser[_to].userStartTime + harbergerSetByUser[_to].userDuration) - now) / 10000);
        accruedTaxes += escrowedByUser[_to] * (now - harbergerSetByUser[_to].userStartTime) / harbergerSetByUser[_to].userDuration;
        accruedReimbursementByUser[_to] += escrowedByUser[_to] * (1-(now - harbergerSetByUser[_to].userStartTime) / harbergerSetByUser[_to].userDuration);
        escrowedByUser[_to] = taxRate * _value * harbergerSetByUser[_to].userValue * ((harbergerSetByUser[_to].userStartTime + harbergerSetByUser[_to].userDuration) - now);
        harbergerSetByUser[_to].userDuration -= now - harbergerSetByUser[_to].userStartTime;
        harbergerSetByUser[_to].userStartTime = now;

        
        //uint256 _recipientTaxedPortion = 100 * (now - harbergerSetByUser[_to].userStartTime) / harbergerSetByUser[_to].userDuration; 
        // //toconsider - instead of paying out the taxes, consider adding them to a state variable and paying it all out at once; 
        // //changes the economics of it though, so need to think through this
        //paymentAddressInstance.transfer(taxAddress, taxRate * harbergerSetByUser[_to].userValue * _recipientTaxedPortion);

        // paymentAddressInstance.transfer(_to, taxRate * harbergerSetByUser[_to].userValue * (1 - _recipientTaxedPortion));


        // escrowedByUser[_to] -= taxRate * harbergerSetByUser[_from].userValue * harbergerSetByUser[_from].userDuration;
        // accruedReimbursementByUser[_to] += taxRate * harbergerSetByUser[_from].userValue * (1 - _senderTaxedPortion);
        
        // //recipient now needs to escrow, so one day they can pay taxes and get reimbursed and all that fun stuff
        // paymentAddressInstance.transferFrom(_to, address(this), (harbergerSetByUser[_to].userValue * harbergerSetByUser[_to].userDuration * _value));
        // escrowedByUser[_to] = harbergerSetByUser[_to].userValue * harbergerSetByUser[_to].userDuration * _value;
        // harbergerSetByUser[_to].userStartTime = now;
        
        

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
        emit testTransfer(balances[_to]);
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

    //TODO: can be used if paymentAddress has approveAndCall
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

    //TODO: function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
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
        require (balances[msg.sender] == _totalSupply);
        transferFrom(msg.sender, tokenizeCore, _totalSupply);
        TokenizeCoreInterface instanceTokenizeCore = TokenizeCoreInterface(tokenizeCore);
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

    event testTransfer(uint256 num);

}











