pragma solidity ^0.4.13;

import "ds-test/test.sol";

import "./PLS.sol";

contract TokenEchoDemo {
    function receiveToken(address from, uint256 _amount, address _token)
    {
        // check that the msg.sender _token is equal to token address
        require(msg.sender == _token);
        
        PLS(_token).transfer(from, _amount);
    }
}

contract Nothing {
    // do not have receiveToken API
}

contract ReceiveAndCallFallBackTest is DSTest, TokenController {
    TokenEchoDemo echo;
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
        echo = new TokenEchoDemo();
        pls = new PLS();
        nothing = new Nothing();
    }

    function testFail_basic_sanity() {
        assertTrue(false);
    }

    function test_transfer_token_to_contract() {
        pls.mint(this, 10000);
        pls.transfer(address(echo), 5000);

        assertTrue(pls.balanceOf(this) == 10000);

        pls.transfer(address(nothing), 100);
    }
}

