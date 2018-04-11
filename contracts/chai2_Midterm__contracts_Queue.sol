pragma solidity ^0.4.15;

/**
 * @title Queue
 * @dev Data structure contract used in `Crowdsale.sol`
 * Allows buyers to line up on a first-in-first-out basis
 * See this example: http://interactivepython.org/courselib/static/pythonds/BasicDS/ImplementingaQueueinPython.html
 */

contract Queue {
	/* State variables */
	uint8 size = 5;
	// YOUR CODE HERE
	address[] list;
	mapping(address => uint) beginBlockNum;
	/* number of blocks within which you are allowed to participate */
	uint time;
	/* Add events */
	event Boot(
		address booted
		);
	/* Include an event to log an error?*/

	/* Add constructor */
	// YOUR CODE HERE
	/* Ideally, you would be allowed to submit a queue size */
	function Queue(uint _time) {
		time = _time;
	}

	/* Returns the number of people waiting in line */
	function qsize() constant returns(uint) {
		return list.length;
	}

	/* Returns whether the queue is empty or not */
	function empty() constant returns(bool) {
		if (qsize() == 0) {
			return true;
		}
		return false;
	}

	/* Returns the address of the person in the front of the queue */
	function getFirst() constant returns(address) {
		if (!empty()){
			return list[0];
		}
	}

	/* Allows `msg.sender` to check their position in the queue
	   -1 indicates that they are not in the queue */
	function checkPlace() constant returns(bool) {
		for (uint i = 0; i < size; i ++){
			if (list[i] == msg.sender){
				return true;
			} else {
				return false;
			}
		}
		
	}

	/* Allows anyone to expel the first person in line if their time
	 * limit is up
	 */
	function checkTime() {
		if ((block.number - beginBlockNum[getFirst()]) > time){
			dequeue();
		}
	}

	/* Removes the first person in line; either when their time is up or when
	 * they are done with their purchase
	 */
	function dequeue() {
		for (uint i = 1; i < size-1; i ++) {
			list[i-1] = list[i];
		}
		address first = getFirst();
		beginBlockNum[first] = block.number;
	}

	/* Places `addr` in the first empty position in the queue */
	function enqueue(address addr) {
		if (qsize() < 5){
			list.push(addr);
		}
		if (checkPlace()){
			beginBlockNum[addr] = block.number;
		}
	}
}