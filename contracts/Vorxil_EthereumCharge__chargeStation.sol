pragma solidity ^0.4.11;

import "owned.sol";

contract ChargeStation is Owned {
	
	mapping(address => uint) balances;
	address charger;
	address station;
	enum State { Idle, Notified, PrepCharging, Charging }
	State state;
	uint chargeStart;
	uint chargeIntervalStart;
	uint chargeIntervalEnd;
	uint chargeEnd;
	uint prepStart;
	uint prepDuration;
	uint totalCharge;
	uint price;
	bool priceLocked;
	
	function ChargeStation(address _station, uint _prepDuration) {
		state = State.Idle;
		charger = address(0);
		chargeStart = 0;
		chargeEnd = 0;
		totalCharge = 0;
		price = 0;
		prepStart = 0;
		prepDuration = _prepDuration*(1 seconds);
		station = _station;
		priceLocked = false;
	}
	
	modifier onlyStation() {
		if (msg.sender == station) {
			_;
		}
	}
	
	modifier onlyCharger() {
		if (msg.sender == charger) {
			_;
		}
	}
	
	event priceUpdated(uint price);
	event chargeDeposited(address from, uint value);
	event fetchPrice();
	event stateChanged(State from, State to);
	event charging(address charger, uint time);
	event consume(address charger, uint consume);
	event chargingStopped(address charger, uint time);
	
	function update(uint _price) onlyStation returns (bool){
		uint time = now;
		if (state == State.Idle) {
			price = _price;
			priceLocked = false;
			charger = address(0);
			priceUpdated(price);
			return true;
		}
		else if (state == State.Notified) {
			if (time <= prepStart + prepDuration) {
				price = _price;
				state = State.PrepCharging;
				prepStart = now;
				priceLocked = true;
				priceUpdated(price);
				stateChanged(State.Notified, State.PrepCharging);
				return true;
			}
			else if (time > prepStart + prepDuration) {
				price = _price;
				state = State.Idle;
				priceLocked = false;
				charger = address(0);
				priceUpdated(price);
				stateChanged(State.Notified, State.Idle);
				return true;
			}
		} else if (state == State.PrepCharging) {
			if (time > prepStart + prepDuration) {
				price = _price;
				state = State.Idle;
				priceLocked = false;
				charger = address(0);
				priceUpdated(price);
				stateChanged(State.PrepCharging, State.Idle);
				return true;
			}
			else {
				return false;
			}
		}
		return false;
	}
	
	function notifyCharge() returns (bool){
		if (state == State.Idle) {
			prepStart = now;
			state = State.Notified;
			charger = msg.sender;
			stateChanged(State.Idle, State.Notified);			
			fetchPrice();
			return true;
		} else if (state == State.Notified && now > prepStart + prepDuration) {
			prepStart = now;
			charger = msg.sender;
			fetchPrice();
			return true;
		} else if (state == State.PrepCharging && now > prepStart + prepDuration) {
			prepStart = now;
			charger = msg.sender;
			state = State.Notified;
			stateChanged(State.Idle, State.Notified);
			fetchPrice();
			return true;
		}
		return false;
	}
	
	function startCharging() onlyCharger returns (bool) {
		uint time = now;
		if (state == State.PrepCharging) {
			if (time < prepStart + prepDuration) {
				totalCharge = 0;
				chargeStart = now;
				chargeIntervalStart = now;
				state = State.Charging;
				stateChanged(State.PrepCharging, State.Charging);
				charging(charger, chargeStart);
				return true;
			} else {
				charger = address(0);
				state = State.Idle;
				stateChanged(State.PrepCharging, State.Idle);
				return false;
			}
		} else {
			return false;
		}
	}
	
	function updatePower(uint power) onlyStation returns (bool) {
		if (state == State.Charging) {
			chargeIntervalEnd = now;
			totalCharge += (chargeIntervalEnd - chargeIntervalStart)*power;
			chargeIntervalStart;
			consume(charger, totalCharge);
			if (totalCharge*price >= balances[charger]) {
				chargeEnd = now;
				balances[owner] += balances[charger];
				balances[charger] = 0;
				chargingStopped(charger, chargeEnd);
				charger = address(0);
				state = State.Idle;
				stateChanged(State.Charging, State.Idle);
			}				
			return true;
		}
		else {
			return false;
		}
	}
	
	function stopCharging() onlyCharger returns (bool){
		if (state == State.Charging) {
			chargeEnd = now;
			chargingStopped(charger, chargeEnd);
			uint cost = totalCharge*price;
			uint amount = balances[charger];
			if (cost > amount) {
				balances[owner] = amount;
				balances[charger] = 0;
			}
			else {
				balances[owner] = cost;
				balances[charger] = amount - cost;
			}
			state = State.Idle;
			stateChanged(State.Charging, State.Idle);
			return true;
		}
		return false;
	}
		
	
	function depositCharge() payable {
		require(msg.sender != address(this));
		require(msg.sender != address(0));
		
		balances[msg.sender] += msg.value;
		
		chargeDeposited(msg.sender, msg.value);
	}
	
	function withdraw() returns (bool) {
		require(!(charger == msg.sender && state == State.Charging));
		uint amount = balances[msg.sender];
		if (amount > 0) {

			balances[msg.sender] = 0;
			if (!msg.sender.send(amount)) {
				balances[msg.sender] = amount;
				return false;
			}
		}
		return true;
	}
}