pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Token.sol";
import "../contracts/ContractCallerProxy.sol";

// Note: Start TestRPC with the following arguments to prevent the Contract Owner's account from running out of Ether / the tests failing because of an Out of Gas exception:
// testrpc --gasLimit 0x57E7C4 --gasPrice 2
contract TestToken_TransferFrom {

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

    /******************** transferFrom function tests ********************/

    // It should be possible to transfer from the contract owner's address the exact amount approved.
    function testTransferFromCorrectlyAllowsDelegationOfTokenOwnership() {
        // Setup
        uint fromAddressOriginalBalance = token.balanceOf(_thisAddress);

        ContractCallerProxy contractCaller = new ContractCallerProxy(address(token));
        address destinationAddress = address(contractCaller);
        uint destinationAddressOriginalBalance = token.balanceOf(destinationAddress);

        Assert.equal(0, destinationAddressOriginalBalance, "Destination account should have started with 0 tokens.");

        uint256 amountApproved = 10;

        // Test
        token.approve(destinationAddress, amountApproved);

        Token(address(contractCaller)).transferFrom(_thisAddress, destinationAddress, amountApproved);
        bool result = contractCaller.execute.gas(200000)();
        Assert.isTrue(result, "Did not expect an exception to be thrown by the call to the transferFrom function.");

        // Verify
        Assert.equal(fromAddressOriginalBalance - amountApproved, token.balanceOf(_thisAddress), "Owner account should have been decremented by the expected amount");
        Assert.equal(destinationAddressOriginalBalance + amountApproved, token.balanceOf(destinationAddress), "Destination address should have received the expected amount of tokens.");
    }

    // It should not be possible to transfer more tokens than have been approved from the contract owner's address.
    function testTransferFromDoesNotAllowTransferOfMoreThanAllowedByDelegate() {
        // Setup
        uint fromAddressOriginalBalance = token.balanceOf(_thisAddress);

        ContractCallerProxy contractCaller = new ContractCallerProxy(address(token));
        address destinationAddress = address(contractCaller);
        uint destinationAddressOriginalBalance = token.balanceOf(destinationAddress);

        Assert.equal(0, destinationAddressOriginalBalance, "Destination account should have started with 0 tokens.");

        uint256 amountApproved = 10;
        uint256 amountAttemptedToSend = 11;

        // Test
        token.approve(destinationAddress, amountApproved);

        Token(address(contractCaller)).transferFrom(_thisAddress, destinationAddress, amountAttemptedToSend);
        bool result = contractCaller.execute.gas(200000)();
        Assert.isTrue(result, "Did not expect an exception to be thrown by the call to the transferFrom function.");

        Assert.equal(fromAddressOriginalBalance, token.balanceOf(_thisAddress), "Owner account should have the same number of tokens.");
        Assert.equal(0, token.balanceOf(destinationAddress), "Destination address should not have received any tokens.");
    }

    // It should not be possible to the transfer any Tokens using an account that has not been approved.
    function testTransferFromDoesNotAllowTransferByAddressThatHasNotBeenApproved() {
        // Setup
        uint fromAddressOriginalBalance = token.balanceOf(_thisAddress);

        ContractCallerProxy contractCaller = new ContractCallerProxy(address(token));
        address destinationAddress = address(contractCaller);
        uint destinationAddressOriginalBalance = token.balanceOf(destinationAddress);

        Assert.equal(0, destinationAddressOriginalBalance, "Destination account should have started with 0 tokens.");

        uint256 amountAttemptedToSend = 1;

        // Test
        Token(address(contractCaller)).transferFrom(_thisAddress, destinationAddress, amountAttemptedToSend);
        bool result = contractCaller.execute.gas(200000)();
        Assert.isTrue(result, "Did not expect an exception to be thrown by the call to the transferFrom function.");

        Assert.equal(fromAddressOriginalBalance, token.balanceOf(_thisAddress), "Owner account should have the same number of tokens.");
        Assert.equal(0, token.balanceOf(destinationAddress), "Destination address should not have received any tokens.");
    }

    // It should not be possible to transfer more tokens than are available from the contract owner's address, even if more have been approved.
    function testTransferFromDoesNotAllowTransferOfMoreThanExistingTokensByDelegate() {
        // Setup
        uint fromAddressOriginalBalance = token.balanceOf(_thisAddress);

        ContractCallerProxy contractCaller = new ContractCallerProxy(address(token));
        address destinationAddress = address(contractCaller);
        uint destinationAddressOriginalBalance = token.balanceOf(destinationAddress);

        Assert.equal(0, destinationAddressOriginalBalance, "Destination account should have started with 0 tokens.");

        uint amountApproved = fromAddressOriginalBalance+1;

        // Test
        token.approve(destinationAddress, amountApproved);

        Token(address(contractCaller)).transferFrom(_thisAddress, destinationAddress, amountApproved);
        bool result = contractCaller.execute.gas(200000)();
        Assert.isTrue(result, "Did not expect an exception to be thrown by the call to the transferFrom function.");

        Assert.equal(fromAddressOriginalBalance, token.balanceOf(_thisAddress), "Owner account should have the same number of tokens.");
        Assert.equal(0, token.balanceOf(destinationAddress), "Destination address should not have received any tokens.");
    }
}