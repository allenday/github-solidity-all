pragma solidity ^0.4.4;
import './Lesson.sol';
import 'dao/Core.sol';

contract Lesson_5 is Lesson {
    function Lesson_5(address _dealer, uint _reward)
             Lesson(_dealer, _reward) {}
    
    function execute(string _token_name, Core _dao) {
        if (_dao.get(_token_name) != 0)
            passed(msg.sender);
    }
}
