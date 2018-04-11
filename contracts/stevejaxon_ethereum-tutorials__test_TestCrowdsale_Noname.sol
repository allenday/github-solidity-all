pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Crowdsale.sol";
import "../contracts/Token.sol";
import "../contracts/ContractCallerProxy.sol";

contract TestCrowdsale_Noname {
    event LogEvent(address message);

    // Grab the address of the contract that creates the test contract - so that we can seed the test contract with Ether.
    address private owner;
    function TestCrowdsale_Noname() {
        owner = msg.sender;
    }


    uint256 private tokenIssuance = 1000;
    Token private crowdsaleToken = new Token(tokenIssuance, "CrowdsaleToken", 0, "*");
    address private _thisAddress = address(this);
    uint private totalEtherToRaise = 1000;
    uint private costOfEachTokenInEther = 1;
    uint private durationOfCrowdsaleInMinutes = 1;

    // Note: we have to cast the address of the crowdsaleToken contract into a 'token' that is understood by the Crowdsale contract
    Crowdsale private crowdsale = new Crowdsale(_thisAddress, totalEtherToRaise, durationOfCrowdsaleInMinutes, costOfEachTokenInEther, token(address(crowdsaleToken)));

    function testCanSendEthToContractWhenCrowdsaleInProgress() {
        // Setup
        uint tokenPrice = crowdsale.price();
        Assert.isTrue(tokenPrice > 0, "Expected that the price of a token in the crowdsale would be > 0.");
        uint amountOfEtherToSend = tokenPrice;
        uint256 initialTokenBalance = crowdsale.balanceOf(_thisAddress);
        Assert.equal(0, initialTokenBalance, "Expected the balance for the test contract's address to have no tokens to start of with.");
        uint initialAmountRaised = crowdsale.amountRaised();
        Assert.equal(0, initialAmountRaised, "Expected that the initial amount raised would be 0");

        // Test
        bool transferSuccessful = address(crowdsale).send(amountOfEtherToSend);
        //Assert.isTrue(transferSuccessful, "Expected that the transfer of Ether to the crowdsale contract to complete successfully.");

        // Verify
        //Assert.equal(initialTokenBalance + (amountOfEtherToSend/tokenPrice), crowdsale.balanceOf(_thisAddress), "Expected that the test contract address would have been awarded tokens for sending Ether to the crowdsale contract");
        //Assert.equal(initialAmountRaised + amountOfEtherToSend, crowdsale.amountRaised(), "Expected that the amount raised would have been increased by the amount sent to the crowdsale contract.");
    }

    // nameReg.call("register", "MyName");
    // nameReg.call(bytes4(keccak256("fun(uint256)")), a);
    // foo.value()()
    // msg.sender.call.value(this.balance)()
    // callcode
    // delegatecall
    // sendTransaction
    // sendTransactionRaw
}