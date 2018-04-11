/*
 * refundSplitMembers.sol - a Solidity Ethereum smartcontract to help theDAO split members recover their ether
 * Copyright (C) 2016 Aeron Buchannan
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */


/* @RefundSplitMembers return theDAO ETH back to split members
 *
 * The priority here is to provide a way for theDAO split members to get their ether out of the contract 
 * without exposing the process to hijacking.
 *
 * The approach of this contract is to be a single recipient for a proposal, so any recursive attack 
 * attempts can't hamper the process.
 *
 * It includes a timelock "cooldown" period in which no funds can be taken out. This period is designed
 * to allow for an appraisal of this contract to check its correctness.
 *
 * It also includes a mechanism for transferring all the ether held by it to a single address if the 
 * members vote to do so, e.g. if an error is found with the refund process.
 *
 * Obviously there is a balance here of providing a secondary payment mechanism as a backup rather than 
 * a backdoor for a malign actor...
 * 
 * TODO: call the parent DAO to get the member details
 *
 *
 */

contract refundSplitMembers {
	// Charity address to receive any left-over Ether that somehow ends up in this contract
	address charity;

	struct MemberDetails
	{
		uint amount;			// amount of wei due for this member
		mapping(uint => bool) votes;	// participation in fallback votes
	}

	// list of addresses to be reimbursed, aka members
	mapping(address => MemberDetails) members; 

	// tracks number of members for voting
	uint numMembers;

	struct FallbackProposal
	{
		address addr;	// address of a fallback option to receive all the eth of this contract
		uint voteCount;	// number of votes for this fallback option
	}

	// list of backup proposals
	FallbackProposal[] fallbackProposals;

	// number of votes required for a proposal to be successful
	uint voteThreshold; 

	// number of members below which the decision must be unanimous
	uint minVoteThreshold;

	// time of refund time-lock release
	uint timelockPeriod; 

	/// Create a new refund contract with hardcoded members for simplicity
	function refundSplitMembers() 
	{
		members["0x..."].amount = ...;
		...

		timelockPeriod = now + 7 days;

		numMembers = ...;

		/* With N - 1 votes required, two people are needed to block a "recovery"
		 * This means that if a member is trying to steal all the funds, you just
		 * need one friend member to stop it. It also means that a single stalker
		 * can't block a fallback option.
		 * Of course, by having a "fallback" option at all, the danger of everything
		 * being stolen exists unavoidably. The alternative is the possibility that
		 * the funds are forever stuck in this contract, i.e. this contract 'steals'
		 * it all ;-)
		 */
		minVoteThreshold = 3;
		if ( numMembers > minVoteThreshold ) voteThreshold = numMembers - 1;
		else voteThreshold = numMembers;
	}

	/// The methods of this contract are members only
	modifier membersOnly
	{
		if ( members[msg.sender].amount == 0 ) throw;
		_
	}

	// This contract shouldn't be receiving any ether
	modifier noEther
	{
		if ( msg.value > 0 ) throw;
	}

	/// If the timelock period is over, allow a member to extract their portion of the funds
	function refund() membersOnly noEther
	{
		if ( now < timelockPeriod ) throw; // only after time period

		msg.sender.send(members[msg.sender].amount); // send funds owed
		members[msg.sender].amount = 0; // remove from member list
		numMembers -= 1; // decrement the member count
		
		if ( numMembers > minVoteThreshold ) voteThreshold -= 1; // decrement the voting threshold
		else voteThreshold = numMembers; // if too few people left, vote must be unamimous
	}

	/// Put forward a single address that can receive all the funds of this contract if enough members vote for it. DANGER!
	function fallbackProposal(address fallback) membersOnly noEther
	{
		fallbackProposals.push(FallbackProposal({
			addr: fallback,
			voteCount: 0
		}));
	}

	/// A member can vote for a fallback address, but only one vote max per address
	function vote(uint proposalNumber) membersOnly noEther
	{
		if ( members[msg.sender].votes[proposalNumber] == true ) throw;

		members[msg.sender].votes[proposalNumber] = true;
		fallbackProposals[proposalNumber].voteCount += 1;
	}

	/// If a fallback address has enough votes, kill this contract and transfer all funds to that address. DANGER!
	function fallback(uint proposalNumber) membersOnly noEther
	{
		if ( fallbackProposals[proposalNumber].voteCount <= voteThreshold ) throw;

		suicide(fallbackProposals[proposalNumber].addr);
	}

	/// If everyone has removed their funds, then the charity can claim whatever is left.
	// This is a final backup option in case the last remaining member didn't think to claim it all
	function charityClaim()
	{
		suicide(charity);
	}	
}
