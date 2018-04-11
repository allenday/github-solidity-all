pragma solidity ^0.4.4;
import './Lesson.sol';
import 'foundation/Congress.sol';

contract Lesson_6 is Lesson {
    function Lesson_6(address _dealer, uint _reward)
             Lesson(_dealer, _reward) {}
    
    function execute(Congress _congress) {
        if(_congress.numProposals() > 0) {
            passed(msg.sender);
        }
    }
}
