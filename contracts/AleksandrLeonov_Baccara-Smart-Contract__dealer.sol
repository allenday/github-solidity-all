pragma solidity ^0.4.11;


contract Dealer {
    address owner;

    function Dealer() {
        owner = msg.sender;
    }

    function deal() constant external returns(uint) {
        uint a = 1093;
        uint c = 18257;
        uint m = 86436;

        // uint s = (a * block.number + c) % m;
        uint s = (a * block.timestamp + c) % m;
        return s % 416;
    }

    function close() {
        if(msg.sender == owner) {
            selfdestruct(owner);
        }
    }
}
