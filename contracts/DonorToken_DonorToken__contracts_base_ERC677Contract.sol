pragma solidity ^0.4.13;

/*interface*/contract ERC677ContractInterface {
  function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _data) external returns (bool);
  function receiveTransfer(address _from, uint256 _value, address _tokenContract, bytes _data) external returns (bool);
  event ReceiveApproval(address indexed from, uint256 value, address indexed tokenContract, bytes indexed data);
  event ReceiveTransfer(address indexed from, uint256 value, address indexed tokenContract, bytes indexed data);
}

// implements ERC677
// see: https://github.com/ethereum/EIPs/issues/677
// help from https://github.com/ConsenSys/Tokens/blob/master/contracts/SampleRecipientSuccess.sol
contract ERC677Contract is ERC677ContractInterface {

  /* Processes token approvals */
  function receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _data) external returns (bool) {
    ReceiveApproval(_from, _value, _tokenContract, _data);
    return true;
  }

  /* Processes token transfers */
  function receiveTransfer(address _from, uint256 _value, address _tokenContract, bytes _data) external returns (bool) {
    ReceiveTransfer(_from, _value, _tokenContract, _data);
    return true;
  }

}
