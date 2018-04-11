pragma solidity ^0.4.4;
import './Lesson.sol';
import 'dao/Core.sol';

contract Lesson_1 is Lesson {
    function Lesson_1(address _dealer, uint _reward)
             Lesson(_dealer, _reward) {}

    function execute(Core _dao) {
        // Check when DAO is created
        if (_dao.owner() == msg.sender)
            passed(msg.sender);
    }
}
