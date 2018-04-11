import "./owned.sol";
import "./localsCointoken.sol";

contract token { mapping (address => uint256) public balanceOf;  }

contract localsStore is owned {

  // the address of the tokencontract to use
  address public tokenaddr;

  // the address of the foundation to use
  address public foundation;

  event Log(string _log, address _newclub);
  event Error(string _error);
  event Allowance(string _msg, uint256 _balance);
  event ClubCreated(string _clubname, address _newClub, address _creator);

	function localsStore(address _tokenContract, address _foundationContract) {
		tokenaddr = _tokenContract;
    foundation = _foundationContract;
	}

	function createAssociation(uint _minimumQuorum, uint _debatingPeriodInMinutes) returns (address associationAddress)	{
      var tokencontract = localsCointoken(tokenaddr);

      if(tokencontract.allowance(msg.sender,this)<200) {
        Error('LocalCoin allowance too low');
        throw;
      }

      Error('allowance check');
      Allowance('TEST ', tokencontract.allowance(msg.sender, this));

      tokencontract.transferFrom(msg.sender, foundation, 200);

      Error('localcoin transferred');
      tokencontract.transfer(foundation, 200);

      // Deploy new token contract and use the address in the association

      /*
      uint256 initialSupply,
      string tokenName,
      uint8 decimalUnits,
      uint256 _minEthbalance,
      string tokenSymbol,
      string versionOfTheCode
      */

      var newtokencontract = new localsCointoken(10000, 'newToken', 2, 0.2 ether, 'T', '0.1');

      // TODO : fix this line
      associationAddress = new Association(newtokencontract, _minimumQuorum, _debatingPeriodInMinutes);

      ClubCreated('new association', associationAddress, msg.sender);

      return associationAddress;

	}

  /* Kill function, for debug purposes (I don't want a mist wallet full of token contracts :) */
  function kill() { if (msg.sender == owner) suicide(owner); }

}


// Here we start an Association
/* The democracy contract itself */
contract Association is owned {

    /* Contract Variables and events */
    uint public minimumQuorum;
    uint public debatingPeriodInMinutes;
    Proposal[] public proposals;
    uint public numProposals;
    address public sharesTokenAddress;

    event ProposalAdded(uint proposalID, address recipient, uint amount, string description);
    event Voted(uint proposalID, bool position, address voter);
    event ProposalTallied(uint proposalID, int result, uint quorum, bool active);
    event ChangeOfRules(uint minimumQuorum, uint debatingPeriodInMinutes, address sharesTokenAddress);

    struct Proposal {
        address recipient;
        uint amount;
        string description;
        uint votingDeadline;
        bool executed;
        bool proposalPassed;
        uint numberOfVotes;
        bytes32 proposalHash;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Vote {
        bool inSupport;
        address voter;
    }

    /* modifier that allows only shareholders to vote and create new proposals */
    modifier onlyShareholders {
        token sharesToken =  token(sharesTokenAddress);
        if (sharesToken.balanceOf(msg.sender) == 0) throw;
        _
    }

    /* First time setup */
    function Association(address sharesTokenAddress, uint minimumSharesToPassAVote, uint minutesForDebate) {
        changeVotingRules(sharesTokenAddress, minimumSharesToPassAVote, minutesForDebate);
    }

    /*change rules*/
    function changeVotingRules(address sharesTokenAddress, uint minimumSharesToPassAVote, uint minutesForDebate) onlyOwner {
        token sharesToken = token(sharesTokenAddress);
        if (minimumSharesToPassAVote == 0 ) minimumSharesToPassAVote = 1;
        minimumQuorum = minimumSharesToPassAVote;
        debatingPeriodInMinutes = minutesForDebate;
        ChangeOfRules(minimumQuorum, debatingPeriodInMinutes, sharesTokenAddress);
    }

    /* Function to create a new proposal */
    function newProposal(
        address beneficiary,
        uint etherAmount,
        string JobDescription,
        bytes transactionBytecode
    )
        onlyShareholders
        returns (uint proposalID)
    {
        proposalID = proposals.length++;
        Proposal p = proposals[proposalID];
        p.recipient = beneficiary;
        p.amount = etherAmount;
        p.description = JobDescription;
        p.proposalHash = sha3(beneficiary, etherAmount, transactionBytecode);
        p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
        p.executed = false;
        p.proposalPassed = false;
        p.numberOfVotes = 0;
        ProposalAdded(proposalID, beneficiary, etherAmount, JobDescription);
        numProposals = proposalID+1;
    }

    /* function to check if a proposal code matches */
    function checkProposalCode(
        uint proposalNumber,
        address beneficiary,
        uint etherAmount,
        bytes transactionBytecode
    )
        constant
        returns (bool codeChecksOut)
    {
        Proposal p = proposals[proposalNumber];
        return p.proposalHash == sha3(beneficiary, etherAmount, transactionBytecode);
    }

    /* */
    function vote(uint proposalNumber, bool supportsProposal)
        onlyShareholders
        returns (uint voteID)
    {
        Proposal p = proposals[proposalNumber];
        if (p.voted[msg.sender] == true) throw;

        voteID = p.votes.length++;
        p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
        p.voted[msg.sender] = true;
        p.numberOfVotes = voteID +1;
        Voted(proposalNumber,  supportsProposal, msg.sender);
    }

    function executeProposal(uint proposalNumber, bytes transactionBytecode) returns (int result) {
        Proposal p = proposals[proposalNumber];
        /* Check if the proposal can be executed */
        if (now < p.votingDeadline  /* has the voting deadline arrived? */
            ||  p.executed        /* has it been already executed? */
            ||  p.proposalHash != sha3(p.recipient, p.amount, transactionBytecode)) /* Does the transaction code match the proposal? */
            throw;

        /* tally the votes */
        uint quorum = 0;
        uint yea = 0;
        uint nay = 0;

        for (uint i = 0; i <  p.votes.length; ++i) {
            Vote v = p.votes[i];

            uint voteWeight = 1;

            if(sharesTokenAddress != 0x0){
              voteWeight = token(sharesTokenAddress).balanceOf(v.voter);
            }

            quorum += voteWeight;
            if (v.inSupport) {
                yea += voteWeight;
            } else {
                nay += voteWeight;
            }
        }

        /* execute result */
        if (quorum <= minimumQuorum) {
            /* Not enough significant voters */
            throw;
        } else if (yea > nay ) {
            /* has quorum and was approved */
            if (!p.recipient.call.value(p.amount * 1 ether)(transactionBytecode)){
              throw;
            }
            p.executed = true;
            p.proposalPassed = true;
        } else {
            p.executed = true;
            p.proposalPassed = false;
        }
        // Fire Events
        ProposalTallied(proposalNumber, result, quorum, p.proposalPassed);
    }
}
