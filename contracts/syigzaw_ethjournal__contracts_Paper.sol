pragma solidity ^0.4.15;

import './EthJournal.sol';

contract Paper {

	enum Stages {
		submittedForPeerReview,
		peerReviewed,
		peerReviewsAcceptedByEditor,
		resubmittedForPeerReview,
		published,
		rejected
	}

	Stages public stage;
	string public title;
	address public author;
	address public editor;
	mapping (address => bool) isPeerReviewer;
	address[] isPeerReviewerArray;
	mapping (address => bool) peerReviewerTracker;
	uint public peerReviewsToSubmit;
	uint public paperUID;
	uint public price;
	address public ethjournal;
	mapping (address => bool) public reader;
	address[] nonDeletedPeerReviewerArray;

	function Paper(string _title, address _editor, uint _paperUID, uint _price, address[] allAuthors, address _ethjournal) public {
		author = tx.origin;
		title = _title;
		editor = _editor;
		paperUID = _paperUID;
		price = _price;
		ethjournal = EthJournal(_ethjournal);
		while (peerReviewsToSubmit != 2) {
		    isPeerReviewerArray.push(allAuthors[(uint(block.blockhash(block.number)) + peerReviewsToSubmit) % allAuthors.length]);
		    peerReviewsToSubmit++;
		}
		for (uint i = 0; i < peerReviewsToSubmit; i++) {
		    isPeerReviewer[isPeerReviewerArray[i]] = true;
		    peerReviewerTracker[isPeerReviewerArray[i]] = true;
		}
		stage = Stages.submittedForPeerReview;
	}

	function submitPeerReview() public returns (bool) {
		require(peerReviewerTracker[msg.sender] && stage == Stages.submittedForPeerReview);
		peerReviewerTracker[msg.sender] = false;
		peerReviewsToSubmit--;
		if (peerReviewsToSubmit == 0) {
		    stage = Stages.peerReviewed;
		}
	}

	function deleteOwnPeerReview() public returns (bool) {
		require(isPeerReviewer[msg.sender] && stage == Stages.submittedForPeerReview);
		isPeerReviewer[msg.sender] = false;
		peerReviewerTracker[msg.sender] = false;
		peerReviewsToSubmit--;
		if (peerReviewsToSubmit == 0) {
		    stage = Stages.peerReviewed;
		}
	}

	function deletePeerReview(address _peerReviewer) public returns (bool) {
		require(msg.sender == editor && stage == Stages.submittedForPeerReview);
		isPeerReviewer[_peerReviewer] = false;
		peerReviewerTracker[_peerReviewer] = false;
		peerReviewsToSubmit--;
		if (peerReviewsToSubmit == 0) {
		    stage = Stages.peerReviewed;
		}
	}

	function publish() public returns (bool) {
		require(msg.sender == editor && stage == Stages.peerReviewed);
		stage = Stages.published;
		EthJournal(ethjournal).addPaper(this);
	}

	function reject() public returns (bool) {
		require(msg.sender == editor && (stage == Stages.peerReviewed || stage == Stages.submittedForPeerReview));
		stage = Stages.rejected;
	}

	function revise() public returns (bool) {
		require(msg.sender == editor && stage == Stages.peerReviewed);
		stage = Stages.submittedForPeerReview;
	}

	modifier costs() {
		if (msg.value >= price) {
			_;
		}
	}

	function buy() public payable costs returns (bool) {
		require(stage == Stages.published);
		author.transfer(msg.value/2);
		editor.transfer(msg.value/4);
		for (uint i = 0; i < isPeerReviewerArray.length; i++) {
			if (isPeerReviewer[isPeerReviewerArray[i]]) {
				nonDeletedPeerReviewerArray.push(isPeerReviewerArray[i]);
			}
		}
		for (uint peerReviewer = 0; peerReviewer < nonDeletedPeerReviewerArray.length; peerReviewer++) {
			nonDeletedPeerReviewerArray[peerReviewer].transfer(msg.value/(4*nonDeletedPeerReviewerArray.length));
		}
		reader[msg.sender] = true;
		return true;
	}

	function read() public returns (bool) {
		require(reader[msg.sender]);
		return true;
	}

	function() public payable {}

}
