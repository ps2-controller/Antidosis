pragma solidity ^0.5.0;
import 'openzeppelin-solidity/contracts/token/ERC721/ERC721Holder.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol';
import "./asset-tokenization-contract.sol";
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';



contract TokenizeCore is ERC721Holder, Ownable {

	//state variables
	TokenToLock[] locked721Tokens;

	//structs
	struct TokenToLock{
		address tokenToLockAddress;
		uint tokenToLockId;
	}

	mapping(address => TokenToLock) public ERC20ToToken;
	mapping(bytes32 => address) tokenToERC20;

	function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) public returns(bytes4){
		(address[3] memory addressesToUse, 
			uint256 _erc20Supply,
			string memory _erc20Name, 
			string memory _erc20Symbol, 
			uint8 _erc20Decimals,
			uint256 _minimumShares, 
			uint256 _taxRate,
			//not sure if I need deployment data; it's meant to handle any custom logic needed for deployment, but may not be needed - keeping for now
			bytes memory _deploymentData) = abi.decode(_data, (
				address[3], 
				uint256, 
				string, 
				string, 
				uint8, 
				uint256,
				uint256,
				bytes));
		//deploys new asset tokenization contract for the contributed token
		(bool a, address b) = lock721Token(msg.sender, _tokenId);
		require(a == true);
		//set ERC20 variables
			// address that handles logic for initial distribution of ERC20 tokens
			address _distributionAddress = addressesToUse[0];
			// ERC20 contract address that denominates what payments/taxes are paid in (DAI contract address by default)
			address _paymentAddress = addressesToUse[1];
			// address of the recipient of all tax payments for this token
			address _taxAddress = addressesToUse[2];
		AssetTokenizationContract instanceAssetTokenizationContract = AssetTokenizationContract(b);
		instanceAssetTokenizationContract.setERC20( _erc20Name, _erc20Symbol, _erc20Decimals);
		instanceAssetTokenizationContract.setMainInfo(_paymentAddress, _taxAddress, _minimumShares, _taxRate);
		instanceAssetTokenizationContract.setDistributionInfo(_distributionAddress, _erc20Supply, _deploymentData);

		return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
	}

	function lock721Token (
		address _tokenToLockAddress, 
		uint256 _tokenToLockId) private returns(bool, address)
	{
		TokenToLock memory _tokenToLock = TokenToLock(_tokenToLockAddress, _tokenToLockId);
		locked721Tokens.push(_tokenToLock); //need to think about if this will cause space issues
		//deploy asset tokenization contract
		AssetTokenizationContract newAssetTokenizationContract = new AssetTokenizationContract(_tokenToLockAddress, _tokenToLockId);

		ERC20ToToken[address(newAssetTokenizationContract)] = _tokenToLock;
		bytes32 _tokenToLockHash = keccak256(abi.encode(_tokenToLockAddress, _tokenToLockId));
		tokenToERC20[_tokenToLockHash] = address(newAssetTokenizationContract);
		return (true, address(newAssetTokenizationContract));
	}

	function getERC20Address(address _tokenToLockAddress, uint _tokenToLockId) public view returns(address){
		bytes32 _tokenToLockHash = keccak256(abi.encode(_tokenToLockAddress, _tokenToLockId));
		return tokenToERC20[_tokenToLockHash];
	}


	function unlockToken  (address _tokenToUnlockAddress, uint _tokenToUnlockId, address _claimant) public {
		require (msg.sender == tokenToERC20[keccak256(abi.encode(_tokenToUnlockAddress, _tokenToUnlockId))]);
		ERC721 instanceERC721 = ERC721(_tokenToUnlockAddress);
		instanceERC721.safeTransferFrom(address(this), _claimant, _tokenToUnlockId);
	}

}
