pragma solidity ^0.4.4;
import './Lesson.sol';
import 'dao/ShareSale.sol';

contract Lesson_4 is Lesson {    
    function Lesson_4(address _dealer, uint _reward) 
             Lesson(_dealer, _reward) {}
    
    function execute(ShareSale _shareSale) {
        if (_shareSale.closed() > 0)
            passed(msg.sender);
    }
}
