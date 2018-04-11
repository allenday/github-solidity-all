pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/crowdsale/Crowdsale.sol";
import "zeppelin-solidity/contracts/token/MintableToken.sol";
import "../../contracts/ExternalTokenCrowdsale.sol";


contract ExternalTokenCrowdsaleMock is Crowdsale, ExternalTokenCrowdsale {
    function ExternalTokenCrowdsaleMock(MintableToken token)
        public
        Crowdsale(now, now + 500, 51, msg.sender)
        ExternalTokenCrowdsale(token) 
    {

    }
}
