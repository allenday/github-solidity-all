contract ManagerContract {

	struct Transaction {
		address consumer;
		uint dt_start;
		uint dt_end;
		uint cost;
		bytes32 hash_id;
	}

	struct Owner {
		address addr;
	}

	struct Sensor {
		uint sensor_id;
		uint dt_start;
		uint dt_end;
		uint fee;
	}

	Owner owner;

	mapping (uint => Sensor) public sensors;
	mapping (address => Transaction) public transactions;
	mapping (address => uint) public consumer_balance;

	function ManagerContract() {
		owner.addr = msg.sender;
	}

	function createSensor(uint sensor_id, uint fee, uint dt_start) public returns (bool) {
		Sensor sen = sensors[sensor_id];
		sen.sensor_id = sensor_id;
		sen.dt_start = dt_start;
		sen.dt_end = dt_start;
		sen.fee = fee;
		sensors[sensor_id] = sen;
		return true;
	}

	function createData(uint sensor_id, uint timestamp) returns (bool) {
		Sensor sensor = sensors[sensor_id];
		sensor.dt_end = timestamp;
		sensors[sensor_id] = sensor;
		return true;
	}

	function performTransaction (address who, bytes32 hash_id) public returns (bool) {
		
		if (msg.sender != owner.addr) {
			return false;
		}

		Transaction transaction = transactions[who];

		consumer_balance[who] = consumer_balance[who] - transaction.cost;

		owner.addr.send(transaction.cost);

		if (transaction.consumer.balance != 0) {
			who.send(consumer_balance[who]);
		}
		delete transactions[who];
		delete consumer_balance[who];
		return true;
	}

	function holdTransaction(uint sensor_id, uint start_time, uint end_time) external returns (bytes32 result) {
		Sensor sensor = sensors[sensor_id];
		if (end_time < start_time) {
			return 0;
		}

		if (sensor.dt_start > start_time || sensor.dt_end < end_time) {
			return 0;
		}

		uint cost = (end_time - start_time) * sensor.fee;

		if (cost > msg.value) {
			return 0;
		}

		result = sha3(msg.sender, start_time, end_time);

		Transaction transaction = transactions[msg.sender];
		transaction.consumer = msg.sender;
		transaction.dt_start = start_time;
		transaction.dt_end = end_time;
		transaction.cost = cost;
		transaction.hash_id = result;

		transactions[msg.sender] = transaction;
		consumer_balance[msg.sender] = msg.value;
	}

	//Сделать у транзакций срок исполнения и проверку на устаревшие транзакции, если срок вышел, вернуть деньги
}               