pragma solidity ^0.4.13;

import "ds-test/test.sol";

import "./PlayDapp.sol";

contract PlayDappTest is DSTest {
    PlayDapp dapp;

    function setUp() {
        dapp = new PlayDapp();
    }

    function testFail_basic_sanity() {
        assertTrue(false);
    }

    function test_basic_sanity() {
        assertTrue(true);
    }
}
