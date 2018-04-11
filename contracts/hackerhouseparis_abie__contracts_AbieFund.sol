/* Part of this contract is from the solidity documentation
TODO: Set a license.
*/

pragma solidity ^0.4.8;

/// @title Fund for donations.
contract AbieFund {

    uint public membershipFee = 0.1 ether;
    uint public deposit = 1 ether;
    uint public nbMembers;
    uint public nbProposalsFund;
    uint public registrationTime = 1 years;
    uint[2] public voteLength = [1 weeks, 1 weeks];
    uint MAX_DELEGATION_DEPTH=1000;
    address NOT_COUNTED=0;
    address COUNTED=1;

    event Donated(address donor, uint amount);

    enum ProposalType {AddMember,FundProject} // Different types of proposals.
    enum VoteType {Abstain,Yes,No} // Different value of a vote.

    struct Proposal
    {
        bytes32 name; // short name (up to 32 bytes).
        uint voteYes; // number of YES votes.
        uint voteNo;  // number of abstention. Number of No can be deduced.
        address recipient; // address the funds will be sent.
        uint value; // quantity of wei to be sent.
        bytes32 data; // data of the transaction.
        ProposalType proposalType; // type of the proposal.
        uint endDate; // when the vote will be closed.
        address lastMemberCounted; // last one who was counted or NOT_COUNTED (if the count has not started) or COUNTED (if all the votes has been counted);
        bool executed; // true if the proposal have been executed.
        mapping (address => VoteType) vote; // vote of the party.
    }

    // Is also a node list.
    struct Member
    {
        uint registration;  // date of registration, if 0 the member does not exist.
        address[2] delegate; // delegate[proposalType] gives the delegate for the type.
        address prev;
        address succ; // this should not be deleted even when the member is.
        uint proposalStoppedOnHim; // number of proposals stopped on him.
    }

    mapping (address => Member) public members;

    // Double chained list.
    struct DoubleChainedList
    {
        address first;
        address last;
    }

    // Chain containing all members to iterate on.
    DoubleChainedList memberList;

    Proposal[] public proposals;

    /// Require at least price to be paid.
    modifier costs(uint price) {
        if (msg.value<price)
            throw;
        _;
    }

    /// Require the caller to be a member.
    modifier isMember() {
        if(!isValidMember(msg.sender))
            throw;
        _;
    }


    /// @param initialMembers First members of the organization.
    function AbieFund(address[] initialMembers) {
        for (uint i;i<initialMembers.length;++i){
            Member member=members[initialMembers[i]];
            member.registration=now;
            if (i==0) { // initialize the list with the first member
                memberList.first=initialMembers[0];
                memberList.last=initialMembers[0];
            } else { // add members
                addMember(initialMembers[i]);
            }
        }
        nbMembers=initialMembers.length;
    }

    // Add the member m to the member list.
    // Assume that there is at least 1 member registrated.
    function addMember(address m) private {
        members[memberList.last].succ=m;
        members[m].prev=memberList.last;
        memberList.last=m;
    }

    /** Choose a delegate.
      * @param proposalType 0 for AddMember, 1 for FundProject.
      * @param target account to delegate to.
      */
    function setDelegate(uint8 proposalType, address target)
    {
        members[msg.sender].delegate[proposalType] = target;
    }

    /// Receive funds.
    function () payable {
        Donated(msg.sender, msg.value);
    }

    /// Ask membership of the fund.
    function askMembership () payable costs(membershipFee) {
        Donated(msg.sender,msg.value); // Register the donation.

        // Create a proposal to add the member.
        proposals.push(Proposal({
          name: 0x0,
          voteYes: 0,
          voteNo: 0,
          recipient: msg.sender,
          value: 0x0,
          data: 0x0,
          proposalType: ProposalType.AddMember,
          endDate: now + voteLength[uint256(ProposalType.AddMember)],
          lastMemberCounted: 0,
          executed: false
        }));
    }

    /// Add Proposal.
    function addProposal (bytes32 _name, uint _value, bytes32 _data) payable costs(deposit) {
        Donated(msg.sender,msg.value); // Register the donation.

        // Create a proposal to add the member.
        proposals.push(Proposal({
          name: _name,
          voteYes: 0,
          voteNo: 0,
          recipient: msg.sender,
          value: _value,
          data: _data,
          proposalType: ProposalType.FundProject,
          endDate: now,
          lastMemberCounted: 0,
          executed: false
        }));

        ++nbProposalsFund;
    }

    /** Vote for a proposal.
     *  @param proposalID ID of the proposal to count votes from.
     *  @param voteType Yes or No.
     */
    function vote (uint proposalID, VoteType voteType) isMember {
        Proposal proposal = proposals[proposalID];
        if (proposal.vote[msg.sender] != VoteType.Abstain) // Has already voted.
            throw;
        if (proposal.endDate < now) // Vote is over.
            throw;

        proposals[proposalID].vote[msg.sender] = voteType;
    }

    /** Count all the votes. You can call this function if gas limit is not an issue.
     *  @param proposalID ID of the proposal to count votes from.
     */
    function countAllVotes (uint proposalID) {
        countVotes (proposalID,uint(-1));
    }

    /** Count up to max of the votes.
     *  You may have to call this function multiple times if counting once reach the gas limit.
     *  This function is necessary to count in multiple times if counting reach gas limit.
     *  We just count the number of Yes and Abstention, so we will deduce the number of No.
     *  @param proposalID ID of the proposal to count votes from.
     *  @param max maximum to count.
     */
    function countVotes (uint proposalID, uint max) {
        Proposal proposal = proposals[proposalID];
        address current;
        if (proposal.endDate > now) // You can't count while the vote is not over.
            throw;
        if (proposal.lastMemberCounted == COUNTED) // The count is already over
            throw;

        if (proposal.lastMemberCounted == NOT_COUNTED)
            current = memberList.first;
        else
            current = proposal.lastMemberCounted;

        while (max-- != 0) {
            Member member=members[current];
            address delegate=current;
            if(isValidMember(current)) {
                uint depth=0;
                // Seach the final vote.
                while (true){
                    VoteType vote=proposal.vote[delegate];
                    if (vote==VoteType.Abstain) { // Look at the delegate
                        depth+=1;
                        delegate=members[delegate].delegate[uint(proposal.proposalType)]; // Find the delegate.
                        if (delegate==current // The delegation chain forms a circle.
                            || delegate==0  // Has not set a delegate.
                            || depth>MAX_DELEGATION_DEPTH) { // Too much depth, we must limit it in order to avoid some circle of delegation made to consume too much gaz.
                           break;
                        }
                    }
                    if (vote==VoteType.Yes) {
                        proposal.voteYes+=1;
                        break;
                    } else if (vote==VoteType.No) {
                        proposal.voteNo+=1;
                        break;
                    }
                }
            } else {
                // TODO: Delete the members if they are expired.
            }

            current=member.succ; // In next iteration start from the next node.
            if (current==0) { // We reached the last member.
                proposal.lastMemberCounted=COUNTED;
                break;
            }

        }

    }

    function executeAddMemberProposal(uint proposalID) {
        Proposal proposal = proposals[proposalID];
        if (proposal.proposalType != ProposalType.AddMember) // Not a proposal to add a member.
            throw;
        if (!isExecutable(proposalID)) // Proposal was not approved.
            throw;
        proposal.executed=true; // The proposal will be executed.
        addMember(proposal.recipient);
    }

    /// CONSTANTS ///

    /** Return the delegate.
     *  @param member member to get the delegate from.
     *  @param proposalType 0 for AddMember, 1 for FundProject.
     */
    function getDelegate(address member, uint8 proposalType) constant returns (address){
        return members[member].delegate[proposalType];
    }

    /** Return true if the proposal is validated, false otherwise.
     *  @param proposalID ID of the proposal to count votes from.
     */
    function isExecutable(uint proposalID) constant returns (bool) {
        Proposal proposal = proposals[proposalID];

        if (proposal.lastMemberCounted != COUNTED) // Not counted yet.
            return false;
        if (proposal.executed) // The proposal has already been executed.
            return false;
        if (proposal.value>this.balance) // Not enough to execute it.
            return false;

        return (proposal.voteYes>proposal.voteNo);
    }

    function isValidMember(address m) constant returns(bool) {
        if (members[m].registration==0) // Not a member.
            return false;
        if (members[m].registration+registrationTime<now) // Has expired.
            return false;
        return true;
    }
}
