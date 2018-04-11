pragma solidity ^0.4.15;

import '../../contracts/KryptopyToken.sol';

// mock class using KryptopyToken
contract KryptopyTokenMock is KryptopyToken  {

  function KryptopyTokenMock()
    KryptopyToken()
  {
      owner = msg.sender;
  }

  function balanceOfWithoutUpdate(address _adr) public returns (uint) {
      return balances[_adr];
  }

  function setBalance(address _adr, uint balance) public onlyOwner {
      totalSupply = totalSupply.sub(balances[_adr]);
      balances[_adr] = balance;
      totalSupply = totalSupply.sub(balances[_adr]);
  }

  function getCurrentBlockTime() constant returns (uint ts) {
      return block.timestamp;
  }

}
