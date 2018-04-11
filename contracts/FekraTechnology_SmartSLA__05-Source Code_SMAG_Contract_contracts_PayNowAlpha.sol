pragma solidity ^0.4.2;
import "HelperLib.sol";

contract PayNowAlpha {
		//Task Record Data structure
		struct previousStates {
			string newState;
			string oldState;
			string timestamp;
		}

		struct taskRecord {
			address requester;//requester address (mapped to user sys_id in servicenow)
			address fulfiller;//fulfiller address (mapped to user sys_id in servicenow)
			uint priority;//priority enum
			string currentState;//current state enum
			string stateUpdatedOn;//state last update timestamp
			string createdOn;//creation timestamp
			string taskUpdatedOn;//last update timestamp
			uint deposit;//need an array of structures to hold deposits?

			previousStates[] prevStates;//array of states changes
		}


		struct taskState{
		}

	mapping (string => taskRecord) public tasks;

	uint public numOfIncs;

	//create a new task
	//this will come for a taskDecomposition module, where a single request creates multiple tasks
	function createTask(address requester, string sys_id, string createdOn, uint priority) constant returns(bool success){
		tasks[sys_id].requester = requester;
		tasks[sys_id].createdOn = createdOn;
		tasks[sys_id].currentState = "open";
		tasks[sys_id].deposit = calculateTaskDeposit(priority);

		numOfIncs += 1;

		return true;
	}

	//calculate task deposit based on: priority
	//TODO: lookup agreement costing model to determine task deposit based on priority
	//TODO: what else do we need to calculate the deposit?
	function calculateTaskDeposit(uint priority) constant returns(uint depositAmount){
		if (priority == 1) return 9;
		else if (priority == 2) return 8;
		else if (priority == 3) return 7;
		else return 0;
	}

	//update the state of an open task
	function updateTaskState(string sys_id, string newState) constant returns(bool success){
		tasks[sys_id].previousStates.push(tasks[sys_id].currentState);
		tasks[sys_id].currentState = newState;
		tasks[sys_id].stateUpdatedOn = "11:11:11";//now;
		return true;
		//TODO need to couple state canges with timestamps, mapping?
	}

	//read number of open tasks
	function readOpentasks() constant returns(uint) {
		return numOfIncs;
	}

	//read an open task state
	function readTaskState(string _sys_id) constant returns(string) {
		return tasks[_sys_id].currentState;
	}

	//read an open task timestamp
	function readTaskCreatedOn(string _sys_id) constant returns(string) {
		return tasks[_sys_id].createdOn;
	}
	//read an open task timestamp
	function readIncUpdatedOn(string _sys_id) constant returns(string) {
		return tasks[_sys_id].stateUpdatedOn;
	}

}
