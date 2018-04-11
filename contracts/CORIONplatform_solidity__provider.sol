/*
    provider.sol
    1.1.0
    
    Rajci 'iFA' Andor @ ifa@corion.io / ifa@ethereumlottery.net
    CORION Platform
*/
pragma solidity ^0.4.16;

import "./module.sol";
import "./moduleHandler.sol";
import "./safeMath.sol";
import "./announcementTypes.sol";
import "./providerDB.sol";
import "./providerRewardLib.sol";

contract provider is module, safeMath, providerCommonVars {
    /* Module functions */
    function replaceModule(address addr) onlyForModuleHandler external returns (bool success) {
        require( db.replaceOwner(addr) );
        super._replaceModule(addr);
        return true;
    }
    function transferEvent(address from, address to, uint256 value) onlyForModuleHandler external returns (bool success) {
        /*
            Transaction completed. This function is ony available for the modulehandler.
            It should be checked if the sender or the acceptor does not connect to the provider or it is not a provider itself if so than the change should be recorded.
            
            @from       From whom?
            @to         For who?
            @value      amount
            @bool       Was the function successful?
        */
        appendSupplyChanges(from, false, value);
        appendSupplyChanges(to, true, value);
        return true;
    }
    function newSchellingRoundEvent(uint256 roundID, uint256 reward) onlyForModuleHandler external returns (bool success) {
        /*
            New schelling round. This function is only available for the moduleHandler.
            We are recording the new schelling round and we are storing the whole current quantity of the tokens.
            We generate a reward quantity of tokens directed to the providers address. The collected interest will be tranfered from this contract.
            
            @roundID        Number of the schelling round.
            @reward         token emission 
            @bool           Was the function successful?
        */
        //get current schelling round supply
        var ( _success, _mint ) = db.newSchellingRound(roundID, reward);
        require( _success );
        if ( _mint ) {
            require( moduleHandler(moduleHandlerAddress).mint(address(this), reward) );
        }
        return true;
    }
    function configureModule(announcementType aType, uint256 value, address addr) onlyForModuleHandler external returns(bool success) {
        if      ( aType == announcementType.providerPublicFunds )          { minFundsForPublic = value; }
        else if ( aType == announcementType.providerPrivateFunds )         { minFundsForPrivate = value; }
        else if ( aType == announcementType.providerPrivateClientLimit )   { privateProviderLimit = value; }
        else if ( aType == announcementType.providerPublicMinRate )        { publicMinRate = uint8(value); }
        else if ( aType == announcementType.providerPublicMaxRate )        { publicMaxRate = uint8(value); }
        else if ( aType == announcementType.providerPrivateMinRate )       { privateMinRate = uint8(value); }
        else if ( aType == announcementType.providerPrivateMaxRate )       { privateMaxRate = uint8(value); }
        else if ( aType == announcementType.providerGasProtect )           { gasProtectMaxRounds = value; }
        else if ( aType == announcementType.providerInterestMinFunds )     { interestMinFunds = value; }
        else if ( aType == announcementType.providerRentRate )             { rentRate = uint8(value); }
        else { return false; }
        super._configureModule(aType, value, addr);
        return true;
    }
    /* Provider database calls */
    // client
    function _isClientPaidUp(address clientAddress) constant returns(bool paid) {
        var (_success, _paid) = db.isClientPaidUp(clientAddress);
        require( _success );
        return _paid;
    }
    function _getClientProviderUID(address clientAddress) internal returns(uint256 providerUID) {
        var ( _success, _providerUID ) = db.getClientProviderUID(clientAddress);
        require( _success );
        return _providerUID;
    }
    function _joinToProvider(uint256 providerUID, address clientAddress) internal {
        var _success = db.joinToProvider(providerUID, clientAddress);
        require( _success );
    }
    function _partFromProvider(uint256 providerUID, address clientAddress) internal {
        var _success = db.partFromProvider(providerUID, clientAddress);
        require( _success );
    }
    function _checkForJoin(uint256 providerUID, address clientAddress, uint256 countLimitforPrivate) internal returns(bool allowed) {
        var ( _success, _allowed ) = db.checkForJoin(providerUID, clientAddress, countLimitforPrivate);
        require( _success );
        return _allowed;
    }
    function _getSenderStatus(uint256 providerUID) internal returns(senderStatus_e status) {
        var ( _success, _status ) = db.getSenderStatus(msg.sender, providerUID);
        require( _success );
        return _status;
    }
    //provider
    function _openProvider(bool priv, string name, string website, uint256 country, string info, uint8 rate, bool isForRent, address admin) internal returns(uint256 newUID) {
        var (_success, _newUID) = db.openProvider(msg.sender, priv, name, website, country, info, rate, isForRent, admin);
        require( _success );
        return _newUID;
    }
    function _closeProvider(address owner) internal {
        var _success = db.closeProvider(owner);
        require( _success );
    }
    function _setProviderInfoFields(uint256 providerUID, string name, string website, 
        uint256 country, string info, address admin, uint8 rate) internal {
        var _success = db.setProviderInfoFields(providerUID, name, website, country, info, admin, rate);
        require( _success );
    }
    function _isProviderValid(uint256 providerUID) internal returns(bool valid) {
        var ( _success, _valid ) = db.isProviderValid(providerUID);
        require( _success );
        return _valid;
    }
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
    function _setProviderInvitedUser(uint256 providerUID, address clientAddress, bool status) internal {
        var _success = db.setProviderInvitedUser(providerUID, clientAddress, status);
        require( _success );
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
    /* Structures */
    struct newProvider_s {
        uint256 balance;
        uint256 newUID;
    }
    /* Variables */
    bytes32 public ownSign = sha3("provider");
    uint256 public minFundsForPublic    = 3e9;
    uint256 public minFundsForPrivate   = 8e9;
    uint256 public privateProviderLimit = 250;
    uint8   public publicMinRate        = 30;
    uint8   public privateMinRate       = 0;
    uint8   public publicMaxRate        = 70;
    uint8   public privateMaxRate       = 100;
    uint256 public gasProtectMaxRounds  = 200;
    uint256 public interestMinFunds     = 25e9;
    uint8   public rentRate             = 20;
    address public rewardLibAddress;
    providerDB public db;
    /* Constructor */
    function provider(bool forReplace, address moduleHandlerAddr, address dbAddr, address rewardLibAddr) module(moduleHandlerAddr) {
        /*
            Install function.
            
            @forReplace                 This address will be replaced with the old one or not.
            @moduleHandlerAddr          Modulhandler's address
            @dbAddr                     Address of database           
        */
        require( dbAddr != 0x00 );
        require( rewardLibAddr != 0x00 );
        db = providerDB(dbAddr);
        rewardLibAddress = rewardLibAddr;
        require( providerRewardLib(rewardLibAddress).ownSign() == sha3("providerRewardLib") );
        if ( ! forReplace ) {
            require( db.replaceOwner(this) );
        }
    }
    /* Externals */
    function openProvider(bool priv, string name, string website, uint256 country, string info, uint8 rate, bool isForRent, address admin) readyModule external {
        /*
            Creating a provider.
            During the ICO its not allowed to create provider.
            To one address only one provider can belong to.
            Address, how is connected to the provider can not create a provider.
            For opening, has to have enough capital.
            All the functions of the provider except of the closing are going to be handled by the admin.
            The provider can be start as a rent as well, in this case the isForRent has to be true/correct.
            In case it runs as a rent the 20% of the profit will belong to the leser and the rest goes to the admin.
            
            @priv           Is private provider?
            @name           Provider’s name.
            @website        Provider’s website.
            @country        Provider’s country.
            @info           Provider’s short introduction.
            @rate           Rate of the emission what is going to be transfered to the client by the provider.
            @isForRent      Is for Rent or not?
            @admin          The admin's address.
        */
        newProvider_s memory _newProvider;
        _newProvider.balance = getTokenBalance(msg.sender);
        checkCorrectRate(priv, rate);
        require( admin != msg.sender );
        require( ( ! isForRent ) || ( isForRent && admin != 0x00) );
        require( _getClientProviderUID(msg.sender) == 0x00 );
        checkProviderOwnerSupply(_newProvider.balance, priv);
        _newProvider.newUID = _openProvider(priv, name, website, country, info, rate, isForRent, admin);
        _joinToProvider(_newProvider.newUID, msg.sender);
        if ( priv ) {
            appendSupplyChanges(msg.sender, true, _newProvider.balance);
        }
        EProviderOpen(_newProvider.newUID);
    }
    function closeProvider() readyModule external {
        /*
            Closing and inactivate the provider.
            It is only possible to close that active provider which is owned by the sender itself after calling the whole share of the emission.
            Who were connected to the provider those clients will have to disconnect after they’ve called their share of emission which was not called before.
        */
        var providerUID = _getClientProviderUID(msg.sender);
        require( providerUID > 0 );
        require( _getProviderOwner(providerUID) == msg.sender );
        require( _isClientPaidUp(msg.sender) );
        var _providerSupply = _getProviderSupply(providerUID);
        var _priv = _getProviderPriv(providerUID);
        appendSchellingSupplyChanges(_providerSupply, 0, _priv);
        _closeProvider(msg.sender);
        EProviderClose(providerUID);
    }
    function setProviderDetails(uint256 providerUID, string name, string website, uint256 country, string info, uint8 rate, address admin) readyModule external {
        /*
            Modifying the datas of the provider.
            This can only be invited by the provider’s admin.
            The emission rate is only valid for the next schelling round for this one it is not.
            The admin can only be changed by the address of the provider.
            
            @providerUID        Address of the provider.
            @name               Provider's name.
            @website            Website.
            @country            Country.
            @info               Short intro.
            @rate               Rate of the emission what will be given to the client.
            @admin              The new address of the admin. If we do not want to set it then we should enter 0x00. 
        */
        require( _isProviderValid(providerUID) );
        checkCorrectRate( _getProviderPriv(providerUID), rate);
        var _admin = _getProviderAdmin(providerUID);
        var _status = _getSenderStatus(providerUID);
        require( ( _status == senderStatus_e.owner && msg.sender != admin ) ||
            ( ( _status == senderStatus_e.admin || _status == senderStatus_e.adminAndClient ) && admin == _admin ) );
        _setProviderInfoFields(providerUID, name, website, country, info, admin, rate);
        EProviderNewDetails(providerUID);
    }
    function joinProvider(uint256 providerUID) readyModule external {
        /*
            Connection to the provider.
            Providers can not connect to other providers.
            If is a client at any provider, then it is not possible to connect to other provider one.
            It is only possible to connect to valid and active providers.
            If is an active provider then the client can only connect, if address is permited at the provider (Whitelist).
            At private providers, the number of the client is restricted. If it reaches the limit no further clients are allowed to connect.
            This process has a transaction fee based on the senders whole token quantity.
            
            @providerUID        Provider Unique ID
        */
        require( _checkForJoin(providerUID, msg.sender, privateProviderLimit) );
        var _supply = getTokenBalance(msg.sender);
        // We charge fee
        require( moduleHandler(moduleHandlerAddress).processTransactionFee(msg.sender, _supply) );
        _supply = getTokenBalance(msg.sender);
        _joinToProvider(providerUID, msg.sender);
        appendSupplyChanges(msg.sender, true, _supply);
        EJoinProvider(providerUID, msg.sender);
    }
    function partProvider() readyModule external {
        /*
            Disconnecting from the provider.
            Before disconnecting we should poll our share from the token emission even if there was nothing factually.
            It is only possible to disconnect those providers who were connected by us before.
        */
        var providerUID = _getClientProviderUID(msg.sender);
        require( providerUID > 0 );
        require( _getProviderOwner(providerUID) != msg.sender );
        // Is paid up?
        require( _isClientPaidUp(msg.sender) );
        var _supply = getTokenBalance(msg.sender);
        // ONLY IF THE PROVIDER ARE OPEN
        if ( _getProviderClosed(providerUID) == 0 ) {
            appendSupplyChanges(msg.sender, false, _supply);
        }
        _partFromProvider(providerUID, msg.sender);
        EPartProvider(providerUID, msg.sender);
    }
    function getReward(address beneficiary, uint256 providerUID, uint256 roundLimit) readyModule external {
        require( rewardLibAddress.delegatecall(bytes4(sha3("getReward(address,uint256,uint256)")), beneficiary, providerUID, roundLimit) );
    }
    function manageInvitations(uint256 providerUID, address[] invite, address[] revokeInvite) readyModule external {
        /*
            Permition of the user to be able to connect to the provider.
            This can only be invited by the provider's owner or admin.
            With this kind of call only 100 address can be permited. 
            
            @providerUID            Provider Unique ID
            @invite                 Array of the addresses for whom the connection is allowed.
            @revokeInvite           Array of the addresses for whom the connection is disallowed.
        */
        uint256 a;
        require( invite.length <= 100 && revokeInvite.length <= 100 );
        require( _isProviderValid(providerUID) );
        var _status = _getSenderStatus(providerUID);
        require( _status == senderStatus_e.owner || 
            _status == senderStatus_e.admin || 
            _status == senderStatus_e.adminAndClient );
        for ( a=0 ; a<invite.length ; a++ ) {
            _setProviderInvitedUser(providerUID, invite[a], true);
            EInviteStatus(providerUID, invite[a], true);
        }
        for ( a=0 ; a<revokeInvite.length ; a++ ) {
            _setProviderInvitedUser(providerUID, revokeInvite[a], false);
            EInviteStatus(providerUID, revokeInvite[a], true);
        }
    }
    /* Internals */
    function appendSupplyChanges(address client, bool _add, uint256 amount) internal {
        require( rewardLibAddress.delegatecall(bytes4(sha3("appendSupplyChanges(address,bool,uint256)")), client, _add, amount) );
    }
    function checkProviderOwnerSupply(uint256 balance, bool priv) internal {
        require( ( priv && ( balance >= minFundsForPrivate )) || ( ! priv && ( balance >= minFundsForPublic )) );
    }
    function appendSchellingSupplyChanges(uint256 providerSupply, uint256 newProviderSupply, bool priv) internal {
        require( rewardLibAddress.delegatecall(bytes4(sha3("appendSchellingSupplyChanges(uint256,uint256,bool)")), providerSupply, newProviderSupply, priv) );
    }
    function checkCorrectRate(bool priv, uint8 rate) internal {
        /*
            Inner function which checks if the amount of interest what is given by the provider is fits to the criteria.
            
            @priv       Is the provider private or not?
            @rate       Percentage/rate of the interest
        */
        require(( ! priv && ( rate >= publicMinRate && rate <= publicMaxRate ) ) || 
                ( priv && ( rate >= privateMinRate && rate <= privateMaxRate ) ) );
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
        address _trg = rewardLibAddress;
        assembly {
            let m := mload(0x80)
            mstore(m, 0xbfd8222a00000000000000000000000000000000000000000000000000000000)
            mstore(add(m, 0x04), providerUID)
            mstore(add(m, 0x24), roundLimit)
            let success := delegatecall(gas, _trg, m, 0x44, m, 0x80)
            switch success case 0 {
                return(0,0)
            } default {
                return(m, 0x80)
            }
        }
    }
    /* Events */
    event EProviderOpen(uint256 UID);
    event EProviderClose(uint256 UID);
    event EProviderNewDetails(uint256 UID);
    event EJoinProvider(uint256 UID, address clientAddress);
    event EPartProvider(uint256 UID, address clientAddress);
    event EInviteStatus(uint256 UID, address clientAddress, bool status);
}
