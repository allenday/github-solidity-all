/*
    providerRewardLib.sol
    1.0.0
    
    Rajci 'iFA' Andor @ ifa@corion.io / ifa@ethereumlottery.net
    CORION Platform
*/
pragma solidity ^0.4.15;

import "./moduleHandler.sol";
import "./safeMath.sol";
import "./module.sol";
import "./providerDB.sol";

contract providerRewardLib is module, safeMath, providerCommonVars {
    /* Provider database calls */
    // client
    function _getClientSupply(address clientAddress, uint256 schellingRound, uint256 oldAmount) internal returns(uint256 amount) {
        var ( _success, _amount, _valid ) = db.getClientSupply(clientAddress, schellingRound);
        require( _success );
        if ( _valid ) {
            return _amount;
        }
        return oldAmount;
    }
    function _getClientProviderUID(address clientAddress) internal returns(uint256 providerUID) {
        var ( _success, _providerUID ) = db.getClientProviderUID(clientAddress);
        require( _success );
        return _providerUID;
    }
    function _getClientLastPaidRate(address clientAddress) internal returns(uint8 rate) {
        var ( _success, _rate ) = db.getClientLastPaidRate(clientAddress);
        require( _success );
        return _rate;
    }
    function _getSenderStatus(uint256 providerUID) internal returns(senderStatus_e status) {
        var ( _success, _status ) = db.getSenderStatus(msg.sender, providerUID);
        require( _success );
        return _status;
    }
    function _getClientPaidUpTo(address clientAddress) internal returns(uint256 paidUpTo) {
        var ( _success, _paidUpTo ) = db.getClientPaidUpTo(clientAddress);
        require( _success );
        return _paidUpTo;
    }
    function _setClientPaidUpTo(address clientAddress, uint256 paidUpTo) internal {
        var ( _success ) = db.setClientPaidUpTo(clientAddress, paidUpTo);
        require( _success );
    }
    function _setClientLastPaidRate(address clientAddress, uint8 lastPaidRate) internal {
        var ( _success ) = db.setClientLastPaidRate(clientAddress, lastPaidRate);
        require( _success );
    }
    function _setClientSupply(address clientAddress, uint256 roundID, uint256 amount) internal {
        var ( _success ) = db.setClientSupply(clientAddress, roundID, amount);
        require( _success );
    }
    function _setClientSupply(address clientAddress, uint256 amount) internal {
        var ( _success ) = db.setClientSupply(clientAddress, amount);
        require( _success );
    }
    //provider
    function _getProviderOwner(uint256 providerUID) internal returns(address owner) {
        var ( _success, _owner ) = db.getProviderOwner(providerUID);
        require( _success );
        return _owner;
    }
    function _getProviderClosed(uint256 providerUID) internal returns(uint256 closed) {
        var ( _success, _closed ) = db.getProviderClosed(providerUID);
        require( _success );
        return _closed;
    }
    function _getProviderAdmin(uint256 providerUID) internal returns(address admin) {
        var ( _success, _admin ) = db.getProviderAdmin(providerUID);
        require( _success );
        return _admin;
    }
    function _getProviderPriv(uint256 providerUID) internal returns(bool priv) {
        var ( _success, _priv ) = db.getProviderPriv(providerUID);
        require( _success );
        return _priv;
    }
    function _getProviderSupply(uint256 providerUID) internal returns(uint256 supply) {
        var ( _success, _supply ) = db.getProviderSupply(providerUID);
        require( _success );
        return _supply;
    }
    function _getProviderSupply(uint256 providerUID, uint256 schellingRound, uint256 oldAmount) internal returns(uint256 supply) {
        var ( _success, _supply, _valid ) = db.getProviderSupply(providerUID, schellingRound);
        require( _success );
        if ( _valid ) {
            return _supply;
        }
        return oldAmount;
    }
    function _setProviderSupply(uint256 providerUID, uint256 amount) internal {
        var ( _success ) = db.setProviderSupply(providerUID, amount);
        require( _success );
    }
    function _setProviderSupply(uint256 providerUID, uint256 schellingRound, uint256 amount) internal {
        var ( _success ) = db.setProviderSupply(providerUID, schellingRound, amount);
        require( _success );
    }
    function _getProviderIsForRent(uint256 providerUID) internal returns(bool isForRent) {
        var ( _success, _isForRent ) = db.getProviderIsForRent(providerUID);
        require( _success );
        return _isForRent;
    }
    function _getProviderRateHistory(uint256 providerUID, uint256 schellingRound, uint8 oldRate) internal returns(uint8 rate) {
        var ( _success, _rate, _valid ) = db.getProviderRateHistory(providerUID, schellingRound);
        require( _success );
        if ( _valid ) {
            return _rate;
        } else {
            return oldRate;
        }
    }
    //schelling
    function _getCurrentSchellingRound() internal returns(uint256 roundID) {
        var ( _success, _roundID ) = db.getCurrentSchellingRound();
        require( _success );
        return _roundID;
    }
    function _getSchellingRoundDetails(uint256 roundID) internal returns(uint256 reward, uint256 supply) {
        var ( _success, _reward, _supply ) = db.getSchellingRoundDetails(roundID);
        require( _success );
        return ( _reward, _supply );
    }
    function _getSchellingRoundSupply() internal returns(uint256 supply) {
        var ( _success, _reward, _supply ) = db.getSchellingRoundDetails();
        require( _success );
        return _supply;
    }
    function _setSchellingRoundSupply(uint256 amount) internal {
        var ( _success ) = db.setSchellingRoundSupply(amount);
        require( _success );
    }
    /* Structures */
    struct checkReward_s {
        address owner;
        address admin;
        senderStatus_e senderStatus;
        uint256 roundID;
        uint256 roundTo;
        uint256 providerSupply;
        uint256 clientSupply;
        uint256 ownerSupply;
        uint256 schellingReward;
        uint256 schellingSupply;
        uint8   rate;
        bool    priv;
        bool    isForRent;
        uint256 closed;
        uint256 ownerPaidUpTo;
        uint256 clientPaidUpTo;
        bool    getInterest;
        uint256 tmpReward;
        uint256 currentSchellingRound;
        uint256 senderReward;
        uint256 adminReward;
        uint256 ownerReward;
        bool    setOwnerRate;
    }
    /* Variables */
    bytes32 public ownSign = sha3("providerRewardLib");
    uint256 public minFundsForPublic;
    uint256 public minFundsForPrivate;
    uint256 public privateProviderLimit;
    uint8   public publicMinRate;
    uint8   public privateMinRate;
    uint8   public publicMaxRate;
    uint8   public privateMaxRate;
    uint256 public gasProtectMaxRounds;
    uint256 public interestMinFunds;
    uint8   public rentRate;
    address public rewardLibAddress;
    providerDB public db;
    /* Constructor */
    function providerRewardLib(address moduleHandlerAddr) module(moduleHandlerAddr) {}
    /* Externals */
    function getReward(address beneficiary, uint256 providerUID, uint256 roundLimit) external {
        /*
            Polling the share from the token emission token emission for clients and for providers.

            It is optionaly possible to give an address of a beneficiary for whom we can transfer the accumulated amount. In case we don’t enter any address then the amount will be transfered to the caller’s address.
            As the interest should be checked at each schelling round in order to get the share from that so to avoid the overflow of the gas the number of the check rounds should be limited.
            It is possible to enter optionaly the number of the check rounds.  If it is 0 then it is automatic.
            
            @beneficiary        Address of the beneficiary
            @limit              Quota of the check rounds.
            @providerUID        Unique ID of the provider
            @reward             Accumulated amount from the previous rounds.
        */
        var _roundLimit = roundLimit;
        var _beneficiary = beneficiary;
        if ( _roundLimit == 0 ) { _roundLimit = gasProtectMaxRounds; }
        if ( _beneficiary == 0x00 ) { _beneficiary = msg.sender; }
        var (_data, _round) = checkReward(msg.sender, providerUID, _roundLimit);
        require( _round > 0 );
        if ( msg.sender == _data.admin && _data.adminReward > 0) {
            require( moduleHandler(moduleHandlerAddress).transfer(address(this), _beneficiary, safeAdd(_data.senderReward, _data.adminReward), false ) );
        } else {
            if ( _data.senderReward > 0 )  {
                require( moduleHandler(moduleHandlerAddress).transfer(address(this), _beneficiary, _data.senderReward, false ) );
            }
            if ( _data.adminReward > 0 )  {
                require( moduleHandler(moduleHandlerAddress).transfer(address(this), _data.admin, _data.adminReward, false ) );
            }
        }
        if ( _data.ownerReward > 0 ) {
            require( moduleHandler(moduleHandlerAddress).transfer(address(this), _data.owner, _data.ownerReward, false ) );
        }
    }
    function appendSupplyChanges(address client, bool add, uint256 amount) external {
        uint256 _clientSupply;
        var providerUID = _getClientProviderUID(client);
        if ( providerUID == 0 || _getProviderClosed(providerUID) > 0) { return; }
        var _priv = _getProviderPriv(providerUID);
        var _owner = _getProviderOwner(providerUID);
        if ( _owner != client || ( _owner == client && _priv )) {
            var _providerSupply = _getProviderSupply(providerUID);
            uint256 _newProviderSupply;
            if ( add ) {
                _newProviderSupply = safeAdd(_providerSupply, amount);
            } else {
                _newProviderSupply = safeSub(_providerSupply, amount);
            }
            _setProviderSupply(providerUID, _newProviderSupply);
            
            _appendSchellingSupplyChanges(_providerSupply, _newProviderSupply, _priv);
        }
        // Client supply changes
        _clientSupply = getTokenBalance(client);
        if ( client != _owner || ( client == _owner && _priv ) )  {
            _setClientSupply(client, _clientSupply);
        }
        // check owner balance for the provider limits
        if ( !add && client == _owner ) {
            checkProviderOwnerSupply(_clientSupply, _priv);
        }
        EProviderNewDetails(providerUID);
    }
    function appendSchellingSupplyChanges(uint256 providerSupply, uint256 newProviderSupply, bool priv) external {
        _appendSchellingSupplyChanges(providerSupply, newProviderSupply, priv);
    }
    /* Internals */
    function _appendSchellingSupplyChanges(uint256 providerSupply, uint256 newProviderSupply, bool priv) internal {
        var _schellingSupply = _getSchellingRoundSupply();
        // check if the provider used to get interest - if so, remove it from the schelling supply
        if (checkForInterest(providerSupply, priv)) {
            _schellingSupply = safeSub(_schellingSupply, providerSupply);
        }
        // check if the provider should get interest now
        if (checkForInterest(newProviderSupply, priv)) {
            _schellingSupply = safeAdd(_schellingSupply, newProviderSupply);
        }
        _setSchellingRoundSupply(_schellingSupply);
    }
    function checkReward(address client, uint256 providerUID, uint256 roundLimit) internal returns(checkReward_s data, uint256 round) {
        if ( providerUID == 0) {
            return;
        }
        var senderStatus = _getSenderStatus(providerUID);
        if ( senderStatus == senderStatus_e.none ) {
            return;
        }
        data.owner = _getProviderOwner(providerUID);
        data.admin = _getProviderAdmin(providerUID);
        data.priv = _getProviderPriv(providerUID);
        data.isForRent = _getProviderIsForRent(providerUID);

        // Get paidUps and set the first schelling round ID
        data.clientPaidUpTo = _getClientPaidUpTo(client);
        data.roundID = data.clientPaidUpTo;
        if ( senderStatus != senderStatus_e.client) {
            data.ownerPaidUpTo = _getClientPaidUpTo(data.owner);
            if ( senderStatus == senderStatus_e.adminAndClient && data.clientPaidUpTo < data.ownerPaidUpTo ) {
                data.roundID = data.clientPaidUpTo;
            } else {
                data.roundID = data.ownerPaidUpTo;
            }
        }
        data.currentSchellingRound = _getCurrentSchellingRound();
        data.roundTo = data.currentSchellingRound;
        data.closed = _getProviderClosed(providerUID);
        if ( data.closed > 0 ) {
            data.roundTo = data.closed;
        }
        
        // load last rate
        if ( senderStatus == senderStatus_e.admin ) {
            data.rate = _getClientLastPaidRate(data.owner);
        } else {
            data.rate = _getClientLastPaidRate(client);
        }
        
        // For loop START
        for ( data.roundID ; data.roundID<data.roundTo ; data.roundID++ ) {
            if ( roundLimit > 0 && round == roundLimit ) { break; }
            round = safeAdd(round, 1);
            // Get provider Rate
            data.rate = _getProviderRateHistory(providerUID, data.roundID, data.rate);
            // Get schelling reward and supply for the current checking round
            (data.schellingReward, data.schellingSupply) = _getSchellingRoundDetails(data.roundID);
            // Get provider supply for the current checking round
            data.providerSupply = _getProviderSupply(providerUID, data.roundID, data.providerSupply);
            // Get client/owner supply for this checking round
            if ( data.clientPaidUpTo > 0 ) {
                data.clientSupply = _getClientSupply(client, data.roundID, data.clientSupply);
            }
            if ( data.ownerPaidUpTo > 0 ) {
                data.ownerSupply = _getClientSupply(data.owner, data.roundID, data.ownerSupply);
            }
            // Check, that the Provider has right for getting interest for the current checking round
            data.getInterest = ((( ! data.priv ) || ( data.priv && interestMinFunds <= data.providerSupply ) ) && data.providerSupply > 0 && data.schellingReward > 0 && data.schellingSupply > 0);
            // Checking client reward if he is the sender
            if ( ( senderStatus == senderStatus_e.client || senderStatus == senderStatus_e.adminAndClient ) && data.clientPaidUpTo <= data.roundID ) {
                // Check for schelling reward, rate (we can not mul with zero) and if the provider get interest or not
                if ( data.rate > 0 && data.getInterest ) {
                    data.senderReward = safeAdd(data.senderReward, safeMul(safeMul(data.schellingReward, data.clientSupply) / data.schellingSupply, data.rate) / 100);
                }
                if ( data.clientPaidUpTo <= data.roundID ) {
                    data.clientPaidUpTo = safeAdd(data.roundID, 1);
                }
            }
            // After closing an provider muss be checked all round. If then is closed we should not check again.
            if ( data.closed == 0 && senderStatus != senderStatus_e.client ) {
                if ( data.ownerPaidUpTo <= data.roundID && data.getInterest ) {
                    // Checking owners reward if he is the sender or was the admin on isForRent
                    if ( data.priv ) {
                        // PaidUpTo check, need be priv and the caller is not client
                        // If the provider isForRent, then the admin can calculate owner's reward, but we send that for the owner
                        // If the provider is not for rent, then the admin can receive owners reward
                        data.tmpReward = safeMul(data.schellingReward, data.ownerSupply) / data.schellingSupply;
                        if ( data.isForRent && senderStatus != senderStatus_e.owner) {
                            data.ownerReward = safeAdd(data.ownerReward, data.tmpReward);
                        } else {
                            data.senderReward = safeAdd(data.senderReward, data.tmpReward);
                        }
                    }
                    // Checking revenue from the clients if the caller was the owner or admin
                    // Check for schelling reward, rate (we can not mul with zero)
                    if ( data.rate < 100 ) {
                        // calculating into temp variable
                        if ( data.priv ) {
                            data.tmpReward = safeSub(data.providerSupply, data.ownerSupply);
                        } else {
                            data.tmpReward = data.providerSupply;
                        }
                        if ( data.tmpReward > 0 ) {
                            data.tmpReward = safeMul(safeMul(data.schellingReward, data.tmpReward) / data.schellingSupply, safeSub(100, data.rate)) / 100;
                            // if the provider isForRent, then the reward will be disturbed
                            if ( data.isForRent ) {
                                if ( senderStatus == senderStatus_e.owner ) {
                                    data.senderReward = safeAdd(data.senderReward, safeMul(data.tmpReward, rentRate) / 100);
                                } else {
                                    data.ownerReward = safeAdd(data.ownerReward, safeMul(data.tmpReward, rentRate) / 100);
                                }
                                data.adminReward = safeAdd(data.adminReward, safeSub(data.tmpReward, safeMul(data.tmpReward, rentRate) / 100));
                            } else {
                                // if not and the calles is the owner he got everything.
                                if ( senderStatus == senderStatus_e.owner ) {
                                    data.senderReward = safeAdd(data.senderReward, data.tmpReward);
                                } else {
                                    data.adminReward = safeAdd(data.adminReward, data.tmpReward);
                                }
                            }
                        }
                    }
                }
                if ( data.ownerPaidUpTo <= data.roundID ) {
                    data.ownerPaidUpTo = safeAdd(data.roundID, 1);
                }
                // If the owner call
                if ( data.clientPaidUpTo <= data.roundID ) {
                    data.clientPaidUpTo = safeAdd(data.roundID, 1);
                }
            }
        }
        // For loop END
        
        // Set last paidUpTo, rate and supply
        if ( senderStatus != senderStatus_e.admin ) {
            if ( client != data.owner || ( client == data.owner && data.priv ) ) {
                _setClientSupply(client, data.clientPaidUpTo, data.clientSupply);
            }
            _setClientPaidUpTo(client, data.clientPaidUpTo);
            _setClientLastPaidRate(client, data.rate);
        }
        if ( senderStatus != senderStatus_e.client ) {
            if ( data.priv ) {
                _setClientSupply(data.owner, data.ownerPaidUpTo, data.ownerSupply);
            }
            _setClientPaidUpTo(data.owner, data.ownerPaidUpTo);
            _setClientLastPaidRate(data.owner, data.rate);
        }
        //save last provider supply
        _setProviderSupply(providerUID, data.roundID, data.providerSupply);
    }
    function checkProviderOwnerSupply(uint256 balance, bool priv) internal {
        require( ( priv && ( balance >= minFundsForPrivate )) || ( ! priv && ( balance >= minFundsForPublic )) );
    }
    function checkForInterest(uint256 supply, bool priv) internal returns (bool) {
        return ( ! priv && supply > 0) || ( priv && interestMinFunds <= supply );
    }
    function getTokenBalance(address addr) internal returns (uint256 balance) {
        /*
            Inner function in order to poll the token balance of the address.
            
            @addr       Address
            
            @balance    Balance of the address.
        */
        var (_success, _balance) = moduleHandler(moduleHandlerAddress).balanceOf(addr);
        require( _success );
        return _balance;
    }
    /* Constants */
    function checkReward(uint256 providerUID, uint256 roundLimit) public constant returns (uint256 senderReward, uint256 adminReward, uint256 ownerReward, uint256 round) {
        var _roundLimit = roundLimit;
        if ( _roundLimit == 0 ) { _roundLimit = _roundLimit-1; } // willfully
        var (_data, _round) = checkReward(msg.sender, providerUID, _roundLimit);
        return (_data.senderReward, _data.adminReward, _data.ownerReward, _round);
    }
    /* Events */
    event EProviderOpen(uint256 UID);
    event EProviderClose(uint256 UID);
    event EProviderNewDetails(uint256 UID);
    event EJoinProvider(uint256 UID, address clientAddress);
    event EPartProvider(uint256 UID, address clientAddress);
    event EInviteStatus(uint256 UID, address clientAddress, bool status);
}
