pragma solidity ^0.4.2;

contract EtherCred {

    struct CitizenReference {
        address id;
        bool isActive;
    }

    struct Citizen {
        CitizenReference[] approvals;
        CitizenReference[] disapprovals;
    }

    mapping(address => Citizen) citizens;

    function approve(address _target) {
        citizens[msg.sender].approvals.push(CitizenReference(_target, true));
    }

    function unapprove(uint _index) {
        if(_index < citizens[msg.sender].approvals.length) {
            citizens[msg.sender].approvals[_index].isActive = false;
        }
    }

    function getApprovalsFor(address _target) constant returns (address[]) {
        address[] memory activeAddresses = new address[](citizens[_target].approvals.length);
        for (uint i = 0; i < citizens[_target].approvals.length; i++) {
            if(citizens[_target].approvals[i].isActive) {
                activeAddresses[i] = citizens[_target].approvals[i].id;
            }
        }
        return activeAddresses;
    }

    function disapprove(address _target) {
        citizens[msg.sender].disapprovals.push(CitizenReference(_target, true));
    }

    function undisapprove(uint _index) {
        if(_index < citizens[msg.sender].disapprovals.length) {
            citizens[msg.sender].disapprovals[_index].isActive = false;
        }
    }

    function getDisapprovalsFor(address _target) constant returns (address[]) {
        address[] memory activeAddresses = new address[](citizens[_target].disapprovals.length);
        for (uint i = 0; i < citizens[_target].disapprovals.length; i++) {
            if(citizens[_target].disapprovals[i].isActive) {
                activeAddresses[i] = citizens[_target].disapprovals[i].id;
            }
        }
        return activeAddresses;
    }
}
