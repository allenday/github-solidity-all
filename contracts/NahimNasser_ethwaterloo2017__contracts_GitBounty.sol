pragma solidity ^0.4.2;

contract GitBountyCreator {
    address[] bountiesAddressesArray;
    function createBounty(string issueUrl, address[] voters,uint256  expiresIn ) public payable returns(address) {
        GitBounty b = new GitBounty(issueUrl, voters, expiresIn, this);
        b.addToBounty.value(msg.value)();
        bountiesAddressesArray.push(b);
        return b;
    }
    function getAllBounties() public constant returns (address[]) {
      return bountiesAddressesArray;
    }
}

contract GitBounty {
    GitBountyCreator public parent;

    // Returned in getAllTheThings in that order
    string public key;
    address public owner;
    uint256 public totalBounty;
    uint256 public expiresAt;
    address[] public voterAddresses;
    uint256 public numberOfVotersWhoVoted;
    address[] public PRS;
    uint256 public totalPRS;
    uint256 public requiredNumberOfVotes;
    bool public isBountyOpen;

    function getAllTheThings() public constant returns(string, address, uint256, uint256, address[], uint256, address[], uint256, uint256, bool ) {
      return (key, owner, totalBounty, expiresAt, voterAddresses, numberOfVotersWhoVoted, PRS, totalPRS, requiredNumberOfVotes, isBountyOpen);
    }

    mapping (address => uint256) public contributions;
    mapping (address => bool) public eligibleVotersAddresses;
    mapping (address => uint256) public votes;
    mapping (bytes32 => bool) private hasVotedToAddress;
    mapping (address => bool) private hasVotedToAtleastOne;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier isEligibleVoter {
        require(eligibleVotersAddresses[msg.sender]);
        _;
    }
    modifier bountyOpen {
        require(isBountyOpen);
        _;
    }
    modifier votedOnce(address voter, address hunter) {
        require(!hasVoted(voter, hunter));
        _;
    }
    function GitBounty(string issueUrl, address[] voters,uint256  expiresIn, GitBountyCreator parentAddress ) public payable {
        parent = parentAddress;
        key = issueUrl;
        isBountyOpen = true;
        expiresAt += expiresIn + now;
        totalBounty += msg.value;
        owner = msg.sender;
        voterAddresses = voters;
        requiredNumberOfVotes = (voterAddresses.length / 2 )  + 1;
        for (uint256 i=0; i < voterAddresses.length; i++ ){
            eligibleVotersAddresses[voterAddresses[i]] = true;
        }
        contributions[msg.sender] += msg.value;
    }
    function addToBounty() public payable bountyOpen {
        contributions[msg.sender] += msg.value;
        totalBounty += msg.value;
    }
    function vote(address addr) public isEligibleVoter bountyOpen votedOnce(msg.sender, addr) returns (bool) {
        votes[addr] += 1;
        if (votes[addr] == 1 ) {
          // New PR vote
          PRS.push(addr);
          totalPRS++;
        }
        if (!hasVotedToAtleastOne[msg.sender]) {
            numberOfVotersWhoVoted++;
            hasVotedToAtleastOne[msg.sender] = true;
        }
        addVotePair(msg.sender, addr);
        return doCount(addr);
    }
    function doCount(address addr) private returns (bool) {
        if (votes[addr] >= requiredNumberOfVotes) {
            addr.transfer(totalBounty);
            isBountyOpen = false;
        }

        return isBountyOpen;
    }
    function addVotePair(address voter, address hunter) private {
        hasVotedToAddress[keccak256(voter, hunter)] = true;
    }
    function hasVoted(address voter, address hunter) private constant returns (bool) {
        return hasVotedToAddress[keccak256(voter, hunter)];
    }
    function getAllPRS() public constant returns (address[]) {
      return PRS;
    }


}
