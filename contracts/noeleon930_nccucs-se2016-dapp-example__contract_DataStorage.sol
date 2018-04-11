pragma solidity ^0.4.0;

contract DataStorage {
	// 合約部署者、擁有者
	address public owner;

	// 存放的字串資料
	string public data;

	// 當資料被 set 的時候，要發射的事件
	// 這邊包含 是誰改的、改的內容是什麼、是什麼時候改的
	event dataSet(address from, string input, uint timestamp);

	// 建構子，只會部署時跑一次
	function DataStorage() {
		owner = msg.sender;
	}

	// data 的 setter
	function setData(string input) {
		data = input;
		
		// 發射事件
		dataSet(msg.sender, input, now);
	}

	// data 的 getter
	function getData() constant returns (string) {
		return data;
	}
}
