pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/VeteranCoin.sol";


contract TestVeteranCoin {

    address account0 = 0x512d964f1210b480fa6188ca7a1657ec4facd2de;
    address account1 = 0xe3a501f5efe9c24ddc7aa494769095cca94d7174;
    string privkey0 = "c94c30f23be98d07f31b9a19efe1b25934e1b254b998e4f63b596dcfb20be9db";

    function testInitalBalance(){
        VeteranCoin veteranCoin = VeteranCoin(DeployedAddresses.VeteranCoin());
        uint expected = 1E19;
        Assert.equal(veteranCoin.balanceOf(tx.origin), expected, "Owner should have 5E19 VeteranCoin" );
    }

    function testAllowance(){
        VeteranCoin veteranCoin = VeteranCoin(DeployedAddresses.VeteranCoin());
        uint expected = 200;
        Assert.equal(veteranCoin.approve(account0, expected), true, "Approved");
    }

    /**
    function testBurn(){
        VeteranCoin veteranCoin = VeteranCoin(DeployedAddresses.VeteranCoin());
        bool isBurned = veteranCoin.burn(1E19);
        Assert.equal(isBurned, true, "Burn Processed");
        uint256 actual = veteranCoin.balanceOf(tx.origin);
        Assert.equal(actual, 0, "Burned amount");
    }
    */

}
