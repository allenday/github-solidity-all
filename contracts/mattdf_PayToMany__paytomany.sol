pragma solidity ^0.4.0;

contract PayMany {

	event PaymentSuccess(
		address payee,
		uint value
	);

	event PaymentFailure(
		address payee,
		uint value
	);

	function PayXToList(address[] list, uint value) public payable {

		// do some overflow checks and bounds checks
		if ((value * list.length) > msg.value || value < (value * list.length) || value > msg.value)
			throw;

		for (uint i = 0; i < list.length; i++){
			if (!list[i].send(value)){
				PaymentFailure(list[i], value);
			}
			else {
				PaymentSuccess(list[i], value);
			}
		}


		msg.sender.transfer(this.balance);

	}

	function PayValsToList(address[] list, uint[] values) public payable {

		for (uint i = 0; i < list.length; i++){
			if (!list[i].send(values[i])){
				PaymentFailure(list[i], values[i]);
			}
			else {
				PaymentSuccess(list[i], values[i]);
			}
		}


		msg.sender.transfer(this.balance);

	}


}
