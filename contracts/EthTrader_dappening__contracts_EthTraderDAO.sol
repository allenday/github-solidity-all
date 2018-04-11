pragma solidity ^0.4.17;

import "./EthTraderLib.sol";
import "./Voting.sol";

// is controller of Token, Registry
contract EthTraderDAO is Voting, TokenController {

    bool                        public regEndow = true;
    bytes32[]                   public roots;

    function EthTraderDAO(address _parent, bytes32 _root, address _token, address _registry, address _store) {
        if(_parent == 0){
            roots.push(_root);
            token = IMiniMeToken(_token);
            registry = IRegistry(_registry);
            store = IStore(_store);
        } else {
            EthTraderDAO parentDAO = EthTraderDAO(_parent);
            token = IMiniMeToken(address(parentDAO.token));
            registry = IRegistry(address(parentDAO.registry));
            store = IStore(address(parentDAO.store));
        }
    }

    function enactProp(uint _propIdx) public {
        Prop storage prop = props[_propIdx];

        bool isPassed = resolveProp(_propIdx);
        Resolved(_propIdx, isPassed);
        if(!isPassed)
            return;
        if( prop.action == Actions.UPGRADE ) {
            upgrade(address(EthTraderLib.extract20(prop.data)));
        } else if( prop.action == Actions.ADD_ROOT ) {
            roots.push(prop.data);
        } else if( prop.action ==  Actions.TOGGLE_TRANSFERABLE ) {
            token.enableTransfers(!token.transfersEnabled());
        } else if( prop.action ==  Actions.TOGGLE_REG_ENDOW ) {
            regEndow = !regEndow;
        } else if( prop.action == Actions.SET_VALUE ) {
            var (k, v) = EthTraderLib.split32_20_12(prop.data);
            store.set(k, uint(v));
        } else if( prop.action == Actions.ENDOW ) {
            var (r, a) = EthTraderLib.split32_20_12(prop.data);
            token.generateTokens(address(r), uint(a));
        } else if( prop.action == Actions.DEREG ) {
            var (u,) = EthTraderLib.split32_20_12(prop.data);
            registry.remove(u);
        }
    }

    function upgrade(address _newController) internal {
        registry.changeController(_newController);
        token.changeController(_newController);
        store.changeController(_newController);
    }

    function register(
        bytes20 _username,
        uint96 _endowment,
        uint32 _firstContent,
        bytes32[] _proof,
        uint16 _rootIndex
    ) public {
        require(
            registry.ownerToUsername(msg.sender) == 0 &&
            registry.getOwner(_username) == 0 &&
            validate(_username, _endowment, _firstContent, _proof, _rootIndex)
            );

        registry.add(_username, msg.sender);
        registry.setUserValue(_username, 0, _firstContent);                     // set initial token age to (time since epoch) of users first ethtrader content

        if(regEndow)
            token.generateTokens(msg.sender, _endowment);
    }

    function validate(
        bytes20 _username,
        uint96 _endowment,
        uint32 _firstContent,
        bytes32[] _proof,
        uint16 _rootIndex
    ) public view returns (bool) {
        bytes32 hash = keccak256(msg.sender, _username, _endowment, _firstContent);
        return EthTraderLib.checkProof(_proof, roots[_rootIndex], hash);
    }

    function hash(
        bytes20 _username,
        uint96 _endowment,
        uint32 _firstContent,
        bytes32[] _proof,
        uint16 _rootIndex
    ) public view returns (bytes32 hash) {
        hash = keccak256(msg.sender, _username, _endowment, _firstContent);
    }

    function onTransfer(address _from, address _to, uint _amount) returns(bool) {
        if( _to == 0 || _to == 1 ) return true;                                 // skip if burn or staking transfer
        bytes20 username = registry.ownerToUsername(_from);
        if( username == 0 || _amount == 0 ) return true;                        // skip if not registered

        uint tokenAgeDayCap = store.values("TOKEN_AGE_DAY_CAP");
        bool isSameDay = block.timestamp - registry.getUserValue(username, 1) < 1 days;
        if( isSameDay ) {
            uint dayTotal = registry.getUserValue(username, 2) + _amount;
            if( dayTotal > tokenAgeDayCap ) {
                registry.setUserValue(username, 0, block.timestamp);            // set TOKEN_AGE_START
            }
            registry.setUserValue(username, 2, dayTotal);
        } else {
            if( _amount > tokenAgeDayCap ) {
                registry.setUserValue(username, 0, block.timestamp);            // set TOKEN_AGE_START
            } else {
                registry.setUserValue(username, 1, block.timestamp);            // set DAY_TRANSFERS_START
                registry.setUserValue(username, 2, _amount);                    // set DAY_TOTAL
            }
        }
        return true;
    }

    function getWeightedVote(bytes20 _username, uint _propIdx) public view returns (uint) {
        Prop storage prop = props[_propIdx];
        uint tokenAgeStart = registry.getUserValue(_username, 0);
        uint multiplier = 0;
        if(tokenAgeStart != 0)
            multiplier = (block.timestamp - tokenAgeStart) / 8 weeks;
        if(multiplier > 5) multiplier = 5;
        return multiplier * token.balanceOfAt(msg.sender, prop.startedAt);
    }

}
