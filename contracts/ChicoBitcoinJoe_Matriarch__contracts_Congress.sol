pragma solidity ^0.4.8;

import "MiniMeToken.sol";

/// @dev The Congress controller contract must implement these functions
contract CongressController {
    /// @notice Called when `_voter` votes on a proposal in the Congress Contract
    /// @param _voter The address that sent a vote to a proposal
    /// @return Uint token balance of the '_voter'
    function getWeight(address _voter) returns(uint);

    /// @notice Notifies the controller about a proposal passing
    /// @param _proposal_id The id of the proposal that passed
    function passed(uint _proposal_id) returns(bool);
}

contract Congress is Controlled {

////////////////
// Declarations
////////////////    

    address public curator;

////////////////
// Constructor
////////////////

    function Congress(address _curator) {
        curator = _curator;
    }
    
////////////////
// DAO Functions
////////////////

    uint inactive = 60 days;
    uint public majority_percent = 51;
    uint public total_locked_tokens;
    
    uint public total_voters = 0; //All voters accross all proposals
    mapping (address => Voter) public voters;
    
    uint public total_proposals = 0; //Also serves as the next proposal ID
    mapping (uint => Proposal) public proposals;
    
    function submitProposal(bytes32 _action, string _description_hash, 
    address _relevant_address, uint _relevant_amount)  {
        proposals[total_proposals] = Proposal(_action, _description_hash, 
            _relevant_address, _relevant_amount, false, false, 0, 0, 0, 0);
        total_proposals++;
    }
    
    function vote(uint _proposal_id, bool _support) validProposal(_proposal_id) {
        uint current_balance = CongressController(controller).getWeight(msg.sender);
        if(current_balance == 0)
            throw;
        
        
        //Has this voter ever voted before?
        if(voters[msg.sender].locks == 0){
            total_voters++;
        }
        
        var locked_balance = voters[msg.sender].locked_tokens;
        var difference = current_balance - locked_balance;
        if(difference > 0){
            total_locked_tokens += difference;
            voters[msg.sender].locked_tokens = current_balance;
        }
        
        var proposal_balance = proposals[_proposal_id].votes[msg.sender].weight;
        var proposal_support = proposals[_proposal_id].votes[msg.sender].support;
        
        //Has this voter ever voted on this proposal?
        if(proposal_balance > 0){
            //Is the voter switching sides?
            if(proposal_support != _support){
                if(proposal_support)
                    proposals[_proposal_id].support -= proposal_balance;
                else
                    proposals[_proposal_id].against -= proposal_balance;
            }
            
            proposals[_proposal_id].votes[msg.sender].weight = current_balance;
            proposals[_proposal_id].votes[msg.sender].support = _support;
            
            if(_support)
                proposals[_proposal_id].support += current_balance;
            else
                proposals[_proposal_id].against += current_balance;
                
        } else {
            voters[msg.sender].voteIndex[voters[msg.sender].total_votes] = _proposal_id;
            voters[msg.sender].total_votes++;
            proposals[_proposal_id].total_voters++;
            proposals[_proposal_id].votes[msg.sender].weight = current_balance;
            if(_support)
                proposals[_proposal_id].support += current_balance;
            else
                proposals[_proposal_id].against += current_balance;
                
            voters[msg.sender].locks++;
        }
        
        voters[msg.sender].timestamp = block.timestamp;
    }
    
    function unvote(address _voter, uint _proposal_id) validProposal(_proposal_id) {
        if(_voter != msg.sender)
             if( (block.timestamp - voters[_voter].timestamp) < inactive) throw;
            
        if(voters[_voter].locks == 0)
            throw;
        
        //Has the voter ever voted on this proposal?
        if(proposals[_proposal_id].votes[_voter].weight == 0)
            throw;
            
        if(proposals[_proposal_id].votes[_voter].support)
            proposals[_proposal_id].support -= proposals[_proposal_id].votes[_voter].weight;
        else
            proposals[_proposal_id].against -= proposals[_proposal_id].votes[_voter].weight;
        
        proposals[_proposal_id].total_voters--;
        voters[_voter].locks--;
        
        //If this voter has no votes remaining remove from voting pool
        if(voters[_voter].locks == 0){
            total_locked_tokens -= voters[_voter].locked_tokens;
            voters[_voter].locked_tokens = 0;
            total_voters--;
        }
    }
    
    function pass(uint _proposal_id) isCurator { 
        bytes32 action = proposals[_proposal_id].action;
        if(action == 'ongoing')
            throw;
        
        uint threshold = total_locked_tokens * majority_percent / 100;
        uint support = proposals[_proposal_id].support;
        if(support > threshold)
            proposals[_proposal_id].passed = true;
            
        uint against = proposals[_proposal_id].against;
        if(against > threshold)
            proposals[_proposal_id].rejected = true;
        
        CongressController(controller).passed(_proposal_id);
    }
    
    function isVoterLocked(address _voter) constant returns (bool) {
        return voters[_voter].locks > 0;
    }
    
    function getProposalAction(uint _proposal_id) constant returns (bytes32) {
        return proposals[_proposal_id].action;
    }
    
    function getProposalAddress(uint _proposal_id) constant returns (address) {
        return proposals[_proposal_id].address_storage;
    }
    
    function getProposalUint(uint _proposal_id) constant returns (uint) {
        return proposals[_proposal_id].uint_storage;
    }
    
////////////////
// Structs and Modifiers
////////////////
    
    modifier validProposal(uint _proposal_id) {
        if(_proposal_id >= total_proposals) throw;
        if(proposals[_proposal_id].passed) throw;
        if(proposals[_proposal_id].rejected) throw;
        _;
    }
    
    modifier isCurator { 
        if(msg.sender != curator)
            throw;
        _;
    }
    
    struct Voter {
        uint timestamp; //To determine inactivity
        uint locks; //1 lock = 1 vote
        uint locked_tokens;
        
        uint total_votes;
        mapping(uint => uint) voteIndex; //vote# => proposal_id
    }
    
    struct Vote {
        uint weight; //The voters weight for a proposal
        bool support; //Is the voter for or against a proposal
    }
    
    struct Proposal {
        bytes32 action;
        string description_hash;
        address address_storage;
        uint uint_storage;
        
        bool passed;
        bool rejected;
        uint timestamp;
        
        uint support;
        uint against;
        
        uint total_voters;
        mapping (uint => address) voterIndex;
        mapping (address => Vote) votes;  
    }

////////////////
// Events
////////////////
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );

}