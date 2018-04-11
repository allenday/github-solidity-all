pragma solidity ^0.4.17;

import "./MerkleTreeLib.sol";
import "./MiniMeToken.sol";
import "./StringLib.sol";
import "./IActionLib.sol";

contract Registry is Controlled {

    struct Values {
        mapping(bytes20 => uint) uints;
    }

    Values                      public votable;
    uint                        public endowEnd;
    uint                        public sigVote = 500;
    uint                        public sigVoteDelay = 43;                                       // ~ 10 min @ 14s/block
    uint                        public propDuration = 43200;                                    // ~ 1 week @ 14s/block
    MiniMeToken                 public token;
    MiniMeTokenFactory          public tokenFactory;
    bytes32[]                   public roots;

    mapping(address => bytes20) public addressToUsername;
    mapping(bytes20 => address) public usernameToAddress;

    event Registered(bytes20 username, address owner, uint endowment);
    event PropAdded(bytes20 username, uint propIdx);
    event Voted(bytes20 username, uint propIdx, uint prefIdx);

    function Registry(bytes32 _root, uint16 _endowDuration) {
        roots.push(_root);
        endowEnd = block.number + _endowDuration;
        tokenFactory = new MiniMeTokenFactory();
        token = new MiniMeToken(
            tokenFactory,
            0,// address _parentToken,
            0,// uint _snapshotBlock,
            "EthTrader Token",// string _tokenName,
            9,// uint8 _decimalUnits,
            "ETR",// string _tokenSymbol,
            false// bool _transfersEnabled
            );
        votable.uints["TEST_VALUE"] = 400;
    }

    function register(
        bytes20 _username,
        uint24 _endowment,
        uint32 _firstContent,
        bytes32[] proof,
        uint16 _rootIndex
    ) public {

        // only register address & username once
        require(addressToUsername[msg.sender] == 0 && usernameToAddress[_username] == 0);

        bytes32 hash = keccak256(msg.sender, _username, _endowment, _firstContent);

        require(MerkleTreeLib.checkProof(proof, roots[_rootIndex], hash));

        addressToUsername[msg.sender] = _username;
        usernameToAddress[_username] = msg.sender;

        if(block.number < endowEnd)
            token.generateTokens(msg.sender, _endowment);

        Registered(_username, msg.sender, _endowment);
    }

    function addRoot(bytes32 _root) public onlyController {
        roots.push(_root);
    }

    function enableTransfers() public {
        require(block.number >= endowEnd);
        token.enableTransfers(true);
    }

    function check(
        bytes20 _username,
        uint24 _endowment,
        uint32 _firstContent,
        bytes32[] proof,
        uint16 _rootIndex
    ) public view returns (bool, bytes32) {
        bytes32 hash = keccak256(msg.sender, _username, _endowment, _firstContent);
        return (MerkleTreeLib.checkProof(proof, roots[_rootIndex], hash), hash);
    }

    // playing with voting

    struct Prop {
        MiniMeToken token;
        ActionLib actionLib;
        uint startedAt;
        uint lastSigVoteAt;
        uint[] results;
        mapping(address => bool) voted;
    }

    Prop[] public props;

    function addProp(string _name, string _symbol, ActionLib _actionLib) public {
        // TODO - ensure sufficient "stake"
        bytes20 username = addressToUsername[msg.sender];
        require(username != "0x");                                              // is user registered

        uint nextPropIdx = props.length - 1;
        MiniMeToken propToken = tokenFactory.createCloneToken(
            token,
            block.number,
            _name,
            token.decimals(),
            _symbol,
            false
            );

        Prop memory prop;
        prop.token = propToken;
        prop.actionLib = _actionLib;
        prop.startedAt = block.number;

        props.push(prop);
    }

    function resolveProp(uint _propIdx) public {
        Prop prop = props[_propIdx];

        require(
            block.number >= prop.lastSigVoteAt + sigVoteDelay &&
            block.number >= prop.startedAt + propDuration
            );

        require(prop.results[1]/2 > prop.results[0]);                           // need 2/3 majority to pass
        prop.actionLib.run(votable);
    }

    function vote(uint _propIdx, uint _prefIdx) public {
        bytes20 username = addressToUsername[msg.sender];
        require(username != "0x");                                              // is user registered

        Prop prop = props[_propIdx];

        require(prop.voted[msg.sender] == false);                               // didn't already vote
        require(                                                                // prop still active
            block.number < prop.startedAt + propDuration ||
            block.number < prop.lastSigVoteAt + sigVoteDelay
            );

        uint weightedVote = prop.token.balanceOf(msg.sender);                   // TODO - add time component to weight
        if(weightedVote >= sigVote)
            prop.lastSigVoteAt = block.number;
        prop.results[_prefIdx] += weightedVote;
        prop.voted[msg.sender] == true;
        Voted(username, _propIdx, _prefIdx);
    }

}
