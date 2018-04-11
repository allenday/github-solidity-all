/**
 *  Relay.sol v1.0.0
 * 
 *  Bilal Arif - https://twitter.com/furusiyya_
 *  Notary Platform
 */

pragma solidity ^0.4.16;

// Used for accepting small contributions without whitelist

import 'Pausable.sol';

contract Relay is Pausable{
  
    address private crowdfunding;
    
    function Relay() 
        Ownable(0x0587e235a5906ed8143d026de530d77ad82f8a92){
        crowdfunding = 0x34a3DeB32b4705018F1e543A5867cF01AFf3F15B;
    }
    
    function () payable isMinimum whenNotPaused{
        crowdfunding.transfer(msg.value);
    }
    
    /** Modifier allowing execution only if received value is greater than zero */
    modifier isMinimum(){
        require(msg.value <= 2 ether);
        _;
    }
}