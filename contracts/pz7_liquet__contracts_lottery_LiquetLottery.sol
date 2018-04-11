pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/ownership/Claimable.sol';

contract LiquetLottery is Claimable {

   struct Bet {
     uint a;
     uint b;
     uint c;
     uint d;
     uint e;
     uint f;
   }

    function LiquetLottery() {
    }

    function bet(uint a, uint b, uint c, uint d, uint e, uint f) {
      Bet memory bt = Bet(a, b, c, d, e, f);

    }

    function() {
        revert();
    }
}
