pragma solidity ^0.4.6;

import "./Provider.sol";
//import "./User.sol";

contract Course is Provider {
  address public teacher;
  uint256 public rate;

  mapping (address => Student) students;
  Student[] public studentList;

  struct Student {
    bool active;
  }

  function Course(string _name, string _description ,uint256 _rate) Provider("_name", "_description"){
    providerName = _name;
    description = _description;
    rate = _rate;
    teacher = msg.sender;
    addStaff(msg.sender);
  }

  function updateRate(uint256 _rate) {
    if (msg.sender!=teacher){
      throw;
    }
    rate = _rate;
  }

  function getStudentCount() public constant returns(uint) {
    return studentList.length;
  }

  function registerStudent(address _userAddress){
    User student = User(_userAddress);
    student.registerToProvider(this);
    students[_userAddress] = Student({active:true});
    studentList.push(students[_userAddress]);
    setDebt(rate, _userAddress);
  }
}