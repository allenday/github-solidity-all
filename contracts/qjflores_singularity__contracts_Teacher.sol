pragma solidity ^0.4.6;

import "./User.sol";
import "./Course.sol";

contract Teacher {
  address userAddress;
  address[] public courses;

  function Teacher(address _userAddress) {
    userAddress = _userAddress;
  }
  function getCourseCount() public constant returns(uint) {
      return courses.length;
  }

  function createCourse(string _name, string _description,uint256 _rate) returns (address){
    Course newCourse = new Course(_name, _description, _rate);
    courses.push(address(newCourse));
  }

  function updateCourseRate(address _courseAddress, uint256 _rate) {
    Course course = Course(_courseAddress);
    course.updateRate(_rate);
  }
}
