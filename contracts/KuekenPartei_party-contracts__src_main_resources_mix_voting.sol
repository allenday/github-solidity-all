/*
*
*(c) 2016 KUEKeN
* Urs Zeidler
*
*/
pragma solidity ^0.4.1;

import "./members.sol";

/*
* A simple ballot for voting on alternatives.
*/
contract Ballot {
    
    struct Voter {
    	uint weight;
    	bool voted;
    	address delegate;
    	uint vote;
    }
    
    struct Proposal {
    	bytes32 name;
    	uint voteCount;
    }

	address public chairperson;
	Proposal[] public proposals;
	string public ballotName;
	mapping (address=>Voter)public voters;
	// Start of user code Ballot.attributes
	//TODO: implement
	// End of user code
	
	
	
	function Ballot(string name,bytes32[] proposalNames) public   {
		//Start of user code Ballot.function.Ballot_string_bytes32
		//TODO: implement
		//End of user code
	}
	
	
	
	function giveRightToVote(address voter) public   {
		//Start of user code Ballot.function.giveRightToVote_address
		//TODO: implement
		//End of user code
	}
	
	
	
	function delegateTo(address to) public   {
		//Start of user code Ballot.function.delegateTo_address
		//TODO: implement
		//End of user code
	}
	
	
	
	function voteFor(uint proposal) public   {
		//Start of user code Ballot.function.voteFor_uint
		//TODO: implement
		//End of user code
	}
	
	
	
	function winningProposal() public  returns (uint winningProposal) {
		//Start of user code Ballot.function.winningProposal
		uint winningVoteCount = 0;
		for (uint p = 0; p < proposals.length; p ++) {
			if (proposals [ p ].voteCount > winningVoteCount)
			{
				winningVoteCount = proposals [ p ].voteCount;
				winningProposal = p;
			}
		}
		//End of user code
	}
	
	// Start of user code Ballot.operations
	//TODO: implement
	// End of user code
}

/*
* The basic ballot.
* Collects the proposals and manages the state.
*/
contract BasicBallot {
    enum BallotState { NULL,ballotCreated,ballotStarted,ballotEnded }
    
    struct BallotProposal {
    	string name;
    	string hash;
    	string url;
    	address member;
    }

	AccessRegistry public accessregistry;
	uint public ballotStart;
	uint public ballotEnd;
	BallotState public ballotState;
	uint public proposalCount;
	string public ballotName;
	string public ballotHash;
	uint public voteCount;
	mapping (uint=>BallotProposal)public proposals;
	mapping (address=>uint)public votesCasted;
	// Start of user code BasicBallot.attributes
	//TODO: implement
	// End of user code
	
	modifier inState(BallotState _ballotState)
	{
	    if (ballotState!=_ballotState) throw;
	
	    _;
	}
	
	modifier onlyMember
	{
	    if(!accessregistry.isMember(msg.sender)) throw;
	    _;
	}
	
	/*
	* Creates the ballot in the state created.
	* 
	* _registry -The member registry for the voting.
	* _name -The name of the ballot.
	* _hash -The hash of the actual text.
	*/
	function BasicBallot(address _registry,string _name,string _hash) public   {
		//Start of user code BasicBallot.constructor.BasicBallot_address_string_string
		accessregistry = AccessRegistry(_registry);
		ballotName = _name;
		ballotHash = _hash;
		ballotState = BallotState.ballotCreated;
		//End of user code
	}
	
	
	
	function addProposal(string _name,string _hash,string _url,address _member) public  onlyMember inState(BallotState.ballotCreated)  {
		//Start of user code BasicBallot.function.addProposal_string_string_string_address
		
		BallotProposal proposal = proposals[proposalCount];
		proposal.name = _name;
		proposal.hash = _hash;
		proposal.url = _url;
		proposal.member = _member;
		proposalCount++;
		//End of user code
	}
	
	
	
	function castVote(uint _voteFor) public  onlyMember inState(BallotState.ballotStarted) ;
	
	
	
	function startBallot() public  onlyMember inState(BallotState.ballotCreated)  {
		//Start of user code BasicBallot.function.startBallot
		ballotState = BallotState.ballotStarted;
		ballotStart = now;
		//End of user code
	}
	
	
	
	function stopBallot() public  onlyMember inState(BallotState.ballotStarted)  {
		//Start of user code BasicBallot.function.stopBallot
		ballotState = BallotState.ballotEnded;
		ballotEnd = now;
		//End of user code
	}
	
	// Start of user code BasicBallot.operations
	//TODO: implement
	// End of user code
}

/*
* A public votes are counted by the events.
*/
contract PublicBallot is BasicBallot {

	// Start of user code PublicBallot.attributes
	//TODO: implement
	// End of user code
	
	
	event VotedCasted(uint proposal,address sender);
	
	
	
	function castVote(uint _voteFor) public  onlyMember inState(BallotState.ballotStarted)  {
		//Start of user code PublicBallot.function.castVote_uint
		if(_voteFor >= proposalCount) throw;
		if(voteCount>=accessregistry.getMemberCount()) throw;
		if(votesCasted[msg.sender]!=0) throw;
		
		VotedCasted(_voteFor,msg.sender);
		voteCount++;
		votesCasted[msg.sender] = voteCount;
		//End of user code
	}
	// Start of user code PublicBallot.operations
	function PublicBallot(address _registry,string _name,string _hash) BasicBallot(_registry,_name,_hash) public   {
		
	}
	// End of user code
}

/*
* Creates the ballots.
*/
contract BallotFactory {

	// Start of user code BallotFactory.attributes
	//TODO: implement
	// End of user code
	
	
	/*
	* Creates a new ballot.
	* 
	* ballotType -0 - public vote
	* _registry -The member registry for the voting.
	* _name -The name of the ballot.
	* _hash -The hash of the actual text.
	* returns
	* ballot -
	*/
	function create(uint ballotType,address _registry,string _name,string _hash) public  returns (BasicBallot ballot) {
		//Start of user code BallotFactory.function.create_uint_address_string_string
		ballot =  new PublicBallot(_registry,_name,_hash);
		//End of user code
	}
	
	// Start of user code BallotFactory.operations
	//TODO: implement
	// End of user code
}

