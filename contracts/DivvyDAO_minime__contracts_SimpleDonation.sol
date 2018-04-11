//pragma solidity ^0.4.1
import "MiniMeToken.sol";
contract Donate {
    address public owner = msg.sender;
    uint public totalCollected; 
    uint price = 1;
    MiniMeToken token; // minime token contract address
    
    function setMiniMeToken(address addr) {
        if (msg.sender != addr ) throw;
        token = MiniMeToken(addr);
    }
    function donate() returns (bool) {
        if (msg.value > 0) {
            if (token.transferFrom(owner, msg.sender, msg.value*price)) {
                owner.send(msg.value);
                return true;
            }
        }
        return false;
    }
}