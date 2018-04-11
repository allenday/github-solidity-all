pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RGXBonus.sol";

contract TestRGXBonus {
    
    function testInitialBalanceUsingDeployedContract() public {
        RGXBonus rgxb = RGXBonus(DeployedAddresses.RGXBonus());
        
        uint expected = 0;
        
        Assert.equal(rgxb.balanceOf(tx.origin), expected, "Owner should have 0 RGXB initially");
    }
    
    function testInitialBalanceWithNewRGXBonus() public {
        RGXBonus rgxb = new RGXBonus('RGXB (bounty/x11 discount)', 'RGXB', 1503478645, 11);
        
        uint expected = 0;
        
        Assert.equal(rgxb.balanceOf(this), expected, "Owner should have 0 RGXB initially");
    }

}
