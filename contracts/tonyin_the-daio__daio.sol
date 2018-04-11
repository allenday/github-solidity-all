pragma solidity ^0.4.15;

contract SafeMath {
    function safeAdd(uint a, uint b) internal returns(uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
    function safeSub(uint a, uint b) internal returns (uint) {
        assert (b <= a);
        return a - b;
    }
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
}

contract Daio is SafeMath {
    uint public membersMinimum = 2;
    uint public membersTotal;
    Member[] public members;
    mapping(address => uint256) public memberId;
    event MembershipChanged(address member, bool isMember);

    struct Member {
        address member;
        string name;
        uint share;
    }

    uint public fundTotal;
    uint public fundShare;
    uint public contributionMinimumTime;
    uint public fundMinimumTime;
    bool public fundActive = false;
    event FundingChanged(uint total);
    event SurplusReturned(uint share, uint shareMax, uint surplus);
    event FundLaunched(uint funds, uint mems, uint share, uint minTime);
    event ShareDistributed(address member, string name, uint share);
    event FundLiquidated(uint funds, uint mems, uint share);

    uint public proposalsTotal;
    Proposal[] public proposals;
    event ProposalAdded(uint proposalId, address recipient, uint volume, uint price);
    event ProposalPassed(uint proposalId, bool passed, uint votesFor);
    event ProposalExecuted(uint proposalId, address recipient, uint volume, uint price);

    struct Proposal {
        address recipient;
        uint volume;
        uint price;
        string description;
        uint deadline;
        bool passed;
        bool executed;
        bytes32 proposalHash;
        uint votesFor;
        uint votesTotal;
        Vote[] votes;
        mapping(address => bool) voted;
    }

    event Voted(uint proposalId, bool support, address member);

    struct Vote {
        address member;
        bool support;
    }

    modifier onlyMembers {
        require(memberId[msg.sender] != 0);
        _;
    }

    modifier onlyNew {
        require(memberId[msg.sender] == 0);
        _;
    }

    function Daio(uint contributionMinimumMinutes) payable public {
        require(msg.value > 0);
        contributionMinimumTime = safeAdd(now, contributionMinimumMinutes * 1 minutes);
        addMember(0, "daio", 0); // dummy daio for member 0
        addMember(msg.sender, "founder", msg.value);
        fundShare = msg.value;
        fundTotal = safeAdd(fundTotal, msg.value);
        FundingChanged(fundTotal);
    }

    function addMember (address member, string name, uint share) private {
        uint id = memberId[member];
        if (id == 0) {
            memberId[member] = members.length;
            id = members.length++;
        }
        members[id] = Member({
            member: member,
            name: name,
            share: share
        });
        membersTotal = id;
        MembershipChanged(member, true);
    }

    function removeMember (uint id) private {
        address member = members[id].member;
        memberId[member] = 0;
        delete members[id];
        members.length--;
    }

    function contributeFund(string memberName) payable onlyNew public {
        require(!fundActive);
        require(msg.value >= fundShare);
        uint share = msg.value;
        if (fundShare == 0) { // first contribution
            fundShare = share;
        }
        if (share > fundShare) {
            uint surplus = safeSub(share, fundShare);
            share = safeSub(share, surplus);
            msg.sender.transfer(surplus);
            SurplusReturned(msg.value, fundShare, surplus);
        }
        addMember(msg.sender, memberName, share);
        fundTotal = safeAdd(fundTotal, share);
        FundingChanged(fundTotal);
    }

    function launchFund(uint fundMinimumMinutes) onlyMembers public {
        require(now >= contributionMinimumTime);
        require(!fundActive);
        require(members.length-1 >= membersMinimum);
        fundActive = true;
        fundMinimumTime = safeAdd(now, fundMinimumMinutes * 1 minutes);
        FundLaunched(fundTotal, membersTotal, fundShare, fundMinimumTime);
    }

    function addProposal(
        address recipient,
        uint volume,
        uint price,
        string description,
        uint votingMinutes,
        bytes transactionBytecode
    ) onlyMembers public
    {
        require(fundActive == true);
        uint proposalId = proposals.length++;
        Proposal storage p = proposals[proposalId]; // construct explicitly
        p.recipient = recipient;
        p.volume = volume;
        p.price = price;
        p.description = description;
        p.deadline = safeAdd(now, votingMinutes * 1 minutes);
        p.passed = false;
        p.executed = false;
        p.votesFor = 0;
        p.votesTotal = 0;
        p.proposalHash = keccak256(recipient, volume, price, transactionBytecode);
        proposalsTotal = proposals.length;
        ProposalAdded(proposalId, recipient, volume, price);
    }

    function voteProposal(uint proposalId, bool support) onlyMembers public {
        Proposal storage p = proposals[proposalId];
        require(!p.voted[msg.sender]);
        require(now <= p.deadline);
        p.voted[msg.sender] = true;
        uint voteId = p.votes.length++;
        p.votesTotal = p.votes.length;
        if (support) {
            p.votesFor += 1;
        }
        p.votes[voteId] = Vote({
            member: msg.sender,
            support: support
        });
        Voted(proposalId, support, msg.sender);
        if (p.votesFor > membersTotal / 2) { // simple majority (>50%). Note: standard integer division returns floor
            p.passed = true;
            ProposalPassed(proposalId, true, p.votesFor);
        }
    }

    function checkProposalCode(
        uint proposalId,
        address recipient,
        uint volume,
        uint price,
        bytes transactionBytecode
    ) constant public returns(bool codeCheckCorrect) {
        Proposal storage p = proposals[proposalId];
        return p.proposalHash == keccak256(recipient, volume, price, transactionBytecode);
    }

    function executeProposal(uint proposalId, bytes transactionBytecode) onlyMembers public {
        Proposal storage p = proposals[proposalId];
        require(p.passed);
        require(!p.executed);
        require(checkProposalCode(proposalId, p.recipient, p.volume, p.price, transactionBytecode));
        ProposalExecuted(proposalId, p.recipient, p.volume, p.price);
    }

    function liquidateFund() onlyMembers payable public {
        require(now >= fundMinimumTime);
        require(fundActive);
        fundActive = false;
        uint share = fundTotal / membersTotal;
        for (uint i = 1; i < members.length; i++) {
            members[i].member.transfer(share);
            ShareDistributed(members[i].member, members[i].name, share);
        }
        FundLiquidated(fundTotal, membersTotal, share);
        for (i = 1; i <= members.length; i++) {
            removeMember(i);
        }
        membersTotal = 0;
        fundTotal = 0;
        fundShare = 0;
    }
}
