/* An example smart contract that uses BCDB */

pragma solidity ^0.4.4;

contract use_BCDB {
	BCDB database;
	address constant BCDB_address = 0x448e75d45d9cfd0a9c1f5564d27f1b411a2d8c8e;
	uint256 database_id;
	bytes32[2] data_item;
	
	function set_BCDB_contract() {
		database = BCDB(BCDB_address);
	}
	
	function create_all() external {
		database_id = database.create("Trisk", "Coin", "Future");
		//create_table();
		//insert_data();
		//erase_data();
		//update_data();
		//search_data();
	}
	
	function create_table() {
		database_id = database.create("Trisk", "Coin", "Future");
	}
	
	//TODO: check it table exists
	function insert_data() {
		database.insert(database_id, "Etherem", "Chaos!!");
		database.insert(database_id, "Monero", "OMG Zcash is coming!");
		database.insert(database_id, "ZCash", "Who needs me if Monero is here?");
		database.insert(database_id, "Bitcoin", "Heya kids!");
	}
	
	function erase_data(){
		int256 data_item_id = database.search(database_id, "Monero");
		if (data_item_id > -1) {
			database.erase(database_id, 3);
		}
	}
	
	function update_data() {
		int256 data_item_id = database.search(database_id, "Zcash");
		if (data_item_id > -1) {
			database.update(database_id, uint256(data_item_id), "Zcash", "Brilliant math");
		}
	}
	
	function search_data() {
		int256 data_item_id = database.search(database_id, "Zcash");
		if (data_item_id > -1) {
			(data_item[0], data_item[1]) = database.get_data(database_id, uint256(data_item_id));
		}
		(data_item[0], data_item[1]) = database.get_data(database_id, 0);
	}
	
	function get_data_item() constant returns (bytes32, bytes32) {
		return (data_item[0], data_item[1]);
	}
	
	function get_database_id() constant returns (uint256) {
		return database_id;
	}
}

contract BCDB {	
	/* Events and Modifiers */
	event tableCreated(bytes32 name, uint256 index);	
    
    /*                              *
     * External intercace functions *
     *                              */       
    function create(bytes32 name, bytes32 header1, bytes32 header2) external returns (uint256) {}
    function insert(uint256 table_id, bytes32 data1, bytes32 data2) external {}
	function erase(uint256 table_id, uint256 row) external {}
    function update(uint256 table_id, uint256 row, bytes32 data1, bytes32 data2) external {}
    function search(uint256 table_id, bytes32 value) external constant returns (int256) {}
	
	/*                      *
     * Output functions	    *
     *                      */  
	function get_header(uint256 table_ind, uint256 header_id) constant returns (bytes32) {}	
	function get_data(uint256 table_id, uint256 row) constant returns (bytes32, bytes32) {}
	function get_table_size(uint256 table_id) constant returns (uint256) {}
}