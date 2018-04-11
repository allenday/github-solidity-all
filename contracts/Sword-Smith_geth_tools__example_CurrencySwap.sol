pragma solidity ^0.4.9;
import "./Tmc4.sol";
import "./DataFeed0.sol";

contract CurrencySwap {
  Tmc4 tokenContractA;
  Tmc4 tokenContractB;
  DataFeed0 dataFeed;
  address addrA;
  address addrB;

  function CurrencySwap() public {
    tokenContractA = Tmc4(_address_Tmc4_A);
    tokenContractB = Tmc4(_address_Tmc4_B);
    dataFeed       = DataFeed0(_address_DataFeed0_);
    addrA          = _address_my_;
    addrB          = 0x0123456789012345678901234567890123456789;
  }

  // For this to work, the balances to be non-negative after this execution
  function execute() public {
    uint256 value = dataFeed.get(0);
    tokenContractA.transferFrom( addrA, addrB, 1 );
    tokenContractB.transferFrom( addrA, addrB, value );
  }
}
