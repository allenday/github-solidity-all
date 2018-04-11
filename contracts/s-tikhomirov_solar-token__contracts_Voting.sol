pragma solidity ^0.4.13;

contract Voting {
    
    enum Role { OWNER, COMPANY, RESIDENT, AUDITOR }
    enum State { INITIAL, OPEN, APPROVED, INSTALLING, AUDITED, CLOSED, FAILED }
    
    mapping (address => Role) roles;
    State public state;
    
    event Funded(address addr, uint amount);
    event VotingOpened(uint threshold);
    event Approved(address addr, uint total);
    event VotingClosedSuccess(uint total);
    event VotingFailed();
    event Withdrawn(address addr, uint amount);
    event Audited();
    event InstallationFailed();
    event Closed();
    
    mapping (address => bool) approved;
    
    uint numRoles = 4;
    uint numApproved;   // number of residents who approved
    uint threshold;     // required support in persent (1 to 100)
    uint firstWithdrawalShare = 50;     // share that company withdraws before installation
    uint thresholdPercent = 70;         // required approval
    uint votingDeadline;
    uint defaultVotingDuration = 1 years;
    uint installationDeadline;
    uint defaultInstallationDuration = 1 years;

	// Addresses generated from seed.txt
    address[] private testAddresses;
    
    function assignTestAddresses(bool isRpc) internal {
        if (isRpc) {
    		testAddresses.push(0x0120fe6e3aa2c936e6d2f88062b266c46c408f98);
    		testAddresses.push(0xa8fc189694dc8ba03c027d470b77c09b7d13471e);
    		testAddresses.push(0xdbf73038f3e4a5d27e38004c36dc6ce82165794f);
    		testAddresses.push(0x692b50dc6d0021a73ec50fcd3ad78d3c121be360);
    		testAddresses.push(0xc396dfc357c849c5e4fbbe1f130eb469675af895);
    		testAddresses.push(0x07efc80760137f58a43e44a9bede15da8053d730);
    		testAddresses.push(0xfe8699b505180f51966e56f118e66544dea311bd);
    		testAddresses.push(0x276ae02aa2710bebc571f3647d64d9b440f998d6);
    		testAddresses.push(0x43882f2be5ccf7ba1cf848e202683385d5fb93bb);
    		testAddresses.push(0x76c780eb591481c086e1a0574b16c4f52e5aa352);
        } else {
            testAddresses.push(0xca35b7d915458ef540ade6068dfe2f44e8fa733c);
            testAddresses.push(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c);
            testAddresses.push(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db);
            testAddresses.push(0x583031d1113ad414f02576bd6afabfb302140225);
            testAddresses.push(0xdd870fa1b7c4700f2bd7f44238821c26f7392148);
        }
    }
    
	function assignRoles() internal {
	    require(msg.sender == testAddresses[0]);
	    require(testAddresses.length >= numRoles);
		roles[testAddresses[0]] = Role.OWNER;
		roles[testAddresses[1]] = Role.COMPANY;
		roles[testAddresses[2]] = Role.AUDITOR;
		for (uint i = numRoles-1; i < testAddresses.length; i++) {
		    roles[testAddresses[i]] = Role.RESIDENT;
		}
	}
	
	function Voting(bool isRpc) {
	    assignTestAddresses(isRpc);
	    assignRoles();
	    state = State.INITIAL;
	}
	
	function () payable {
	    require(roles[msg.sender] == Role.OWNER);
	    require(state == State.INITIAL);
	    Funded(msg.sender, msg.value);
	}
	
	// owner can deposit and withdraw ether before voting starts
	function withdrawBeforeVoting(uint _amount) {
	    require(state == State.INITIAL);
	    require(roles[msg.sender] == Role.OWNER);
	    withdraw(_amount);
	}
	
	function startVoting() {
	    require(roles[msg.sender] == Role.OWNER);
	    require(state == State.INITIAL);
	    require(this.balance > 0);
	    votingDeadline = now + defaultVotingDuration;
	    threshold = (thresholdPercent * (testAddresses.length - numRoles + 1) / 100);
	    state = State.OPEN;
	    VotingOpened(threshold);
	}
	
	function approve() {
	    require(now < votingDeadline);
	    require(roles[msg.sender] == Role.RESIDENT);
	    require(state == State.OPEN);
	    approved[msg.sender] = true;
	    numApproved += 1;
	    Approved(msg.sender, numApproved);
	    if (numApproved >= threshold) {
	        state = State.APPROVED;
	        installationDeadline = now + defaultInstallationDuration;
	        VotingClosedSuccess(numApproved);
	    }
	}
	
	function closeFailedVotingAndWithdraw() {
	    require(now >= votingDeadline);    // voting deadline passed
	    require(state == State.OPEN);      // but voting still "opened"
	    require(roles[msg.sender] == Role.OWNER);
	    state = State.FAILED;
	    VotingFailed();
	    withdraw(this.balance);
	}
	
	function closeFailedInstallationAndWithdraw() {
	    require(now >= installationDeadline);   // installation deadline passed
	    require(state == State.APPROVED || state == State.INSTALLING);      // but nothing was installed
	    require(roles[msg.sender] == Role.OWNER);
	    state = State.FAILED;
	    InstallationFailed();
	    withdraw(this.balance);
	}
	
	function withdraw(uint amount) internal {
	    msg.sender.transfer(amount);
	    Withdrawn(msg.sender, amount);
	}
	
	function withdrawFirst() {
	    require(now < installationDeadline);
	    require(roles[msg.sender] == Role.COMPANY);
	    require(state == State.APPROVED);
	    withdraw(this.balance * firstWithdrawalShare / 100);
	    state = State.INSTALLING;
	}
	
	function auditConfirm() {
	    require(now < installationDeadline);
	    require(roles[msg.sender] == Role.AUDITOR);
	    require(state == State.INSTALLING);
	    state = State.AUDITED;
	    Audited();
	}
	
	function withdrawSecond() {
	    require(roles[msg.sender] == Role.COMPANY);
	    require(state == State.AUDITED);
	    withdraw(this.balance);
	    state = State.CLOSED;
	    Closed();
	}

    function hasApproved(address addr) returns(bool) {
       return approved[addr];
    }

}
