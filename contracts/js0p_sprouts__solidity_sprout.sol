pragma solidity ^0.4.15;

/// @title Math operations with safety checks
library SafeMath {
    function mul(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }
}

contract BasicSprout {

	using SafeMath for uint256;
	
    uint256 public totalBalance;
    address public maxFundedProposal; // can be used to query as well
    mapping (address => uint256) public balances;
    mapping (address => address) votedProposal;
    mapping (address => uint) fundingOfProposal;

    modifier onlyNotVoted(address voter) {
        if(votedProposal[voter] == address(0)) {
            _;
        } else {
            Error("The voter has voted already!");
        }
    }

    modifier hasBalance(address voter){
        if(balanceOf(voter) != 0) {
            _;
        } else {
            Error("One has to have balances in his account in order to vote!");
        }
    } 

    function BasicSprout() {}
	
    // fallback function for ppl to put funds into our contract 
    function () external payable {
		balances[msg.sender] = balances[msg.sender].add(msg.value);
		totalBalance = totalBalance.add(msg.value);
    }

    function finalizeProposal() external constant returns (address _proposal) {
        _proposal = maxFundedProposal;
    }

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function vote(address _proposal) external onlyNotVoted(msg.sender) hasBalance(msg.sender) {
        // vote 
        votedProposal[msg.sender] = _proposal;
        fundingOfProposal[_proposal] = fundingOfProposal[_proposal].add(balanceOf(msg.sender));

        // find max
        if(fundingOfProposal[_proposal] > fundingOfProposal[maxFundedProposal]) {
            maxFundedProposal = _proposal;
        }
    }

    event Error(string message);
    
}   