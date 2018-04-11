pragma solidity ^0.4.2;

contract testSmartContract {

  event TestEvent (
    string someEventString
  );

  string testString;

  function testSmartContract (string _testString) {
    testString = _testString;
  } 

  function getConstructorString () constant returns (string) {
    return testString;
  }

  function triggerTestEvent () {
    TestEvent("This is a test string from the event");
  }
}
