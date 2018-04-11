/*
    module.sol
    1.0.0
    
    Rajci 'iFA' Andor @ ifa@corion.io / ifa@ethereumlottery.net
    CORION Platform
*/
pragma solidity ^0.4.15;

import "./announcementTypes.sol";

contract abstractModuleHandler {
    function transfer(address from, address to, uint256 value, bool fee) external returns (bool success) {}
    function balanceOf(address owner) public constant returns (bool success, uint256 value) {}
}

contract module is announcementTypes {
    /* Enumerations */
    enum status {
        New,
        Connected,
        Disconnected,
        Disabled
    }
    /* Variables */
    status public moduleStatus;
    uint256 public disabledUntil;
    address public moduleHandlerAddress;
    /* Constructor */
    function module(address moduleHandler) {
        registerModuleHandler(moduleHandler);
    }
    /* Externals */
    function disableModule(bool forever) external onlyForModuleHandler returns (bool success) {
        _disableModule(forever);
        return true;
    }
    function replaceModuleHandler(address newModuleHandlerAddress) external onlyForModuleHandler returns (bool success) {
        _replaceModuleHandler(newModuleHandlerAddress);
        return true;
    }
    function connectModule() external onlyForModuleHandler returns (bool success) {
        _connectModule();
        return true;
    }
    function disconnectModule() external onlyForModuleHandler returns (bool success) {
        _disconnectModule();
        return true;
    }
    function replaceModule(address newModuleAddress) external onlyForModuleHandler returns (bool success) {
        _replaceModule(newModuleAddress);
        return true;
    }
    function transferEvent(address from, address to, uint256 value) external onlyForModuleHandler returns (bool success) {
        _transferEvent(from, to, value);
        return true;
    }
    function configureModule(announcementType aType, uint256 value, address addr) onlyForModuleHandler external returns(bool success) {
        _configureModule(aType, value, addr);
        return true;
    }
    function newSchellingRoundEvent(uint256 roundID, uint256 reward) external onlyForModuleHandler returns (bool success) {
        _newSchellingRoundEvent(roundID, reward);
        return true;
    }
    /* Internals */
    function _disableModule(bool forever) internal {
        /*
            Disable the module for one week, if the forever true then for forever.
            This function calls the Publisher module.
            
            @forever    For forever or not
        */
        if ( forever ) { moduleStatus = status.Disabled; }
        else { disabledUntil = block.number + 5760; }
    }
    function _replaceModuleHandler(address newModuleHandlerAddress) internal {
        /*
            Replace the ModuleHandler address.
            This function calls the Publisher module.
            
            @newModuleHandlerAddress    New module handler address
        */
        require( moduleStatus == status.Connected );
        moduleHandlerAddress = newModuleHandlerAddress;
    }
    function _connectModule() internal {
        /*
            Registering and/or connecting-to ModuleHandler.
            This function is called by ModuleHandler load or by Publisher.
        */
        require( moduleStatus == status.New );
        moduleStatus = status.Connected;
    }
    function _disconnectModule() internal {
        /*
            Disconnect the module from the ModuleHandler.
            This function calls the Publisher module.
        */
        require( moduleStatus != status.New && moduleStatus != status.Disconnected );
        moduleStatus = status.Disconnected;
    }
    function _replaceModule(address newModuleAddress) internal {
        /*
            Replace the module for an another new module.
            This function calls the Publisher module.
            We send every Token and ether to the new module.
            
            @newModuleAddress   New module handler address
        */
        require( moduleStatus != status.New && moduleStatus != status.Disconnected);
        var (_success, _balance) = abstractModuleHandler(moduleHandlerAddress).balanceOf(address(this));
        require( _success );
        if ( _balance > 0 ) {
            require( abstractModuleHandler(moduleHandlerAddress).transfer(address(this), newModuleAddress, _balance, false) );
        }
        moduleStatus = status.Disconnected;
    }
    function _transferEvent(address from, address to, uint256 value) internal {}
    function _configureModule(announcementType aType, uint256 value, address addr) internal {}
    function _newSchellingRoundEvent(uint256 roundID, uint256 reward) internal {}
    function registerModuleHandler(address _moduleHandlerAddress) internal {
        /*
            Module constructor function for registering ModuleHandler address.
        */
        moduleHandlerAddress = _moduleHandlerAddress;
    }
    function isModuleHandler(address addr) internal returns (bool ret) {
        /*
            Test for ModuleHandler address.
            If the module is not connected then returns always false.
            
            @addr   Address to check
            
            @ret    This is the module handler address or not
        */
        if ( moduleHandlerAddress == 0x00 ) { return true; }
        if ( moduleStatus != status.Connected ) { return false; }
        return addr == moduleHandlerAddress;
    }
    /* Constants */
    function isActive() public constant returns (bool success, bool active) {
        /*
            Check self for ready for functions or not.
            
            @success    Function call was successfull or not
            @active     Ready for functions or not
        */
        return (true, moduleStatus == status.Connected && block.number >= disabledUntil);
    }
    /* Modifiers */
    modifier onlyForModuleHandler() {
        require( msg.sender == moduleHandlerAddress );
        _;
    }
    modifier readyModule() {
        var (_success, _active) = isActive();
        require( _success && _active ); 
        _;
    }
}
