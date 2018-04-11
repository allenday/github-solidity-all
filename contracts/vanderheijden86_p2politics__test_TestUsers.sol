pragma solidity ^0.4.4;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Users.sol";

contract TestUsers {

    address addr = 0x8Ae4F8fC3eCaf9E9394f037FD54405DBF77daCa2;
    Users users = new Users();

    function testSetRole() {

        users.setRole(addr, "insurance", "admin", 1);

        uint expected = 1;
        Assert.equal(users.hasRole(addr, "insurance", "admin"), expected, "Ad is niet admin.");


    }

    function testHasRole() {

        //address addrs = DeployedAddresses.Users();
        //Users users = Users(DeployedAddresses.Users.gas(1000)());

        uint expected = 1;
        Assert.equal(users.hasRole(addr, "insurance", "admin"), expected, "Ad is niet admin.");

    }

    function testChangeRole() {

        users.setRole(addr, "insurance", "admin", 2);

        uint expected = 2;
        Assert.equal(users.hasRole(addr, "insurance", "admin"), expected, "Ad is niet admin.");


    }
}
