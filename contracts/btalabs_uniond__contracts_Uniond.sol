pragma solidity ^0.4.0;

contract Uniond {

  uint[8] public constitution;
  address[] public members;
  uint public activeMembers;
  mapping(address => Member) public member;

  struct Member {
    uint joinDate;
    uint renewalDate;
    bool exists;
    bool isApproved;
    bool isMember;
    bool isMemberAdmin;
    bool isTreasurer;
    uint electedMemberAdminDate;
    uint electedTreasurerDate;
    uint spentVotes; //numVotes = issues.length + delegatedVotes - spentVotes;
    uint delegatedVotes;
  }
  
  uint tokenSupply;
  mapping(address => uint) public tokens;
  
  Issue[] public issues;
  Election[] public elections;
  Amendment[] public amendments;
  MemberReview[] memberReviews;

  struct MemberReview {
    uint reviewDate;
    uint tempActiveMembers;
    uint lastEndIndex;
    mapping(uint => bool) reviewed;
  }
  
  struct Amendment {
    string reason;
    uint clause;
    uint value;
    uint deadline;
    bool executed;
    address[] votes;
    mapping(address => bool) hasVoted;
  }

  struct Election {
    address owner;
    address nominee;
    uint role;
    uint deadline;
    bool executed;
    uint votes;
    mapping(address => bool) hasVoted;
  }

  struct Issue {
    address owner;
    string description;
    uint date;
    uint approve;
    uint disapprove;
    uint deadline;
  }

  event PaymentLog(address spender, address recipient, string reason, uint amount, uint date);
  event NewMemberLog(address newMember, address memberAdmin, uint date);
  event NewElectionLog(address member, address nominee, uint position, uint date, uint index);
  event NewAmendmentLog(address member, uint clause, uint newValue, uint date, uint index);
  event NewIssueLog(address member, string description, uint date, uint index);

  //constructor
  function Uniond(){
      member[msg.sender] = Member(now, now, true, true, true, true, true, now, now, 0, 0);
      members.push(msg.sender);
      constitution[0] = 1; //minSignaturesForSpend
      constitution[1] = 2419200; //electionDuration
      constitution[2] = 50; //electionWinThreshold
      constitution[3] = 31536000; //mandateDuration
      constitution[4] = 66; //amendmentWinThreshold
      constitution[5] = 1000; //joiningFee
      constitution[6] = 31536000; //subscriptionPeriod
      constitution[7] = 2419200; //issue duration
      tokens[msg.sender] = 1000000; //initialTokens
      tokenSupply = tokens[msg.sender]; //set initial token supply
  }

  modifier onlyMemberAdmin {
      if (member[msg.sender].isApproved 
        && member[msg.sender].isMemberAdmin 
        && (now - member[msg.sender].electedMemberAdminDate) < constitution[3]) {
        _ ;
      }
  }

  modifier onlyTreasurer {
      if (member[msg.sender].isApproved 
        && member[msg.sender].isTreasurer 
        && (now - member[msg.sender].electedTreasurerDate) < constitution[3]) {
        _ ;
      }
  }

  modifier onlyMember {
      if (member[msg.sender].isApproved 
        && member[msg.sender].isMember 
        && (now - member[msg.sender].renewalDate) < constitution[6]) {
        _ ;
      }
  }

  /// @notice Allow treasurer to spend UnionD funds
  /// @return payment success
  function spendFunds(address _to, uint _amount, string _reason) onlyTreasurer 
           returns (bool success){
    if(!_to.send(_amount)){
        throw;
      } else {
        PaymentLog(msg.sender, _to, _reason, _amount, now);
        return true;
      }
  }

  /// @notice Gets the total membership count
  /// @return count of the total members (active and inactive)
  function getMemberCount() constant returns (uint count){
    return members.length;
  }

  /// @notice Reviews the active membership of the Uniond
  /// @param start index to start from;
  /// @param end index to end on;
  /// @return success if the review was successful;
  function reviewActiveMembers(uint start, uint end) onlyTreasurer returns (bool success){
    if(start == 0){
      memberReviews.push(MemberReview(now, 0, 0));
    }
    if(start > 0 
      && memberReviews[memberReviews.length -1].lastEndIndex != start){
      return false;
    }
    for(uint i = start; i < end; i++){
        if(!(memberReviews[memberReviews.length -1].reviewed[i]) 
          && now - member[members[i]].renewalDate < constitution[6]){
          memberReviews[memberReviews.length -1].tempActiveMembers++;
          memberReviews[memberReviews.length -1].reviewed[i] = true;
        }
    }
    if(end == members.length){
      activeMembers = memberReviews[memberReviews.length -1].tempActiveMembers;
    }
    memberReviews[memberReviews.length -1].lastEndIndex = end;
    return true;
  }

  /// @notice Creates a new election object
  /// @param nominee person up for election or removal from power
  /// @param position what role or removal from role they are up for
  /// @return success if it is successful
  function addElection(address nominee, uint position) onlyMember returns (bool success){
      uint duration = constitution[1];
      uint deadline = now + duration;
      elections.push(Election(msg.sender, nominee, position, deadline, false, 0));
      NewElectionLog(msg.sender, nominee, position, now, elections.length);
      return true;
  }

  /// @notice Members can vote on an election
  /// @param election which election they are voting on
  /// @return success if their vote was cast
  function voteElection(uint election) onlyMember returns (bool success){
      if(now < elections[election].deadline 
        && !elections[election].hasVoted[msg.sender]){
          elections[election].hasVoted[msg.sender] = true;
          elections[election].votes++;
          return true;
      }
      return false;
  }

  /// @notice Determines the result of an election
  /// @param election which election the call is on
  /// @return result if successful or not
  function callElection(uint election) returns (bool result){
    //check recent memberReview has been conducted and completed
      if(now - memberReviews[memberReviews.length -1].reviewDate < 1 days
       && memberReviews[memberReviews.length -1].tempActiveMembers == activeMembers
       && (elections[election].votes*100)/activeMembers > constitution[2]){
        return true;
      } else {
        return false;
      }
  }

    //positions; 1 == treasurer, 2 == memberAdmin, 3 == chair, 4 == representative 
    // 5 == revoke treasurer, 6 == revoke memberAdmin, 
    // 7 == revoke Chair, 8 == revoke representative
    /// @notice Execute the mandate of an election
    /// @param election which election is it
    /// @return success if the mandate is executed
    function executeElectionMandate(uint election) returns (bool success){
      if(member[elections[election].nominee].exists 
        && !elections[election].executed 
        && callElection(election)){
        address nominee = elections[election].nominee;
        if(elections[election].role == 1){
          //add treasurer
          member[nominee].isTreasurer = true;
          elections[election].executed = true;
          member[nominee].electedTreasurerDate = now;
        } else if (elections[election].role == 2){
          //add memberAdmin 
          member[nominee].isMemberAdmin = true;
          elections[election].executed = true;
          member[nominee].electedMemberAdminDate = now;
        } else if (elections[election].role == 5) {
          //revoke treasurer
          member[nominee].isTreasurer = false;
          elections[election].executed = true;
        } else if (elections[election].role == 6) {
          //revoke memberAdmin
          member[nominee].isMemberAdmin = false;
          elections[election].executed = true;
        } else {
          return false;
        }
        return true;
      } else {
        //fail case
        return false;
      }
    }

  /// @notice Apply to be a member - must pay joiningFee
  /// @return success if the joiningFee is paid
  function applyMember() payable returns (bool success){
      if(msg.value >= constitution[5] 
        && !member[msg.sender].exists){
        //dont include old issues in vote count
        member[msg.sender] = Member(now, now, true, false, false, false, false, 0, 0, issues.length, 0); 
        members.push(msg.sender);
        return true;
      }
      return false;
  }

  /// @notice Renew existing membership
  /// @return success if the membership is renewed
  function renewMembership() returns (bool success){
    if(msg.value >= constitution[5] 
      && member[msg.sender].exists 
      && member[msg.sender].isApproved){
      member[msg.sender].isMember = true;
      member[msg.sender].renewalDate = now;
      return true;
    }
    //refund msg.value?
    return false;
  }

  /// @notice approved newMember
  /// @param newMember address of the new member
  /// @return success if the new member is added
  function addMember(address newMember) onlyMemberAdmin returns (bool success){
      if(member[newMember].exists){
        member[newMember].isApproved = true;
        member[newMember].isMember = true;
        NewMemberLog(newMember, msg.sender, now);
        return true;
      }
      return false;
  }

  /// @notice treasurers can set the joiningFee
  /// @param fee the amount to set
  /// @return success if the fee is set
  function setJoiningFee(uint fee) onlyTreasurer returns (bool success){
      constitution[5] = fee;
      return true;
  }

  /// @notice get the union contract's ether balance
  /// @return balance the balance of the contract
  function unionBalance() constant returns (uint balance) {
      return this.balance;
  }

  /// @notice create new issue, all members get a vote
  /// @param description what the issue is about
  /// @return success if the issue is set
  function addIssue(string description) onlyMember returns (bool success){
      uint deadline = now + constitution[7];
      issues.push(Issue(msg.sender, description, now, 0, 0, deadline));
      NewIssueLog(msg.sender, description, now, issues.length);
      return true;
  }

  /// @notice vote on a given issue n times
  /// @param issue which issue it is
  /// @param approve whether it is for or against the issue
  /// @param amount how many votes to cast
  /// @return success if the votes are cast
  function vote(uint issue, bool approve, uint amount) onlyMember returns (bool success){
      if(now < issues[issue].deadline 
        && (issues.length + member[msg.sender].delegatedVotes - member[msg.sender].spentVotes) >= amount){
        member[msg.sender].spentVotes += amount;
        if(approve){
          issues[issue].approve += amount;
        } else {
          issues[issue].disapprove += amount;
        }
        return true;
      }
      return false;
  }

  /// @notice transfer votes to a proxy
  /// @param reciever who is the proxy
  /// @param amount how many votes to give them
  /// @return success if the votes are transfered
  function transferVotes(address reciever, uint amount) returns (bool success){
      if((issues.length + member[msg.sender].delegatedVotes - member[msg.sender].spentVotes) >= amount){
        member[msg.sender].spentVotes += amount;
        member[reciever].delegatedVotes += amount;
        return true;
      }
      return false;
  }

  /// @notice create new amendment object
  /// @param reason for the amendment
  /// @param clause which constitution setting to amendment
  /// @param value what to change it to
  /// @return success if the amendment is created
  function newAmendment(string reason, uint clause, uint value) onlyMember returns (bool success){
    uint duration = constitution[1];
    uint deadline = now + duration;
    address[] memory votes;
    amendments.push(Amendment(reason, clause, value, deadline, false, votes));
    NewAmendmentLog(msg.sender, clause, value, now, amendments.length);
    return true;
  }

  /// @notice Members can vote on an amendment
  /// @param amendment which amendment they are voting on
  /// @return success if their vote was cast
  function voteAmendment(uint amendment) onlyMember returns (bool success){
      if(now < amendments[amendment].deadline 
        && !amendments[amendment].hasVoted[msg.sender]){
          amendments[amendment].votes.push(msg.sender);
          amendments[amendment].hasVoted[msg.sender] = true;
          return true;
      }
      return false;
  }

  /// @notice call an amendment 
  /// @param amendment which to call
  /// @return result true if it is past
  function callAmendment(uint amendment) returns (bool result){
    //check that a member review has been conducted in the past day
      if(now - memberReviews[memberReviews.length -1].reviewDate < 1 days
       && memberReviews[memberReviews.length -1].tempActiveMembers == activeMembers
       && (amendments[amendment].votes.length / activeMembers)*100 > constitution[4]){
        return true;
      }
      return false;
    }

  /// @notice execute amendment object
  /// @param amendment which to execute
  /// @return success if amendment is executed
  function executeAmendmentMandate(uint amendment) returns (bool success){
      if(!amendments[amendment].executed 
        && callAmendment(amendment)){
        constitution[amendments[amendment].clause] = amendments[amendment].value;
        amendments[amendment].executed = true;
        return true;
      }
      return false;
    }

  /// @notice get supply of issue votes
  /// @return supply of votes
  function totalVotes() constant returns (uint256 votes){
    return (issues.length + member[msg.sender].delegatedVotes - member[msg.sender].spentVotes);
  }

  /// @notice get supply of tokenSupply
  /// @return supply of tokens
  function totalSupply() constant returns (uint256 supply){
      return tokenSupply;
    }

  /// @notice get token balance
  /// @param _owner whose account we are checking
  /// @return balance how many tokens they have
  function balanceOf(address _owner) constant returns (uint256 balance){
      return tokens[_owner];
    }

  /// @notice transfer tokens
  /// @param _to who to transfer to
  /// @param _value how much to transfer
  /// @return success if the transfer happened
  function transfer(address _to, uint256 _value) returns (bool success){
      if(tokens[msg.sender] >= _value){
        tokens[msg.sender] -= _value;
        tokens[_to] += _value;
        return true;  
      }
      return false;
    }

}