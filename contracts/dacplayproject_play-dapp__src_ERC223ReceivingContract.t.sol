pragma solidity ^0.4.13;

import "ds-test/test.sol";

import "./PLS.sol";
import "./ERC223ReceivingContract.sol";
// import "ds-token/token.sol";

contract TokenReceivingEchoDemo {

    PLS pls;

    function TokenReceivingEchoDemo(address _token)
    {
        pls = PLS(_token);
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public
    {
        // check that the msg.sender _token is equal to token address
        require(msg.sender == address(pls));
        
        pls.transfer(_from, _value);
    }
}

contract Nothing {
    // do not have receiveToken API
}

contract ERC223ReceivingContractTest is DSTest, TokenController {
    TokenReceivingEchoDemo echo;
    PLS pls;
    Nothing nothing;

    function proxyPayment(address _owner) payable returns(bool){
        return true;
    }

    function onTransfer(address _from, address _to, uint _amount) returns(bool){
        return true;
    }

    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool)
    {
        return true;
    }

    function setUp() {
        pls = new PLS();
        echo = new TokenReceivingEchoDemo(address(pls));
        nothing = new Nothing();
    }

    function testFail_basic_sanity() {
        assertTrue(false);
    }

    function test_token_fall_back() {
        pls.mint(this, 10000);
        pls.transfer(address(echo), 5000, "");

        assertTrue(pls.balanceOf(this) == 10000);

        pls.transfer(address(nothing), 100);
    }
}

