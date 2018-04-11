/*
    moduleHandler.sol
    1.0.0
    
    Rajci 'iFA' Andor @ ifa@corion.io / ifa@ethereumlottery.net
    CORION Platform
*/
pragma solidity ^0.4.15;

import "./module.sol";
import "./announcementTypes.sol";
import "./multiOwner.sol";
import "./publisher.sol";
import "./token.sol";
import "./provider.sol";
import "./providerDB.sol";
import "./providerRewardLib.sol";
import "./schellingLight.sol";
import "./premium.sol";

contract abstractModule is announcementTypes {
    function connectModule() external returns (bool success) {}
    function disconnectModule() external returns (bool success) {}
    function replaceModule(address addr) external returns (bool success) {}
    function disableModule(bool forever) external returns (bool success) {}
    function configureModule(announcementType aType, uint256 value, address addr) external returns(bool success) {}
    function isActive() public constant returns (bool success) {}
    function replaceModuleHandler(address newHandler) external returns (bool success) {}
    function transferEvent(address from, address to, uint256 value) external returns (bool success) {}
    function newSchellingRoundEvent(uint256 roundID, uint256 reward) external returns (bool success) {}
}

contract moduleHandler is multiOwner, announcementTypes {
    /* Structures */
    struct modules_s {
        address addr;
        bytes32 name;
        bool schellingEvent;
        bool transferEvent;
    }
    /* Variables */
    modules_s[] public modules;
    uint256 public debugModeUntil = block.number + 1000000;
    /* Constructor */
    function moduleHandler(address[] newOwners) multiOwner(newOwners) {}
    /* Externals */
    function load(bool forReplace, address Token, address Premium, address Publisher, address Schelling, address Provider) external {
        /*
            Loading modulest to ModuleHandler.
            
            This module can be called only once and only by the owner, if every single module and its database are already put on the blockchain.
            If forReplace is true, than the ModuleHandler will be replaced. Before the publishing of its replace, the new contract must be already on the blockchain.
            
            @forReplace     Is it for replace or not. If not, it will be connected to the module.
            @Token          address of token.
            @Publisher      address of publisher.
            @Schelling      address of Schelling.
            @Provider       address of provider
        */
        require( owners[msg.sender] );
        require( modules.length == 0 );
        addModule( modules_s(Token,      sha3('Token'),      false, false),  ! forReplace);
        addModule( modules_s(Premium,    sha3('Premium'),    false, false),  ! forReplace);
        addModule( modules_s(Publisher,  sha3('Publisher'),  false, true),   ! forReplace);
        addModule( modules_s(Schelling,  sha3('Schelling'),  false, true),   ! forReplace);
        addModule( modules_s(Provider,   sha3('Provider'),   true, true),    ! forReplace);
    }
    function replaceModule(string name, address addr, bool callCallback) external returns (bool success) {
        /*
            Module replace, can be called only by the Publisher contract or owner during debug mode.
            
            @name           Name of module.
            @addr           Address of module.
            @callCallback   Call the replaceable module to confirm replacement or not.
            
            @success        Was the Function successful?
        */
        var (_success, _found, _id) = getModuleIDByAddress(msg.sender);
        require( _success );
        if ( ! ( _found && modules[_id].name == sha3('Publisher') )) {
            require( block.number < debugModeUntil );
            if ( ! insertAndCheckDo(calcDoHash("replaceModule", sha3(name, addr, callCallback))) ) {
                return true;
            }
        }
        (_success, _found, _id) = getModuleIDByName(name);
        require( _success && _found );
        if ( callCallback ) {
            require( abstractModule(modules[_id].addr).replaceModule(addr) );
        }
        modules[_id].addr = addr;
        require( abstractModule(addr).connectModule() );
        return true;
    }
    function callReplaceCallback(string moduleName, address newModule) external returns (bool success) {
        require( block.number < debugModeUntil );
        if ( ! insertAndCheckDo(calcDoHash("callReplaceCallback", sha3(moduleName, newModule))) ) {
            return true;
        }
        var (_success, _found, _id) = getModuleIDByName(moduleName);
        require( _success && _found );
        require( abstractModule(modules[_id].addr).replaceModule(newModule) );
        return true;
    }
    function newModule(string name, address addr, bool schellingEvent, bool transferEvent) external returns (bool success) {
        /*
            Adding new module to the database. Can be called only by the Publisher contract or while debug mode by owners.
            
            @name               Name of module.
            @addr               Address of module.
            @schellingEvent     Gets it new Schelling round notification?
            @transferEvent      Gets it new transaction notification?
            
            @success            Was the Function successful?
        */
        var (_success, _found, _id) = getModuleIDByAddress(msg.sender);
        require( _success );
        if ( ! ( _found && modules[_id].name == sha3('Publisher') )) {
            require( block.number < debugModeUntil );
            if ( ! insertAndCheckDo(calcDoHash("newModule", sha3(name, addr, schellingEvent, transferEvent))) ) {
                return true;
            }
        }
        addModule( modules_s(addr, sha3(name), schellingEvent, transferEvent), true);
        return true;
    }
    function dropModule(string name, bool callCallback) external returns (bool success) {
        /*
            Deleting module from the database. Can be called only by the Publisher contract or while debug mode by owners.
            
            @name           Name of module to delete.
            @callCallback   Call the replaceable module to confirm replacement or not.
            
            @success        Was the Function successful?
        */
        var (_success, _found, _id) = getModuleIDByAddress(msg.sender);
        require( _success );
        if ( ! ( _found && modules[_id].name == sha3('Publisher') )) {
            require( block.number < debugModeUntil );
            if ( ! insertAndCheckDo(calcDoHash("dropModule", sha3(name, callCallback))) ) {
                return true;
            }
        }
        (_success, _found, _id) = getModuleIDByName(name);
        require( _success && _found );
        if( callCallback ) {
            abstractModule(modules[_id].addr).disableModule(true);
        }
        delete modules[_id];
        return true;
    }
    function callDisableCallback(string moduleName) external returns (bool success) {
        require( block.number < debugModeUntil );
        if ( ! insertAndCheckDo(calcDoHash("callDisableCallback", sha3(moduleName))) ) {
            return true;
        }
        var (_success, _found, _id) = getModuleIDByName(moduleName);
        require( _success && _found );
        require( abstractModule(modules[_id].addr).disableModule(true) );
        return true;
    }
    function broadcastTransfer(address from, address to, uint256 value) external returns (bool success) {
        /*
            Announcing transactions for the modules.
            
            Can be called only by the token module.
            Only the configured modules get notifications.( transferEvent )
            
            @from       from who.
            @to         to who.
            @value      amount.
            
            @success    Was the Function successful?
        */
        var (_success, _found, _id) = getModuleIDByAddress(msg.sender);
        require( _success && _found && modules[_id].name == sha3('Token') );
        for ( uint256 a=0 ; a<modules.length ; a++ ) {
            if ( modules[a].transferEvent && abstractModule(modules[a].addr).isActive() ) {
                require( abstractModule(modules[a].addr).transferEvent(from, to, value) );
            }
        }
        return true;
    }
    function broadcastSchellingRound(uint256 roundID, uint256 reward) external returns (bool success) {
        /*
            Announcing new Schelling round for the modules.
            Can be called only by the Schelling module.
            Only the configured modules get notifications( schellingEvent ).
            
            @roundID        Number of Schelling round.
            @reward         Coin emission in this Schelling round.
            
            @success        Was the Function successful?
        */
        var (_success, _found, _id) = getModuleIDByAddress(msg.sender);
        require( _success && _found && modules[_id].name == sha3('Schelling') );
        for ( uint256 a=0 ; a<modules.length ; a++ ) {
            if ( modules[a].schellingEvent && abstractModule(modules[a].addr).isActive() ) {
                require( abstractModule(modules[a].addr).newSchellingRoundEvent(roundID, reward) );
            }
        }
        return true;
    }
    function replaceModuleHandler(address newHandler) external returns (bool success) {
        /*
            Replacing ModuleHandler.
            
            Can be called only by the publisher or while debug mode by owners.
            Every module will be informed about the ModuleHandler replacement.
            
            @newHandler     Address of the new ModuleHandler.
            
            @success        Was the Function successful?
        */
        var (_success, _found, _id) = getModuleIDByAddress(msg.sender);
        require( _success );
        if ( ! ( _found && modules[_id].name == sha3('Publisher') )) {
            require( block.number < debugModeUntil );
            if ( ! insertAndCheckDo(calcDoHash("replaceModuleHandler", sha3(newHandler))) ) {
                return true;
            }
        }
        for ( uint256 a=0 ; a<modules.length ; a++ ) {
            require( abstractModule(modules[a].addr).replaceModuleHandler(newHandler) );
        }
        return true;
    }
    function mint(address to, uint256 value) external returns (bool success) {
        /*
            Token emission request. Can be called only by the provider.
            
            @to         Place of new token
            @value      Token amount
            
            @success    Was the function successfull?
        */
        var (_success, _found, _id) = getModuleIDByAddress(msg.sender);
        require( _success && _found && modules[_id].name == sha3('Provider') );
        (_success, _found, _id) = getModuleIDByName('Token');
        require( _success && _found );
        require( token(modules[_id].addr).mint(to, value) );
        return true;
    }
    function transfer(address from, address to, uint256 value, bool fee) external returns (bool success) {
        /*
            Token transaction request. Can be called only by a module.
            
            @from       From who.
            @to         To who.
            @value      Token amount.
            @fee        Transaction fee will be charged or not?
            
            @success    Was the function successfull?
        */
        var (_success, _found, _id) = getModuleIDByAddress(msg.sender);
        require( _success && _found );
        (_success, _found, _id) = getModuleIDByName('Token');
        require( _success && _found );
        require( token(modules[_id].addr).transferFromByModule(from, to, value, fee) );
        return true;
    }
    function processTransactionFee(address from, uint256 value) external returns (bool success) {
        /*
            Token transaction fee. Can be called only by the provider.
            
            @from       From who.
            @value      Token amount.
            
            @success    Was the function successfull?
        */
        var (_success, _found, _id) = getModuleIDByAddress(msg.sender);
        require( _success && _found && modules[_id].name == sha3('Provider') );
        (_success, _found, _id) = getModuleIDByName('Token');
        require( _success && _found );
        require( token(modules[_id].addr).processTransactionFee(from, value) );
        return true;
    }
    function burn(address from, uint256 value) external returns (bool success) {
        /*
            Token burn. Can be called only by Schelling.
            
            @from       From who.
            @value      Token amount.
            @success    Was the function successfull?
        */
        var (_success, _found, _id) = getModuleIDByAddress(msg.sender);
        require( _success && _found && modules[_id].name == sha3('Schelling') );
        (_success, _found, _id) = getModuleIDByName('Token');
        require( _success && _found );
        require( token(modules[_id].addr).burn(from, value) );
        return true;
    }
    function configureModule(string moduleName, announcementType aType, uint256 value, address addr) external returns (bool success) {
        /*
            Changing configuration of a module. Can be called only by Publisher or while debug mode by owners.
            
            @moduleName Module name which will be configured
            @aType      Type of variable (announcementType).
            @value      New value
            @addr       New address
            
            @success    Was the function successfull?
        */
        var (_success, _found, _id) = getModuleIDByAddress(msg.sender);
        require( _success );
        if ( ! ( _found && modules[_id].name == sha3('Publisher') )) {
            require( block.number < debugModeUntil );
            if ( ! insertAndCheckDo(calcDoHash("configureModule", sha3(moduleName, aType, value, addr))) ) {
                return true;
            }
        }
        (_success, _found, _id) = getModuleIDByName(moduleName);
        require( _success && _found );
        require( abstractModule(modules[_id].addr).configureModule(aType, value, addr) );
        return true;
    }
    function freezing(bool forever) external {
        /*
            Freezing CORION Platform. Can be called only by the owner.
            Freez can not be recalled!
            
            @forever    Is it forever or not?
        */
        require( owners[msg.sender] );
        if ( forever ) {
            if ( ! insertAndCheckDo(calcDoHash("freezing", sha3(forever))) ) {
                return;
            }            
        }
        for ( uint256 a=0 ; a<modules.length ; a++ ) {
            require( abstractModule(modules[a].addr).disableModule(forever) );
        }
    }
    /* Internals */
    function addModule(modules_s input, bool call) internal {
        /*
            Inside function for registration of the modules in the database.
            If the call is false, wont happen any direct call.
            
            @input  Structure of module.
            @call   Is connect to the module or not.
        */
        if ( call ) { require( abstractModule(input.addr).connectModule() ); }
        var (_success, _found, _id) = getModuleIDByAddress(input.addr);
        require( _success && ! _found );
        (_success, _found, _id) = getModuleIDByHash(input.name);
        require( _success && ! _found );
        (_success, _found, _id) = getModuleIDByAddress(0x00);
        require( _success );
        if ( ! _found ) {
            _id = modules.length;
            modules.length++;
        }
        modules[_id] = input;
    }
    /* Constants */
    function balanceOf(address owner) public constant returns (bool success, uint256 value) {
        /*
            Query of token balance.
            
            @owner      Address
            
            @success    Was the Function successful?
            @value      Balance
        */
        var (_success, _found, _id) = getModuleIDByName('Token');
        require( _success && _found );
        return (true, token(modules[_id].addr).balanceOf(owner));
    }
    function totalSupply() public constant returns (bool success, uint256 value) {
        /*
            Query of the whole token amount.
            
            @value      Amount
            @success    Was the function successfull?
        */
        var (_success, _found, _id) = getModuleIDByName('Token');
        require( _success && _found );
        return (true, token(modules[_id].addr).totalSupply());
    }
    function getCurrentSchellingRoundID() public constant returns (bool success, uint256 round) {
        /*
            Query of number of the actual Schelling round.
            
            @round      Schelling round.
            @success    Was the function successfull?
        */
        var (_success, _found, _id) = getModuleIDByName('Schelling');
        require( _success && _found );
        ( _success, _id ) = schelling(modules[_id].addr).getCurrentSchellingRoundID();
        require( _success );
        return (true, _id);
    }
    function getModuleAddressByName(string name) public constant returns( bool success, bool found, address addr ) {
        /*
            Search by name for module. The result is an Ethereum address.
            
            @name       Name of module.
            
            @success    Was the Function successful?
            @addr       Address of module.
            @found      Is there any result.
            @success    Was the transaction succesfull or not.
        */
        var (_success, _found, _id) = getModuleIDByName(name);
        if ( _success && _found ) { return (true, true, modules[_id].addr); }
        return (true, false, 0x00);
    }
    function getModuleIDByHash(bytes32 hashOfName) public constant returns( bool success, bool found, uint256 id ) {
        /*
            Search by hash of name in the module array. The result is an index array.
            
            @name       Name of module.
            
            @success    Was the Function successful?
            @id         Index of module.
            @found      Was there any result or not.
        */
        for ( uint256 a=0 ; a<modules.length ; a++ ) {
            if ( modules[a].name == hashOfName ) {
                return (true, true, a);
            }
        }
        return (true, false, 0);
    }
    function getModuleIDByName(string name) public constant returns( bool success, bool found, uint256 id ) {
        /*
            Search by name for module. The result is an index array.
            
            @name       Name of module.
            
            @success    Was the Function successful?
            @id         Index of module.
            @found      Was there any result or not.
        */
        return getModuleIDByHash(sha3(name));
    }
    function getModuleIDByAddress(address addr) public constant returns( bool success, bool found, uint256 id ) {
        /*
            Search by ethereum address for module. The result is an index array.
            
            @address    Address of the module
            
            @success    Was the Function successful?
            @id         Index of module.
            @found      Was there any result or not.
        */
        for ( uint256 a=0 ; a<modules.length ; a++ ) {
            if ( modules[a].addr == addr ) {
                return (true, true, a);
            }
        }
        return (true, false, 0);
    }
}
