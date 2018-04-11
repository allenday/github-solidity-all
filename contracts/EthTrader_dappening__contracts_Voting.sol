pragma solidity ^0.4.17;

import "./MiniMeToken.sol";
// import "./Registry.sol";
import "./Interfaces.sol";
// import "./Store.sol";
// import "./EthTraderLib.sol";

contract Voting {

    enum Actions                  { NONE, UPGRADE, ADD_ROOT, TOGGLE_TRANSFERABLE, TOGGLE_REG_ENDOW, SET_VALUE, ENDOW, DEREG }

    struct Prop {
        Actions                     action;
        bytes32                     data;
        uint                        startedAt;
        uint                        lastSigVoteAt;
        bytes20                     author;
        uint                        stake;
        mapping(uint => uint)       results;
        mapping(address => bool)    voted;
    }

    mapping(uint => bool)           public passed;
    mapping(uint => bool)           public failed;
    /* bytes20[]                       public actions = [bytes20("NONE")]; */
    IStore                          public store;
    IRegistry                       public registry;
    IMiniMeToken                    public token;
    Prop[]                          public props;

    event Proposed(uint propIdx);
    event Voted(bytes20 username, uint propIdx, uint prefIdx);
    event Resolved(uint propIdx, bool result);

    function addProp(Actions _action, bytes32 _data) public {
        bytes20 username = registry.ownerToUsername(msg.sender);
        require( username != 0 );

        Prop memory prop;

        if(_action == Actions.NONE) {                                             // is "NONE" action, treat as poll
            require( token.destroyTokens(msg.sender, store.values("POLL_COST")) );
        } else {
            prop.stake = store.values("PROP_STAKE");
            require( token.transferFrom(msg.sender, 1, prop.stake) );
        }

        prop.action = _action;
        prop.data = _data;
        prop.startedAt = block.number;
        prop.author = username;

        Proposed(props.push(prop)-1);
    }

    function resolveProp(uint _propIdx) internal returns(bool) {
        Prop storage prop = props[_propIdx];

        require(
            prop.action != Actions.NONE &&
            passed[_propIdx] == false &&
            failed[_propIdx] == false &&
            block.number >= prop.lastSigVoteAt + store.values("SIG_VOTE_DELAY") &&
            block.number >= prop.startedAt + store.values("PROP_DURATION")
            );

        if(prop.results[1]/2 > prop.results[0]) {                             // need 2/3 majority to pass
            passed[_propIdx] = true;
            // return staked tokens
            require( token.transferFrom(1, registry.getOwner(prop.author), prop.stake) );
            return true;
        } else {
            failed[_propIdx] = true;
            // burn staked tokens
            require( token.destroyTokens(1, prop.stake) );
            return false;
        }
    }

    function getResult(uint _propIdx, uint _prefIdx) public view returns (uint) {
        Prop storage prop = props[_propIdx];
        return prop.results[_prefIdx];
    }

    function getVoted(uint _propIdx) public view returns (bool) {
        Prop storage prop = props[_propIdx];
        return prop.voted[msg.sender];
    }

    function getWeightedVote(bytes20 _username, uint _propIdx) public view returns (uint) {        // override this method in DAO
        Prop storage prop = props[_propIdx];
        return token.balanceOfAt(msg.sender, prop.startedAt);
    }

    function getNumProps() public view returns (uint) {
        return props.length;
    }

    /* function getProps() public view returns (Prop[]) { */
    function getProps() public view returns (Actions[], bytes32[], uint[], uint[], bool[], bool[], bool[]) {
        Actions[]    memory actions = new Actions[](props.length);
        bytes32[] memory data = new bytes32[](props.length);
        uint[]    memory starts = new uint[](props.length);
        uint[]    memory lasts = new uint[](props.length);
        bool[]    memory voted = new bool[](props.length);
        bool[]    memory endedPassed = new bool[](props.length);
        bool[]    memory endedFailed = new bool[](props.length);

        for (uint i = 0; i < props.length; i++) {
            Prop storage prop = props[i];
            actions[i] = prop.action;
            data[i] = prop.data;
            starts[i] = prop.startedAt;
            lasts[i] = prop.lastSigVoteAt;
            voted[i] = prop.voted[msg.sender];
            endedPassed[i] = passed[i];
            endedFailed[i] = failed[i];
        }

        return (actions, data, starts, lasts, voted, endedPassed, endedFailed);
    }

    function vote(uint _propIdx, uint _prefIdx) public {
        bytes20 username = registry.ownerToUsername(msg.sender);
        require( username != 0 );

        Prop storage prop = props[_propIdx];

        require(prop.voted[msg.sender] == false);                               // didn't already vote
        require(                                                                // prop still active
            block.number < prop.startedAt + store.values("PROP_DURATION") ||
            block.number < prop.lastSigVoteAt + store.values("SIG_VOTE_DELAY")
            );

        uint weightedVote = getWeightedVote(username, _propIdx);
        if(weightedVote >= store.values("SIG_VOTE"))
            prop.lastSigVoteAt = block.number;
        prop.results[_prefIdx] += weightedVote;
        prop.voted[msg.sender] = true;
        Voted(username, _propIdx, _prefIdx);
    }
}
