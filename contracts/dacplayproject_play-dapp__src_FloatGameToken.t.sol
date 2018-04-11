pragma solidity ^0.4.13;

import "ds-test/test.sol";
import "./FloatGameToken.sol";
import "./PLS.sol";

contract FloatGameTokenTest is DSTest {
    FloatGameToken gameToken;
    PLS pls;

    function setUp() {
        pls = new PLS();
        gameToken = new FloatGameToken("TEST", pls);
    }

    function testFail_basic_sanity() {
        assertTrue(false);
    }

    function test_token_creation() {
        // todo
    }
}

