/*
    providerDB.sol
    1.0.0
    
    Rajci 'iFA' Andor @ ifa@corion.io / ifa@ethereumlottery.net
    CORION Platform
*/
pragma solidity ^0.4.15;

import "./provider.sol";
import "./safeMath.sol";
import "./owned.sol";

contract providerCommonVars {
    enum senderStatus_e {
        none,
        client,
        adminAndClient,
        admin,
        owner
    }
}

contract providerDB is providerCommonVars, owned, safeMath {
    /* Structures */
    struct supply_s {
        uint256 amount;
        bool valid;
    }
    struct rate_s {
        uint8 value;
        bool valid;
    }
    struct provider_s {
        mapping(uint256 => rate_s) rateHistory;
        mapping(address => bool) invitations;
        mapping(uint256 => supply_s) supply;
        address owner;
        address admin;
        string name;
        string website;
        uint256 country;
        string info;
        bool isForRent;
        uint8 currentRate;
        bool priv;
        uint256 clientsCount;
        uint256 lastSupplyID;
        uint256 closed; // schelling round
    }
    struct schellingRoundDetails_s {
        uint256 reward;
        uint256 supply;
    }
    struct client_s {
        mapping(uint256 => supply_s) supply;
        uint256 providerUID;
        uint256 lastSupplyID;
        uint8 lastPaidRate;
        uint256 paidUpTo;
    }
    /* Variables */
    mapping(uint256 => provider_s) providers;
    mapping(uint256 => schellingRoundDetails_s) public schellingRoundDetails;
    mapping(address => client_s) public clients;
    address public debug_owner = msg.sender;
    uint256 public providerCounter;
    uint256 public currentSchellingRound = 1;
    function debug_changeOwner(address newOwner) {
        require( msg.sender == debug_owner );
        owner = newOwner;
    }
    //base providerCounter functions
    function getProviderCounter() constant returns(bool success, uint256 value) {
        return (
            true,
            providerCounter
        );
    }
    //combined client functions
    function isClientPaidUp(address clientAddress) constant returns(bool success, bool paid) {
        var providerUID = clients[clientAddress].providerUID;
        return (
            true,
            ( ( providers[providerUID].closed > 0 && clients[clientAddress].paidUpTo == safeSub(providers[providerUID].closed, 1) ) ||
            clients[clientAddress].paidUpTo == currentSchellingRound )
        );
    }
    function joinToProvider(uint256 providerUID, address clientAddress) external returns(bool success) {
        require( isOwner() );
        if ( providers[providerUID].owner != clientAddress ) {
            providers[providerUID].clientsCount = safeAdd(providers[providerUID].clientsCount, 1);
        }
        clients[clientAddress].providerUID = providerUID;
        clients[clientAddress].lastSupplyID = currentSchellingRound;
        clients[clientAddress].paidUpTo = currentSchellingRound;
        clients[clientAddress].lastPaidRate = providers[providerUID].currentRate;
        return true;
    }
    function partFromProvider(uint256 providerUID, address clientAddress) external returns(bool success) {
        require( isOwner() );
        if ( providers[providerUID].owner != clientAddress ) {
            providers[providerUID].clientsCount = safeSub(providers[providerUID].clientsCount, 1);
        }
        delete clients[clientAddress].providerUID;
        delete clients[clientAddress].supply[clients[clientAddress].lastSupplyID];
        delete clients[clientAddress].lastSupplyID;
        delete clients[clientAddress].lastPaidRate;
        return true;
    }
    function getSenderStatus(address sender, uint256 providerUID) constant returns(bool success, senderStatus_e status) {
        if ( providers[providerUID].owner == sender ) {
            return (true, senderStatus_e.owner);
        } else if ( providers[providerUID].admin == sender ) {
            if ( clients[sender].providerUID == providerUID ) {
                return (true, senderStatus_e.adminAndClient);
            } else {
                return (true, senderStatus_e.admin);
            }
        } else if ( clients[sender].providerUID == providerUID ) {
            return (true, senderStatus_e.client);
        }
        return (true, senderStatus_e.none);
    }
    function getClientSupply(address clientAddress, uint256 schellingRound, uint256 previousSupply) constant returns(bool success, uint256 amount) {
        if ( clients[clientAddress].supply[schellingRound].valid ) {
            return ( true, clients[clientAddress].supply[schellingRound].amount );
        } else {
            if ( clients[clientAddress].lastSupplyID < schellingRound ) {
                return ( true, clients[clientAddress].supply[clients[clientAddress].lastSupplyID].amount );
            } else {
                return ( true, previousSupply );
            }
        }
    }
    function setClientSupply(address clientAddress, uint256 schellingRound, uint256 amount) external returns(bool success) {
        require( isOwner() );
        if ( ( schellingRound == currentSchellingRound && ( ! clients[clientAddress].supply[schellingRound].valid )  ) ||
            schellingRound != currentSchellingRound ) {
            clients[clientAddress].supply[schellingRound].amount = amount;
            clients[clientAddress].supply[schellingRound].valid = true;
        }
        if ( clients[clientAddress].lastSupplyID < schellingRound ) {
            clients[clientAddress].lastSupplyID = schellingRound;
        }
        return true;
    }
    //base client functions
    function getClientSupply(address clientAddress) constant returns(bool success, uint256 amount) {
        return (
            true,
            clients[clientAddress].supply[clients[clientAddress].lastSupplyID].amount
        );
    }
    function getClientSupply(address clientAddress, uint256 schellingRound) constant returns(bool success, uint256 amount, bool valid) {
        return (
            true,
            clients[clientAddress].supply[schellingRound].amount,
            clients[clientAddress].supply[schellingRound].valid
        );
    }
    function setClientSupply(address clientAddress, uint256 amount) external returns(bool success) {
        require( isOwner() );
        clients[clientAddress].supply[currentSchellingRound].amount = amount;
        clients[clientAddress].supply[currentSchellingRound].valid = true;
        clients[clientAddress].lastSupplyID = currentSchellingRound;
        return true;
    }
    function getClientPaidUpTo(address clientAddress) constant returns(bool success, uint256 paidUpTo) {
        return (
            true,
            clients[clientAddress].paidUpTo
        );
    }
    function setClientPaidUpTo(address clientAddress, uint256 paidUpTo) external returns(bool success) {
        require( isOwner() );
        clients[clientAddress].paidUpTo = paidUpTo;
        return true;
    }
    function getClientLastPaidRate(address clientAddress) constant returns(bool success, uint8 lastPaidRate) {
        return (
            true,
            clients[clientAddress].lastPaidRate
        );
    }
    function setClientLastPaidRate(address clientAddress, uint8 lastPaidRate) external returns(bool success) {
        require( isOwner() );
        clients[clientAddress].lastPaidRate = lastPaidRate;
        return true;
    }
    function getClientLastSupplyID(address clientAddress) constant returns(bool success, uint256 lastSupplyID) {
        return (
            true,
            clients[clientAddress].lastSupplyID
        );
    }
    function setClientLastSupplyID(address clientAddress, uint256 lastSupplyID) external returns(bool success) {
        require( isOwner() );
        clients[clientAddress].lastSupplyID = lastSupplyID;
        return true;
    }
    function getClientProviderUID(address clientAddress) constant returns(bool success, uint256 providerUID) {
        return (
            true,
            clients[clientAddress].providerUID
        );
    }
    function setClientProviderUID(address clientAddress, uint256 providerUID) external returns(bool success) {
        require( isOwner() );
        clients[clientAddress].providerUID = providerUID;
        return true;
    }
    //combined schelling functions
    function newSchellingRound(uint256 roundID, uint256 reward) external returns(bool success, bool mint) {
        require( isOwner() );
        mint = schellingRoundDetails[currentSchellingRound].supply > 0;
        if ( mint ) {
            // we set reward only if the previous round has any supply
            schellingRoundDetails[currentSchellingRound].reward = reward;
        }
        schellingRoundDetails[roundID].supply = schellingRoundDetails[currentSchellingRound].supply;
        currentSchellingRound = roundID;
        // if the current supply ID was zero, we send back DONT mint tokens
        return (true, mint);
    }
    //base schelling functions
    function getCurrentSchellingRound() constant returns(bool success, uint256 roundID) {
        return (
            true,
            currentSchellingRound
        );
    }
    function setCurrentSchellingRound(uint256 roundID) external returns(bool success) {
        require( isOwner() );
        currentSchellingRound = roundID;
        return true;
    }
    function getSchellingRoundDetails() constant returns(bool success, uint256 reward, uint256 supply) {
        return (
            true,
            schellingRoundDetails[currentSchellingRound].reward,
            schellingRoundDetails[currentSchellingRound].supply
        );
    }
    function getSchellingRoundDetails(uint256 roundID) constant returns(bool success, uint256 reward, uint256 supply) {
        return (
            true,
            schellingRoundDetails[roundID].reward,
            schellingRoundDetails[roundID].supply
        );
    }
    function setSchellingRoundDetails(uint256 roundID, uint256 reward, uint256 supply) external returns(bool success) {
        require( isOwner() );
        schellingRoundDetails[roundID].reward = reward;
        schellingRoundDetails[roundID].supply = supply;
        return true;
    }
    function setSchellingRoundSupply(uint256 supply) external returns(bool success) {
        require( isOwner() );
        schellingRoundDetails[currentSchellingRound].supply = supply;
        return true;
    }
    function setSchellingRoundReward(uint256 reward) external returns(bool success) {
        require( isOwner() );
        schellingRoundDetails[currentSchellingRound].reward = reward;
        return true;
    }
    //combined provider functions
    function openProvider(address owner, bool priv, string name, string website, uint256 country, string info,
        uint8 rate, bool isForRent, address admin) external returns(bool success, uint256 providerUID) {
        require( isOwner() );
        providerCounter = safeAdd(providerCounter, 1);
        providers[providerCounter].owner = owner;
        providers[providerCounter].admin = admin;
        providers[providerCounter].priv = priv;
        providers[providerCounter].name = name;
        providers[providerCounter].website = website;
        providers[providerCounter].country = country;
        providers[providerCounter].info = info;
        providers[providerCounter].currentRate = rate;
        providers[providerCounter].rateHistory[currentSchellingRound].value = rate;
        providers[providerCounter].isForRent = isForRent;
        providers[providerCounter].supply[currentSchellingRound].valid = true;
        providers[providerCounter].lastSupplyID = currentSchellingRound;
        return ( true, providerCounter );
    }
    function closeProvider(address owner) external returns(bool success) {
        require( isOwner() );
        providers[clients[owner].providerUID].closed = currentSchellingRound;
        clients[owner].providerUID = 0;
        delete clients[owner].lastPaidRate;
        return true;
    }
    function checkForJoin(uint256 providerUID, address clientAddress, uint256 countLimitforPrivate) constant returns(bool success, bool allowed) {
        return (
            true,
            providers[providerUID].closed == 0x00 && 
            providers[providerUID].owner != 0x00 && 
            providers[providerUID].owner != msg.sender && 
            clients[clientAddress].providerUID == 0x00 && 
            (
                ( providers[providerUID].priv && providers[providerUID].invitations[clientAddress] && (safeAdd(providers[providerUID].clientsCount, 1)) <= countLimitforPrivate) || 
                ( ! providers[providerUID].priv )
            )
        );
    }
    function isProviderValid(uint256 providerUID) constant returns(bool success, bool valid) {
        return (
            true,
            providers[providerUID].closed == 0x00 && providers[providerUID].owner != 0x00
        );
    }
    function getProviderInfoFields(uint256 providerUID) constant returns(bool success, address owner, 
        string name, string website, uint256 country, string info, address admin, uint8 rate) {
        success = true;
        owner = providers[providerUID].owner;
        name = providers[providerUID].name;
        website = providers[providerUID].website;
        country = providers[providerUID].country;
        info = providers[providerUID].info;
        admin = providers[providerUID].admin;
        rate = providers[providerUID].currentRate;
    }
    function setProviderInfoFields(uint256 providerUID, string name, string website,
        uint256 country, string info, address admin, uint8 rate) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].name = name;
        providers[providerUID].website = website;
        providers[providerUID].country = country;
        providers[providerUID].info = info;
        providers[providerUID].admin = admin;
        providers[providerUID].currentRate = rate;
        providers[providerUID].rateHistory[currentSchellingRound] = rate_s( rate, true );
        return true;
    }
    function getProviderDetailFields(uint256 providerUID) constant returns(bool success, bool priv, bool isForRent, uint256 closed) {
        success = true;
        priv = providers[providerUID].priv;
        isForRent = providers[providerUID].isForRent;
        closed = providers[providerUID].closed;
    }
    function setProviderDetailFields(uint256 providerUID, bool priv, bool isForRent, uint256 closed) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].priv = priv;
        providers[providerUID].isForRent = isForRent;
        providers[providerUID].closed = closed;
        return true;
    } 
    function getProviderSupply(uint256 providerUID, uint256 schellingRound, uint256 previousSupply) constant returns(bool success, uint256 amount) {
        if ( providers[providerUID].supply[schellingRound].valid ) {
            return ( true, providers[providerUID].supply[schellingRound].amount );
        } else {
            if ( providers[providerUID].lastSupplyID < schellingRound ) {
                return ( true, providers[providerUID].supply[providers[providerUID].lastSupplyID].amount );
            } else {
                return ( true, previousSupply );
            }
        }
    }
    function getProviderRateHistory(uint256 providerUID, uint256 schellingRound, uint8 previousRate) constant returns(bool success, uint8 rate) {
        if ( providers[providerUID].rateHistory[schellingRound].valid ) {
            return ( true, providers[providerUID].rateHistory[schellingRound].value );
        } else {
            return ( true, previousRate );
        }
    }
    function setProviderSupply(uint256 providerUID, uint256 schellingRound, uint256 amount) external returns(bool success) {
        require( isOwner() );
        if ( ( schellingRound == currentSchellingRound && ( ! providers[providerUID].supply[schellingRound].valid )  ) ||
            schellingRound != currentSchellingRound ) {
            providers[providerUID].supply[schellingRound].amount = amount;
            providers[providerUID].supply[schellingRound].valid = true;
        }
        if ( providers[providerUID].lastSupplyID < schellingRound ) {
            providers[providerUID].lastSupplyID = schellingRound;
        }
        return true;
    }
    //base provider functions
    function getProviderOwner(uint256 providerUID) constant returns(bool success, address owner) {
        return (
            true, 
            providers[providerUID].owner
        );
    }
    function setProviderOwner(uint256 providerUID, address owner) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].owner = owner;
        return true;
    }
    function getProviderAdmin(uint256 providerUID) constant returns(bool success, address admin) {
        return (
            true, 
            providers[providerUID].admin
        );
    }
    function setProviderAdmin(uint256 providerUID, address admin) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].admin = admin;
        return true;
    }
    function getProviderName(uint256 providerUID) constant returns(bool success, string name) {
        return (
            true, 
            providers[providerUID].name
        );
    }
    function setProviderName(uint256 providerUID, string name) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].name = name;
        return true;
    }
    function getProviderWebsite(uint256 providerUID) constant returns(bool success, string website) {
        return (
            true, 
            providers[providerUID].website
        );
    }
    function setProviderWebsite(uint256 providerUID, string website) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].website = website;
        return true;
    }
    function getProviderCountry(uint256 providerUID) constant returns(bool success, uint256 country) {
        return (
            true, 
            providers[providerUID].country
        );
    }
    function setProviderCountry(uint256 providerUID, uint256 country) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].country = country;
        return true;
    }
    function getProviderInfo(uint256 providerUID) constant returns(bool success, string info) {
        return (
            true, 
            providers[providerUID].info
        );
    }
    function setProviderInfo(uint256 providerUID, string info) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].info = info;
        return true;
    }
    function getProviderIsForRent(uint256 providerUID) constant returns(bool success, bool isForRent) {
        return (
            true, 
            providers[providerUID].isForRent
        );
    }
    function setProviderIsForRent(uint256 providerUID, bool isForRent) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].isForRent = isForRent;
        return true;
    }
    function getProviderRateHistory(uint256 providerUID, uint256 schellingRound) constant returns(bool success, uint8 value, bool valid) {
        return (
            true, 
            providers[providerUID].rateHistory[schellingRound].value,
            providers[providerUID].rateHistory[schellingRound].valid
        );
    }
    function setProviderRateHistory(uint256 providerUID, uint256 schellingRound, uint8 value, bool valid) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].rateHistory[schellingRound].value = value;
        providers[providerUID].rateHistory[schellingRound].valid = valid;
        return true;
    }
    function getProviderCurrentRate(uint256 providerUID) constant returns(bool success, uint8 rate) {
        return (
            true, 
            providers[providerUID].currentRate
        );
    }
    function setProviderCurrentRate(uint256 providerUID, uint8 rate) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].currentRate = rate;
        return true;
    }
    function getProviderPriv(uint256 providerUID) constant returns(bool success, bool priv) {
        return (
            true, 
            providers[providerUID].priv
        );
    }
    function setProviderPriv(uint256 providerUID, bool priv) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].priv = priv;
        return true;
    }
    function getProviderClientsCount(uint256 providerUID) constant returns(bool success, uint256 clientsCount) {
        return (
            true, 
            providers[providerUID].clientsCount
        );
    }
    function setProviderClientsCount(uint256 providerUID, uint256 clientsCount) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].clientsCount = clientsCount;
        return true;
    }
    function getProviderInvitedUser(uint256 providerUID, address clientAddress) constant returns(bool success, bool status) {
        return (
            true,
            providers[providerUID].invitations[clientAddress]
        );
    }
    function setProviderInvitedUser(uint256 providerUID, address clientAddress, bool status) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].invitations[clientAddress] = status;
        return true;
    }
    function getProviderSupply(uint256 providerUID, uint256 schellingRound) constant returns(bool success, uint256 value, bool valid) {
        return (
            true, 
            providers[providerUID].supply[schellingRound].amount,
            providers[providerUID].supply[schellingRound].valid
        );
    }
    function getProviderSupply(uint256 providerUID) constant returns(bool success, uint256 value) {
        return (
            true, 
            providers[providerUID].supply[providers[providerUID].lastSupplyID].amount
        );
    }
    function setProviderSupply(uint256 providerUID, uint256 value) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].supply[currentSchellingRound].amount = value;
        providers[providerUID].supply[currentSchellingRound].valid = true;
        providers[providerUID].lastSupplyID = currentSchellingRound;
        return true;
    }
    function getProviderLastSupplyID(uint256 providerUID) constant returns(bool success, uint256 lastSupplyID) {
        return (
            true, 
            providers[providerUID].lastSupplyID
        );
    }
    function setProviderLastSupplyID(uint256 providerUID, uint256 lastSupplyID) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].lastSupplyID = lastSupplyID;
        return true;
    }
    function getProviderClosed(uint256 providerUID) constant returns(bool success, uint256 closed) {
        return (
            true, 
            providers[providerUID].closed
        );
    }
    function setProviderClosed(uint256 providerUID, uint256 closed) external returns(bool success) {
        require( isOwner() );
        providers[providerUID].closed = closed;
        return true;
    }
}
