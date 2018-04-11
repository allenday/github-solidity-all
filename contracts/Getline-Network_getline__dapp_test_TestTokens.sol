pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/tokens/PrintableToken.sol";

contract TestTokens {
    function testPrintableToken() public {
        uint256 testPrintValue = 100;
        PrintableToken testToken = new PrintableToken("testTokenName", 0, "testTokenSymbol", testPrintValue);
        Assert.equal(testToken.printValue(), testPrintValue, "It should initialize printValue");
        address someAddressA = 0x123;
        testToken.print(someAddressA);
        Assert.equal(testToken.balanceOf(someAddressA), testPrintValue, "It should print tokens");
        Assert.equal(testToken.totalSupply(), testPrintValue, "It should update the total supply");
        address someAddressB = 0x234;
        testToken.print(someAddressA);
        testToken.print(someAddressB);
        Assert.equal(testToken.balanceOf(someAddressA), testPrintValue * 2, "It should print tokens");
        Assert.equal(testToken.balanceOf(someAddressB), testPrintValue, "It should print tokens");
        Assert.equal(testToken.totalSupply(), testPrintValue * 3, "It should update the total supply");
    }
}
