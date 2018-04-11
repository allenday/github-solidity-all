pragma solidity ^0.4.0;

/**
 * @title Coupon
 * @dev
 * Inspired by the ControlAccess Smart Contract (https://gist.github.com/PhABC/3d9f865592035ffde450b59aedcbaed6) presented as part of the
 * "Off-Chain Whitelist with On-Chain Verification for Ethereum Smart Contracts" article by Philippe Castonguay.
 */
contract Coupon {

    event Deposited(address _account, uint _amount);
    event Withdrawn(address _account, uint _amount);

    function balanceOf(address _account) public view returns (uint);
    function totalStaked(address _getTogether) public view returns (uint);
    function stakedAmount(address _getTogether, address _account) public view returns (uint);
    function deposit() public payable;
    function withdraw(uint _amount) public;

    function registerForGetTogether(address _getTogether) public;
    function redeemStake(address _getTogether, address _to, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) public;
}
