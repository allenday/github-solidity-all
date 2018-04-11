pragma solidity ^0.4.14;
// 'Submarine Sends': Inside IC3's Plan to Clamp Down on ICO Cheats - CoinDesk 
// https://www.coindesk.com/submarine-sends-inside-ic3s-plan-to-clamp-down-on-ico-cheats/?utm_content=buffer693e1&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer


contract HotCrowdsale{
   // fallback function can be used to buy tokens
   // mining pools "frontrunning" issue
   function () payable {
     buyTokens(msg.sender);
   }

   // low level token purchase function
   function buyTokens(address beneficiary) payable {
     require(beneficiary != 0x0);
   }
}


