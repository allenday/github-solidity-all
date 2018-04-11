pragma solidity ^0.4.14;

// 
// Create a Democracy contract in Ethereum  https://ethereum.org/dao
// 

// The Blockchain Congress

  pragma solidity ^0.4.2;
  contract owned {
      address public owner;

      function owned() {
          owner = msg.sender;
      }

      modifier onlyOwner {
          require (msg.sender == owner);
          _;
      }

      function transferOwnership(address newOwner) onlyOwner {
          owner = newOwner;
      }
  }

  contract tokenRecipient {
      event receivedEther(address sender, uint amount);
      event receivedTokens(address _from, uint256 _value, address _token, bytes _extraData);

      function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData){
          Token t = Token(_token);
          require (!t.transferFrom(_from, this, _value));
          receivedTokens(_from, _value, _token, _extraData);
      }

      function () payable {
          receivedEther(msg.sender, msg.value);
      }
  }

  contract Token {
      function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
  }

  contract Congress is owned, tokenRecipient {

      /* Contract Variables and events */
      uint public minimumQuorum;
      uint public debatingPeriodInMinutes;
      int public majorityMargin;
      Proposal[] public proposals;
      uint public numProposals;
      mapping (address => uint) public memberId;
      Member[] public members;

      event ProposalAdded(uint proposalID, address recipient, uint amount, string description);
      event Voted(uint proposalID, bool position, address voter, string justification);
      event ProposalTallied(uint proposalID, int result, uint quorum, bool active);
      event MembershipChanged(address member, bool isMember);
      event ChangeOfRules(uint newMinimumQuorum, uint newDebatingPeriodInMinutes, int newMajorityMargin);

      struct Proposal {
          address recipient;
          uint amount;
          string description;
          uint votingDeadline;
          bool executed;
          bool proposalPassed;
          uint numberOfVotes;
          int currentResult;
          bytes32 proposalHash;
          Vote[] votes;
          mapping (address => bool) voted;
      }

      struct Member {
          address member;
          string name;
          uint memberSince;
      }

      struct Vote {
          bool inSupport;
          address voter;
          string justification;
      }

      /* modifier that allows only shareholders to vote and create new proposals */
      modifier onlyMembers {
          require (memberId[msg.sender] != 0);
          _;
      }

      /* First time setup */
      function Congress (
          uint minimumQuorumForProposals,
          uint minutesForDebate,
          int marginOfVotesForMajority
      )  payable {
          changeVotingRules(minimumQuorumForProposals, minutesForDebate, marginOfVotesForMajority);
          // It’s necessary to add an empty first member
          addMember(0, "");
          // and let's add the founder, to save a step later       
          addMember(owner, 'founder');        
      }

      /// @notice Make `targetMember` a member named `memberName`
      /// @param targetMember ethereum address to be added
      /// @param memberName public name for that member
      function addMember(address targetMember, string memberName) onlyOwner {
          uint id = memberId[targetMember];
          if (id == 0) {
              memberId[targetMember] = members.length;
              id = members.length++;
          }

          members[id] = Member({member: targetMember, memberSince: now, name: memberName});
          MembershipChanged(targetMember, true);
      }

      /// @notice Remove membership from `targetMember`
      /// @param targetMember ethereum address to be removed
      function removeMember(address targetMember) onlyOwner {
          require(memberId[targetMember] != 0);

          for (uint i = memberId[targetMember]; i<members.length-1; i++){
              members[i] = members[i+1];
          }
          delete members[members.length-1];
          members.length--;
      }

      /// @notice Make so that proposals need tobe discussed for at least `minutesForDebate/60` hours, have at least `minimumQuorumForProposals` votes, and have 50% + `marginOfVotesForMajority` votes to be executed
      /// @param minimumQuorumForProposals how many members must vote on a proposal for it to be executed      
      /// @param minutesForDebate the minimum amount of delay between when a proposal is made and when it can be executed    
      /// @param marginOfVotesForMajority the proposal needs to have 50% plus this number      
      function changeVotingRules(
          uint minimumQuorumForProposals,
          uint minutesForDebate,
          int marginOfVotesForMajority
      ) onlyOwner {
          minimumQuorum = minimumQuorumForProposals;
          debatingPeriodInMinutes = minutesForDebate;
          majorityMargin = marginOfVotesForMajority;

          ChangeOfRules(minimumQuorum, debatingPeriodInMinutes, majorityMargin);
      }

      /// @notice Propose to send `weiAmount / 1E18` ether to `beneficiary` for `JobDescription`. `transactionBytecode ? Contains : Does not contain` code.
      /// @param beneficiary who to send the ether to      
      /// @param weiAmount amount of ether to send, in wei       
      /// @param JobDescription Description of job
      /// @param transactionBytecode bytecode of transaction
      function newProposal(
          address beneficiary,
          uint weiAmount,
          string JobDescription,
          bytes transactionBytecode
      )
          onlyMembers
          returns (uint proposalID)
      {
          proposalID = proposals.length++;
          Proposal storage p = proposals[proposalID];
          p.recipient = beneficiary;
          p.amount = weiAmount;
          p.description = JobDescription;
          p.proposalHash = sha3(beneficiary, weiAmount, transactionBytecode);
          p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
          p.executed = false;
          p.proposalPassed = false;
          p.numberOfVotes = 0;
          ProposalAdded(proposalID, beneficiary, weiAmount, JobDescription);
          numProposals = proposalID+1;

          return proposalID;
      }

      /// @notice Propose to send `etherAmount` ether to `beneficiary` for `JobDescription`. `transactionBytecode ? Contains : Does not contain` code.
      /// @param beneficiary who to send the ether to      
      /// @param etherAmount amount of ether to send       
      /// @param JobDescription Description of job
      /// @param transactionBytecode bytecode of transaction
      function newProposalInEther(
          address beneficiary,
          uint etherAmount,
          string JobDescription,
          bytes transactionBytecode
      )
          onlyMembers
          returns (uint proposalID)
      {
          return newProposal(beneficiary, etherAmount * 1 ether, JobDescription, transactionBytecode);
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
          Proposal storage p = proposals[proposalNumber];
          return p.proposalHash == sha3(beneficiary, etherAmount, transactionBytecode);
      }

      /// @notice Vote `supportsProposal? in support of : against` proposal #`proposalNumber`
      /// @param proposalNumber number of proposal
      /// @param supportsProposal either in favor or against it
      /// @param justificationText optional justification text
      function vote(
          uint proposalNumber,
          bool supportsProposal,
          string justificationText
      )
          onlyMembers
          returns (uint voteID)
      {
          Proposal storage p = proposals[proposalNumber];         // Get the proposal
          require(!p.voted[msg.sender]);         // If has already voted, cancel
          p.voted[msg.sender] = true;                     // Set this voter as having voted
          p.numberOfVotes++;                              // Increase the number of votes
          if (supportsProposal) {                         // If they support the proposal
              p.currentResult++;                          // Increase score
          } else {                                        // If they don't
              p.currentResult--;                          // Decrease the score
          }
          // Create a log of this event
          Voted(proposalNumber,  supportsProposal, msg.sender, justificationText);
          return p.numberOfVotes;
      }

      /// @notice Count the votes proposal #`proposalNumber` and execute it if approved
      /// @param proposalNumber proposal number
      /// @param transactionBytecode optional: if the transaction contained a bytecode, you need to send it
      function executeProposal(uint proposalNumber, bytes transactionBytecode) {
          Proposal storage p = proposals[proposalNumber];
          /* Check if the proposal can be executed:
             - Has the voting deadline arrived?
             - Has it been already executed or is it being executed?
             - Does the transaction code match the proposal?
             - Has a minimum quorum?
          */

          require (now > p.votingDeadline
              && !p.executed
              && p.proposalHash == sha3(p.recipient, p.amount, transactionBytecode)
              && p.numberOfVotes >= minimumQuorum);

          /* execute result */
          /* If difference between support and opposition is larger than margin */
          if (p.currentResult > majorityMargin) {
              // Avoid recursive calling

              p.executed = true;
              require(p.recipient.call.value(p.amount)(transactionBytecode));

              p.proposalPassed = true;
          } else {
              p.proposalPassed = false;
          }
          // Fire Events
          ProposalTallied(proposalNumber, p.currentResult, p.numberOfVotes, p.proposalPassed);
      }
  }