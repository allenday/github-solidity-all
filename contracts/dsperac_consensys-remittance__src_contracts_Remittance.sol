pragma solidity ^0.4.5;

import "./Ownable.sol";

contract Remittance is Ownable {

    uint constant MIN_DEADLINE = 1;
    uint constant MAX_DEADLINE = 500;

    struct Challenge {
        uint amount;
        uint deadline;
        address challengeOwner;
    }
    mapping(bytes32 => Challenge) public challenges;
    mapping(address => uint) public accounts;

    event OnChallengeRegistered(address indexed challengeOwner, bytes32 indexed challengeHash, uint amount, uint deadline);
    event OnChallengeSolved(address indexed solver, uint amount);
    event OnRefund(address refundAddress, uint amount);
    event OnWithdrawal(address indexed account, uint amountWithdrawn);

    function registerChallenge(bytes32 challengeHash, uint deadline) payable returns (bool isSuccessful) {
        require(msg.value > 0);
        require(deadline >= MIN_DEADLINE && deadline <= MAX_DEADLINE);

        Challenge memory challenge = Challenge(msg.value, block.number + deadline, msg.sender);
        challenges[challengeHash] = challenge;

        OnChallengeRegistered(msg.sender, challengeHash, msg.value, deadline);

        return true;
    }

    function solveChallenge(bytes32 password) returns (bool isSuccessful) {
        bytes32 hashed = keccak256(password, msg.sender);
        Challenge storage challenge = challenges[hashed];

        require(challenge.amount > 0);
        require(!hasDeadlinePassed(hashed));

        accounts[msg.sender] += challenge.amount;
        challenge.amount = 0;

        OnChallengeSolved(msg.sender, challenge.amount);

        return true;
    }

    function hasDeadlinePassed(bytes32 challengeHash) public returns (bool) {
        return block.number > challenges[challengeHash].deadline;
    }

    function requestRefund(bytes32 challengeHash) public returns (bool) {
        Challenge storage challenge = challenges[challengeHash];

        require(challenge.amount > 0);
        require(hasDeadlinePassed(challengeHash));
        require(challenge.challengeOwner == msg.sender);

        accounts[msg.sender] += challenge.amount;
        challenge.amount = 0;

        OnRefund(msg.sender, challenge.amount);

        return true;
    }

    function withdraw() public returns (bool) {
        uint senderBalance = accounts[msg.sender];

        require(senderBalance > 0);
        require(this.balance >= senderBalance);

        msg.sender.transfer(senderBalance);
        accounts[msg.sender] = 0;

        OnWithdrawal(msg.sender, senderBalance);

        return true;
    }

    function killMe() onlyOwner {
        selfdestruct(owner);
    }
}
