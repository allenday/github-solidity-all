pragma solidity ^0.4.0;

contract Proxy {
    address public fallback;
    address public creator;
    bool public killSwitchStatus;
    mapping (address => address) personal;

    modifier onlyCreator () {
        if (msg.sender != creator) {
            throw;
        }
        _;
    }

    modifier killSwitch () {
        if (killSwitchStatus) {
            throw;
        }
        _;
    }

    function VersionControl() {
        creator = msg.sender;
    }

    function setCreator() {
        if (creator == 0x0) {
            creator = msg.sender;
        }
    }

    function toggleKillSwitch() onlyCreator() {
        killSwitchStatus = !killSwitchStatus;
    }

    function setFallback(address _fallback) onlyCreator() {
        fallback = _fallback;
    }

    function setPersonal(address _personal) {
        personal[msg.sender] = _personal;
    }

    function getVersion() returns (address) {
        return personal[msg.sender] != 0x0 ? personal[msg.sender] : fallback;
    }

    function call(bytes _methodSignature) killSwitch() {
        EtherGit eg = EtherGit(getVersion());
        eg.call(_method);
    }
}
