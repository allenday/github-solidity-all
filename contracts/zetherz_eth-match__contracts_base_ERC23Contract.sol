pragma solidity ^0.4.15;

/*interface*/contract ERC23ContractInterface {
  function tokenFallback(address _from, uint256 _value, bytes _data) external;
}

// implements ERC23
// see: https://github.com/ethereum/EIPs/issues/23
// help from HasNoTokens.sol
contract ERC23Contract is ERC23ContractInterface {

 /**
  * @dev Reject all ERC23 compatible tokens
  * param _from address that is transferring the tokens
  * param _value amount of specified token
  * param _data bytes data passed from the caller
  */
  function tokenFallback(address /*_from*/, uint256 /*_value*/, bytes /*_data*/) external {
    revert();
  }

}
