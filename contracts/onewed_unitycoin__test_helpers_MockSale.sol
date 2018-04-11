pragma solidity ^0.4.15;

import '../../contracts/UnitySale.sol';


contract MockSale is UnitySale {
    function MockSale(
        address _token,
        bool _isPresale,
        uint256 _minFundingGoalWei,
        uint256 _minContributionWei,
        uint256 _maxContributionWei,
        uint256 _start,
        uint256 _durationHours,
        uint256[] _hourBasedDiscounts
    ) UnitySale(_token, _isPresale, _minFundingGoalWei, _minContributionWei, _maxContributionWei, _start, _durationHours, _hourBasedDiscounts) {}

    function getTokenAddress() external constant returns (address) {
        return address(token);
    }
    function getNow() external constant returns (uint256) {
        return now;
    }
    function getCurrentDiscountTrancheIndex() external constant returns (uint8) {
        determineDiscountRate(); // just to trigger the check and update
        return currentDiscountTrancheIndex;
    }
    function getDiscountTrancheEnd(uint8 _index) external constant returns (uint256) {
        determineDiscountRate(); // just to trigger the check and update
        return discountTranches[_index].end;
    }
    function getDiscountTrancheDiscount(uint8 _index) external constant returns (uint8) {
        determineDiscountRate(); // just to trigger the check and update
        return discountTranches[_index].discount;
    }
    function getWeiForRefund() external constant returns (uint256) {
        return weiForRefund;
    }
}
