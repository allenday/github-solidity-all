pragma solidity ^0.4.15;

import './Paper.sol';

contract EthJournal {

	mapping (address => bool) public isAuthors;
	address[] authors;
	mapping (address => bool) public isEditors;
	address[] editors;
	mapping (address => address[]) usersPapers;
	address[] papers;

	event log(address user);

	function authorSignUp(address user) returns (bool) {
		log(user);
		require(!isAuthors[user]);
		log(user);
		isAuthors[user] = true;
		authors.push(user);
		log(user);
		return true;
	}

	function editorSignUp(address user) returns (bool) {
		require(!isEditors[user]);
		isEditors[user] = true;
		editors.push(user);
		return true;
	}

	function createPaper(string _title, uint _paperUID, uint _price) returns (Paper) {
		address editor = editors[uint(block.blockhash(block.number)) % editors.length];
		Paper newPaper = new Paper(_title, editor, _paperUID, _price, authors, this);
		return newPaper;
	}

	function addPaper(address _paper) returns (bool) {
		usersPapers[Paper(_paper).author()].push(_paper);
		papers.push(_paper);
		return true;
	}

}
