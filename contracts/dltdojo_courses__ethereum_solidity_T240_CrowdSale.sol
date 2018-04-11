pragma solidity ^0.4.14;
// 
// CrowdSale v.s. CrowdFunding (T018) 
// Token v.s. Ether (balance)
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/crowdsale/Crowdsale.sol

import "github.com/OpenZeppelin/zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";

contract User { 
    function info() constant returns (address _address, uint _balance){
        _address = this;
        _balance = this.balance;
    }

    // solidity - send VS call - differences and when to use and when not to use - Ethereum Stack Exchange 
    // https://ethereum.stackexchange.com/questions/6470/send-vs-call-differences-and-when-to-use-and-when-not-to-use
    function buyTokens(Crowdsale crowdsale, uint weiAmount){
        // 
        // https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/crowdsale/Crowdsale.sol#L79
        // update state
        // weiRaised = weiRaised.add(weiAmount);
        // gsa issue
        // crowdsale.transfer(weiAmount);
        // call directly to crowdsale's fallback function
        crowdsale.call.value(weiAmount)();
    }
    function() payable{}
}

contract FooCrowdsale {
    
    // fallback 100 ether
    function() payable{}
    
    User public alice = new User();
    Crowdsale public crowdsale;
    // MintableToken public token;
    
    function test01CrowdsaleInit(){
        uint256 startTime = now + 5 seconds;
        uint256 endTime = now + 20 minutes;
        // how many token units a buyer gets per wei
        // calculate token amount to be created
        // uint256 tokens = weiAmount.mul(rate);
        uint256 rate = 100 ; 
        address wallet = msg.sender;
        crowdsale = new Crowdsale(startTime, endTime, rate, wallet);
    }
    
    // User at alice address
    // check alice.info()
    // Crowdsale instance
    // call crowdsale() fallback with 9 ether by account0
    // MintableToken at token address
    // check balanceOf(account0)
    
    function test02BuyToken() {
        crowdsale.call.value(0.345 ether)();
        MintableToken token = crowdsale.token();
        require(token.balanceOf(this) == 34.5 ether);
    }
    
    function test03AliceBuyToken() {
        alice.transfer(1 ether);
        require(alice.balance == 1 ether);
        alice.buyTokens(crowdsale, 0.168 ether);
        MintableToken token = crowdsale.token();
        require(token.balanceOf(alice) == 16.8 ether);
    }
    
}
