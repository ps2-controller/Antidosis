
pragma solidity ^0.5.0;

interface TokenizeCoreInterface{
    function unlockToken  (address _tokenToUnlockAddress, uint _tokenToUnlockId, address _claimant) external;
}

