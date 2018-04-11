pragma solidity ^0.4.6;

import "Owned.sol";

contract VoteHub is Owned {
    
    address fund_contract;
    
    struct Community {
        uint available_tokens;
        uint total_tokens;
        mapping(string => Key) keys;
    }
    
    struct Key {
        uint upvotes;
        uint downvotes;
    }
    
    struct Voter {
        uint total_tokens;
        mapping (string => Community) Communities;
    }
    
    uint total_tokens = 0;
    mapping (string => Community) Communities;
    mapping (address => Voter) Voters;
    
    function VoteHub(address fundContract){
        fund_contract = fundContract;
    }
    
    event FundDevelopment_event(address funder, uint value);
    
    function fundDevelopment(string community) payable {
        if(msg.value == 0)
            throw;
        
        total_tokens += msg.value;
        Voters[msg.sender].total_tokens += msg.value;
        Voters[msg.sender].Communities[community].available_tokens += msg.value;
        Voters[msg.sender].Communities[community].total_tokens += msg.value;
        Communities[community].available_tokens += msg.value;
        Communities[community].total_tokens += msg.value;
        
        if(!fund_contract.send(msg.value))
            throw;
        
        FundDevelopment_event(msg.sender,msg.value);
    }
    
    event Vote_event(address voter, string community, string key, uint amount, bool support);
    
    function vote(string community, string key, uint amount, bool support){
        reclaimTokens(community,key);
        
        uint available = Voters[msg.sender].Communities[community].available_tokens;
        if(available > 0 && amount <= available){
            if(support){
                Communities[community].keys[key].upvotes += amount;
                Voters[msg.sender].Communities[community].keys[key].upvotes += amount;
            } else {
                Communities[community].keys[key].downvotes += amount;
                Voters[msg.sender].Communities[community].keys[key].downvotes += amount;
            }
            
            Voters[msg.sender].Communities[community].available_tokens -= amount;
            Communities[community].available_tokens -= amount;
            
            Vote_event(msg.sender,community,key,amount,support);
        }
    }
    
    event ReclaimTokens_event(address voter, string community, string key, uint upvotes, uint downvotes);
    
    function reclaimTokens(string community, string key){
        var upvotes = Voters[msg.sender].Communities[community].keys[key].upvotes;
        var downvotes = Voters[msg.sender].Communities[community].keys[key].downvotes;
        
        Communities[community].keys[key].upvotes -= upvotes;
        Communities[community].keys[key].downvotes -= downvotes;
        
        Voters[msg.sender].Communities[community].keys[key].upvotes = 0;
        Voters[msg.sender].Communities[community].keys[key].downvotes = 0;
        
        var refund = upvotes + downvotes;
        Voters[msg.sender].Communities[community].available_tokens += refund;
        Communities[community].available_tokens += refund;
        
        ReclaimTokens_event(msg.sender, community,key,upvotes,downvotes);
    }
    
    function getKeyVotes(string community, string key) constant returns(uint,uint){
        //get key upvotes/downvotes
        var upvotes = Communities[community].keys[key].upvotes;
        var downvotes = Communities[community].keys[key].downvotes;
        
        return (upvotes,downvotes);
    }
    
    function getUserVotes(address user, string community, string key) constant returns (uint,uint){
        var upvotes = Voters[user].Communities[community].keys[key].upvotes;
        var downvotes = Voters[user].Communities[community].keys[key].downvotes;
        
        return (upvotes,downvotes);
    }
    
    function getUserData(address user, string community) constant returns(uint,uint,uint){
        var total_tokens = Voters[user].total_tokens;
        var available_tokens = Voters[user].Communities[community].available_tokens;
        var community_tokens = Voters[user].Communities[community].total_tokens;
        
        return (available_tokens,community_tokens,total_tokens);
    }
    
    function getCommunityData(string community) constant returns(uint,uint){
        var available_tokens = Communities[community].available_tokens;
        var community_tokens = Communities[community].total_tokens;
        
        return (available_tokens,community_tokens);
    }
    
    function getVoteHubDetails() constant returns (address,address,uint){
        return (owner,fund_contract,total_tokens);
    }
    
    function changeFundContract(address newFundContract) isOwner {
        fund_contract == newFundContract;
    }
}