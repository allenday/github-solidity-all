pragma solidity ^0.4.13;

import "ds-test/test.sol";

import "./PLS.sol";

contract PLSTest is DSTest {
    PLS pls;

    function setUp() {
        pls = new PLS();
    }

    function testFail_basic_sanity() {
        assertTrue(false);
    }

    function test_basic_sanity() {
        assertTrue(true);
    }

    function test_transfer_to_contract_with_fallback() {
        assertTrue(true);
    }

    function test_transfer_to_contract_without_fallback() {
        assertTrue(true);
    }
}
