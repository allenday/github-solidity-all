//Quadractic
contract QuadracticVoting{
	function QuadraticVoting(){
	}

//Define the basic data Structures
	struct Voter{
		uint public voteCount;
		bool public yesOrNo;
	}
	struct Member{
		uint[] permisions;
	}
	struct Proposal {
		bytes32 public name;
		bytes32 public description;
		address public contract;
		uint public yesVotes;
		uint public noVotes;
		uint public money;
		uint public startDate;
		uint public endDate;
		mapping [address[] -> Voter] public voters;
	}
	struct Organization{
		bytes32 public name;
		uint public voteCost;
		mapping (address[] => Member) public members;
	}

//Register an organization, and give the registering account admin access.
	function registerOrganization{
	}
	function voteBuyer{
	}
}
