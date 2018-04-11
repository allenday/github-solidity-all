pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Token.sol";
import "../contracts/ContractCallerProxy.sol";

// Note: Start TestRPC with the following arguments to prevent the Contract Owner's account from running out of Ether / the tests failing because of an Out of Gas exception:
// testrpc --gasLimit 0x57E7C4 --gasPrice 2
contract TestToken_Transfer {

    function testInitialBalanceUsingDeployedContract() {
        Token token = Token(DeployedAddresses.Token());

        uint expected = 100;

        Assert.equal(token.balanceOf(msg.sender), expected, "Owner should have 100 Tokens initially");
    }

    uint256 private initialAmount = 10000100110000101110010;
    Token private token = new Token(initialAmount, "ContractOwnedToken", 0, "*");
    address private _thisAddress = address(this);

    function testDeployNewTokenWithTheTestContractAsOwner() {
        Assert.equal(initialAmount, token.balanceOf(_thisAddress), "Expected the Test Contract's address to contain all of the tokens created");
    }

    event LogEvent(uint message);

    /******************** Transfer function tests ********************/

    // It should be possible for the contract owner to transfer fewer tokens than are available in the contract owner's address to another account's address.
    function testTransferCorrectlySendsTokens() {
        // Setup
        uint fromAddressOriginalBalance = token.balanceOf(_thisAddress);
        address destinationAddress = 0x0;
        uint destinationAddressOriginalBalance = token.balanceOf(destinationAddress);

        Assert.equal(initialAmount, fromAddressOriginalBalance, "Owner account should have started with the original number of tokens.");
        Assert.equal(0, destinationAddressOriginalBalance, "Destination account should have started with 0 tokens.");

        uint amountToSend = 10;

        // Test
        token.transfer(destinationAddress, amountToSend);

        // Verify
        Assert.equal(fromAddressOriginalBalance - amountToSend, token.balanceOf(_thisAddress), "Owner account should have been decremented by the expected amount");
        Assert.equal(destinationAddressOriginalBalance + amountToSend, token.balanceOf(destinationAddress), "Destination address should have received the expected amount of tokens.");
    }

    // It should not be possible for the contract owner to transfer more tokens than are available in the contract owner's address.
    function testTransferHandlesTooLargeRequest() {
        // Setup
        uint fromAddressOriginalBalance = token.balanceOf(_thisAddress);
        address destinationAddress = 0x1;
        uint destinationAddressOriginalBalance = token.balanceOf(destinationAddress);

        Assert.equal(0, destinationAddressOriginalBalance, "Destination account should have started with 0 tokens.");

        uint tooLargeAmount = fromAddressOriginalBalance + 1;
        // Test
        token.transfer(destinationAddress, tooLargeAmount);

        // Verify
        Assert.equal(fromAddressOriginalBalance, token.balanceOf(_thisAddress), "Owner account should have the same number of tokens.");
        Assert.equal(0, token.balanceOf(destinationAddress), "Destination address should not have received any tokens.");
    }

    // It should not be possible for the cotract owner to send a negative number of tokens.
    function testTransferHandlesNegativeAmountRequest() {
        // Setup
        uint fromAddressOriginalBalance = token.balanceOf(_thisAddress);
        address destinationAddress = 0x2;
        uint destinationAddressOriginalBalance = token.balanceOf(destinationAddress);

        Assert.equal(0, destinationAddressOriginalBalance, "Destination account should have started with 0 tokens.");

        int negativeAmount = -1;
        // Test
        token.transfer(destinationAddress, uint(negativeAmount));

        // Verify
        Assert.equal(fromAddressOriginalBalance, token.balanceOf(_thisAddress), "Owner account should have the same number of tokens.");
        Assert.equal(0, token.balanceOf(destinationAddress), "Destination address should not have received any tokens.");
    }

    function testTransferTokensUsingRawCall() {
        // Setup
        uint fromAddressOriginalBalance = token.balanceOf(_thisAddress);
        address destinationAddress = 0x3;
        uint destinationAddressOriginalBalance = token.balanceOf(destinationAddress);

        Assert.equal(0, destinationAddressOriginalBalance, "Destination account should have started with 0 tokens.");

        uint256 amountToSend = 5;

        // Test
        bool result = token.call(bytes4(keccak256("transfer(address,uint256)")), destinationAddress, amountToSend);

        Assert.equal(true, result, "Expected that no exception was thrown by the transfer function");

        // Verify
        Assert.equal(fromAddressOriginalBalance - amountToSend, token.balanceOf(_thisAddress), "Owner account should have been decremented by the expected amount");
        Assert.equal(destinationAddressOriginalBalance + amountToSend, token.balanceOf(destinationAddress), "Destination address should have received the expected amount of tokens.");
    }
}