
    /*
    https://github.com/ethereum/wiki/wiki/Solidity-Tutorial
    
    "Democracy DAO" slightly modified from: https://github.com/ethereum/go-ethereum/wiki/Contract-Tutorial
    
    !!!IMPORTANT, MUST DO FIRST!!!
    CREATE THE "token" CONTRACT FIRST, THEN COPY / PASTE THAT CONTRACT'S JAVASCRIPT CODE IN THE TEXT AREA ABOVE THIS ONE LABELED "Javascript Run Before Contract Creation", THEN DIRECTLY BELOW THAT CODE ADD THIS CODE:
    var var_1 = token.address;  // Ignore this example AFTER running javascript on this source code, it will get modified along with the "var_*" vars in the code
    
    */


contract token { mapping (address => uint) public coinBalanceOf;   function token() { }   function sendCoin(address receiver, uint amount) returns(bool sufficient) {  } }


contract Democracy {

    uint public minimumQuorum;
    uint public debatingPeriod;
    token public voterShare;
    address public founder;
    Proposal[] public proposals;
    uint public numProposals;

    event ProposalAdded(uint proposalID, address recipient, uint amount, bytes32 data, string description);
    event Voted(uint proposalID, int position, address voter);
    event ProposalTallied(uint proposalID, int result, uint quorum, bool active);

    struct Proposal {
        address recipient;
        uint amount;
        bytes32 data;
        string description;
        uint creationDate;
        bool active;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Vote {
        int position;
        address voter;
    }

    function Democracy(token _voterShareAddress, uint _minimumQuorum, uint _debatingPeriod) {
        founder = msg.sender;  
        voterShare = token(var_1);  //  The token contract address
        minimumQuorum = 40; // Minimum amount of voter tokens the proposal needs to pass
        debatingPeriod = 30 days; // debating period
    }


    function newProposal(address _recipient, uint _amount, bytes32 _data, string _description) returns (uint proposalID) {
        if (voterShare.coinBalanceOf(msg.sender)>0) {
            proposalID = proposals.length++;
            Proposal p = proposals[proposalID];
            p.recipient = _recipient;
            p.amount = _amount;
            p.data = _data;
            p.description = _description;
            p.creationDate = now;
            p.active = true;
            ProposalAdded(proposalID, _recipient, _amount, _data, _description);
            numProposals = proposalID+1;
        }
    }

    function vote(uint _proposalID, int _position) returns (uint voteID){
        if (voterShare.coinBalanceOf(msg.sender)>0 && (_position >= -1 || _position <= 1 )) {
            Proposal p = proposals[_proposalID];
            if (p.voted[msg.sender] == true) return;
            voteID = p.votes.length++;
            p.votes[voteID] = Vote({position: _position, voter: msg.sender});
            p.voted[msg.sender] = true;
            Voted(_proposalID,  _position, msg.sender);
        }
    }

    function executeProposal(uint _proposalID) returns (int result) {
        Proposal p = proposals[_proposalID];
        /* Check if debating period is over */
        if (now > (p.creationDate + debatingPeriod) && p.active){   
            uint quorum = 0;
            /* tally the votes */
            for (uint i = 0; i <  p.votes.length; ++i) {
                Vote v = p.votes[i];
                uint voteWeight = voterShare.coinBalanceOf(v.voter); 
                quorum += voteWeight;
                result += int(voteWeight) * v.position;
            }
            /* execute result */
            if (quorum > minimumQuorum && result > 0 ) {
                p.recipient.call.value(p.amount)(p.data);
                p.active = false;
            } else if (quorum > minimumQuorum && result < 0) {
                p.active = false;
            }
            ProposalTallied(_proposalID, result, quorum, p.active);
        }
    }
}