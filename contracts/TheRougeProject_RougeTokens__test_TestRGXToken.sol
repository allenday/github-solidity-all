pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/RGXToken.sol";

contract TestRGXToken {
    
    function testInitialBalanceUsingDeployedContract() public {
        RGXToken rgx = RGXToken(DeployedAddresses.RGXToken());
        
        uint expected = 1000;
        
        Assert.equal(rgx.balanceOf(tx.origin), expected, "Owner should have 1000 RGXToken initially");
    }
    
    function testInitialBalanceWithNewRGXToken() public {
        RGXToken rgx = new RGXToken('RGX Token (x8 discount)', 'RGX8', 888, 1503478645, 8);
        
        uint expected = 888;
        
        Assert.equal(rgx.balanceOf(this), expected, "Owner should have 888 RGXToken initially");
    }

}
