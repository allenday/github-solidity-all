contract SplitPayment {
	address payee1;
	address payee2;

	function SplitPayment(address address1, address address2) {
		payee1 = address1;
		payee2 = address2;
	}

	function kill() {
		if (msg.sender == payee1) {
			selfdestruct(payee1);
		}

		if (msg.sender == payee2) {
			selfdestruct(payee2);
		}
	}

	function() {
		uint remainder = msg.value / 2;
		payee1.send(msg.value - remainder);
		payee2.send(remainder);
	}
}
