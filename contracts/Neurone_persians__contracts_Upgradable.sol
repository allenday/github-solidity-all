pragma solidity ^0.4.18;

import "./Owned.sol";

/**
 * The contract can be deprecated and the owner can set - only once - another address to advertise
 * clients of the existence of another more recent contract.
 */
contract Upgradable is Owned {

    string  public VERSION;
    bool    public deprecated;
    string  public newVersion;
    address public newAddress;
    uint    public timestamp;

    function Upgradable(string _version) public {
        VERSION = _version;
    }

    function setDeprecated(string _newVersion, address _newAddress) external onlyOwner returns (bool success) {
        require(!deprecated && !Upgradable(_newAddress).deprecated());
        address _currentAddress = this;
        require(_newAddress != _currentAddress);
        deprecated = true;
        newVersion = _newVersion;
        newAddress = _newAddress;
        timestamp = block.timestamp;
        return true;
    }
}