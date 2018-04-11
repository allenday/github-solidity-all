pragma solidity ^0.4.0;

import './GetTogether.sol';
import './Coupon.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract BlockTogether is GetTogether, Ownable {

    Coupon public coupon;
    uint public getTogetherDate;
    uint public maxCapacity;
    uint public stakeRequired;

    uint public numberOfAttendees;

    function BlockTogether(address _coupon, uint _getTogetherDate, uint _maxCapacity, uint _stakeRequired) public {
        require(_coupon != address(0));
        require(_getTogetherDate > now);
        require(_maxCapacity > 1);

        coupon = Coupon(_coupon);
        getTogetherDate = _getTogetherDate;
        maxCapacity = _maxCapacity;
        stakeRequired = _stakeRequired;

        GetTogetherCreated(msg.sender, getTogetherDate, maxCapacity, stakeRequired);
    }

    function attendeesList() public view returns (address[]) {
        address[] memory attendees;
        return attendees;
    }

    function canCancel(uint datetime) public view returns (bool) {
        false;
    }

    function amountOfStakeReturnedOnCancellation(uint datetime) public view returns (uint) {
        return 0;
    }

    function whenStakeCanBeReturned() public view returns (uint) {
        return 0;
    }

    function amountOfStakeToBeReturned(address attendee, uint datetime) public view returns (uint) {
        return 0;
    }

    function register() public payable {

    }

    function cancelRegistration() public {

    }

    function cancelGetTogether() public {

    }
}
