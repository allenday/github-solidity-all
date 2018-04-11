pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/common/AccessControl.sol";
import "../contracts/common/Math.sol";

contract TestCommon {
    function testAccessControl() public {
        AccessControl access = new AccessControl();
        Assert.equal(access.admins(this), true, "I should be an admin by default");

        address address1 = 0x123;
        access.addAdmin(address1);
        Assert.equal(access.admins(address1), true, "I should add an admin");
        access.removeAdmin(address1);
        Assert.equal(access.admins(address1), false, "I should remove an admin");

        address addresss2 = 0x234;
        access.addManager(addresss2);
        Assert.equal(access.managers(addresss2), true, "I should add a manager");
        access.removeManager(addresss2);
        Assert.equal(access.managers(addresss2), false, "I should remove a manager");
    }

    function testMath() public {
        Assert.equal(Math.min(2, 6), 2, "The min function is not working");
        Assert.equal(Math.min(12, 6), 6, "The min function is not working");
    }
}
