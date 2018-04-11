pragma solidity ^0.4.0;

import './GetTogether.sol';

contract MockGetTogether is GetTogether {

    uint internal deployedDate;

    function MockGetTogether() {
        deployedDate = now;
    }

    function owner() public view returns (address) {
        return address(0x627306090abab3a6e1400e9345bc60c78a8bef57);
    }

    function coupon() public view returns (address) {
        return address(0);
    }

    function getTogetherDate() public view returns (uint) {
        return deployedDate + 1 days;
    }

    function stakeRequired() public view returns (uint) {
        return 1 wei;
    }

    function attendeesList() public view returns (address[]) {
        address[] memory addresses;
        addresses[0] = address(0);
        return addresses;
    }

    function numberOfAttendees() public view returns (uint) {
        return 0;
    }

    function maxCapacity() public view returns (uint) {
        return 10;
    }

    function canCancel(uint datetime) public view returns (bool) {
        return true;
    }

    function amountOfStakeReturnedOnCancellation(uint _datetime) public view returns (uint) {
        return 1 wei;
    }

    function whenStakeCanBeReturned() public view returns (uint) {
        return deployedDate;
    }

    function register(address _attendee) public payable {

    }

    function cancelRegistration(address _attendee) public {

    }

    function cancelGetTogether() public {

    }
}
