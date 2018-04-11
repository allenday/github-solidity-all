/*
 * Partial src: https://github.com/eris-ltd/hello-eris/blob/master/contracts/DealManager.sol
 */

import "Task.sol";
import "SequenceArray.sol";

contract TaskManager {

    SequenceArray taskList = new SequenceArray();

    // TODO extend with eventObject if possible; `bytes32[]`?
    event ActionEvent(address indexed userAddr, bytes32 actionType);
    function registerActionEvent(bytes32 actionType) {
      ActionEvent(msg.sender, actionType);
    }

    /**
     * Adds a new task with the specified attributes
     */
    function addTask(
        bytes32 _id,
        bytes32 _title,
        bytes32 _desc,
        bytes32 _status,
        bytes32 _complete,
        bytes32 _reward,
        bytes32 _participants,
        bytes32 _creator,
        bytes32 _createdAt,
        bytes32 _token
        )
        returns (Task t)
    {
        t = new Task(_id, _title, _desc, _status, _complete, _reward, _participants, _creator, _createdAt, _token);

        bool isOverwrite = taskList.insert(_token, t);
        registerActionEvent("ADD TASK");
        // TODO needs a verification of insert success
        return t;
    }

    function getTaskAtIndex(uint _idx) constant returns (address, uint) {
        registerActionEvent("GET TASK AT INDEX");
        return taskList.valueAtIndexHasNext(_idx);
    }

    function getTaskAddress(bytes32 _id) constant returns (address) {
        registerActionEvent("GET TASK ADDRESS");
        return taskList.value(_id);
    }

    function getTaskKeyAtIndex(uint _idx) constant returns (bytes32) {
        return taskList.keyAtIndex(_idx);
    }

    function getTaskFromToken(bytes32 token) constant returns (address) {
        return taskList.value(token);
    }

    function getTaskListSize() constant returns (uint) {
        registerActionEvent("GET TASKLIST SIZE");
        return taskList.size();
    }

    function markTaskCompleted(address taskAddr, bytes32 status) returns (bool) {
        return Task(taskAddr).markComplete(status);
    }
}
