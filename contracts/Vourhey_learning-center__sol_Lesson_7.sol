pragma solidity ^0.4.4;
import './Lesson.sol';
import 'foundation/Crowdfunding.sol';

contract Lesson_7 is Lesson {
	function Lesson_7(address _dealer, uint _reward) 
		     Lesson(_dealer, _reward) {}
	
    function execute(Crowdfunding _crowdfunding) {
		if (_crowdfunding.totalFunded() > 0)
            passed(msg.sender);
    }
}
