import "mortal.sol";

contract PlutonDistribution is mortal {

  mapping ( address => uint256 ) distributedAmount;
//EtherTransaction[1] etherTransactions = [EtherTransaction(hex"5487b714c0659731efaf9021e2ac161153e01b0259221f378a4202551af52695",1184207878095000)];
//BitcoinTransaction[695] bitcoinTransactions;

  function PlutonDistribution() {
  }

  function distributeIfNeeded(address _toAddress, uint256 _totalAmount) onlyowner returns (bool _success)  {
    uint256 _amountDistributed = distributedAmount[_toAddress];
    uint256 _amountLeft = _totalAmount - _amountDistributed;
    if (_amountLeft>0) {
      distributedAmount[_toAddress]=distributedAmount[_toAddress]+_amountLeft;
    }
    _success = true;
  }

}
