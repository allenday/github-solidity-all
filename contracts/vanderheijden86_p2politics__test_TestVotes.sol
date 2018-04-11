pragma solidity ^0.4.8;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Users.sol";
import "../contracts/Votes.sol";

contract TestVotes {

    address addr = 0x8Ae4F8fC3eCaf9E9394f037FD54405DBF77daCa2;
    Votes votes = new Votes();

    function testVote() {

        bytes32 outcome = votes.vote(1, 20, "down with the system you greedy bastards");

        bytes32 expected = "Voted successfully.";

        Assert.equal(outcome, expected, "FAIL FAIL FAIL");

    }

    /* function getVote() { */

    /*     bytes32 outcome = votes.vote(1, 20, "down with the system you greedy bastards"); */

    /*     bytes32 expected = "Voted successfully."; */

    /*     Assert.equal(outcome, expected, "FAIL FAIL FAIL"); */

    /* } */


    /* function testHasRole() { */

    /*     //address addrs = DeployedAddresses.Users(); */
    /*     //Users votes = Users(DeployedAddresses.Users.gas(1000)()); */

    /*     uint expected = 1; */
    /*     Assert.equal(votes.hasRole(addr, "insurance", "admin"), expected, "Ad is niet admin."); */

    /* } */

    /* function testChangeRole() { */

    /*     votes.setRole(addr, "insurance", "admin", 2); */

    /*     uint expected = 2; */
    /*     Assert.equal(votes.hasRole(addr, "insurance", "admin"), expected, "Ad is niet admin."); */


    /* } */
}
