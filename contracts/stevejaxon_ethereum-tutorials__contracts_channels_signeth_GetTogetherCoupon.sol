pragma solidity ^0.4.0;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import './Coupon.sol';
import './GetTogether.sol';

/**
 * @title GetTogetherCoupon
 * @dev Implementation of the Coupon interface for use with the BlockTogether contract.
 */
// TODO decide whether the contract can be paused
contract GetTogetherCoupon is Ownable, Coupon {

    using SafeMath for uint256;

    mapping (address => uint) internal balances;
    mapping (address => mapping(address => uint)) internal stakes;

    modifier hasLargeEnoughBalance(uint _amount) {
        require(balances[msg.sender] >= _amount);
        _;
    }

    function deposit() public payable {
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        Deposited(msg.sender, msg.value);
    }

    function withdraw(uint _amount) public hasLargeEnoughBalance(_amount) {
        require(_amount > 0);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        msg.sender.transfer(_amount);
        Withdrawn(msg.sender, _amount);
    }

    function balanceOf(address _account) public view returns (uint) {
        return balances[_account];
    }

    function totalStaked(address _getTogether) public view returns (uint) {
        return stakes[_getTogether][address(0)];
    }

    function stakedAmount(address _getTogether, address _account) public view returns (uint) {
        return stakes[_getTogether][_account];
    }

    function registerForGetTogether(address _getTogether) public {
        require(_getTogether != address(0));
        GetTogether getTogether = GetTogether(_getTogether);
        require(getTogether.getTogetherDate() > now);
        require(getTogether.numberOfAttendees() < getTogether.maxCapacity());
        stake(getTogether.stakeRequired(), _getTogether);
    }

    function stake(uint _amount, address _getTogether) internal hasLargeEnoughBalance(_amount) {
        // Require that the msg.sender has not already registered / staked a balance for the get-together
        require(stakes[_getTogether][msg.sender] == 0);
        // Very unlikely - if someone owned the address 0x0 then they would own
        require(msg.sender != address(0));
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        stakes[_getTogether][msg.sender] = _amount;
        // Keep track of the total amount staked
        stakes[_getTogether][address(0)] = stakes[_getTogether][address(0)].add(_amount);
    }

    // TODO how to keep track of the total balance that has been staked to an address
    function redeemStake(address _getTogether, address _to, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) public {
        require(_getTogether != address(0));
        require(stakes[_getTogether][_to] != 0);
        require(_value > 0);
        GetTogether getTogether = GetTogether(_getTogether);
        require(now >= getTogether.whenStakeCanBeReturned());
        require(getTogether.owner() != address(0));
        address recoveredSignerAddress = recoverAddressOfSigner(_getTogether, _to, _value, _v, _r, _s);
        require(recoveredSignerAddress == getTogether.owner());
        stakes[_getTogether][_to] = 0;
        balances[_to] = balances[_to].add(_value);
        stakes[_getTogether][address(0)] = stakes[_getTogether][address(0)].sub(_value);
    }

    function recoverAddressOfSigner(address _getTogether, address _to, uint256 _value, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (address) {
        require(_to != address(0));
        bytes32 hash = keccak256(_getTogether, _to, _value);
        return recover(hash, _v, _r, _s);
    }

    function recover(bytes32 h, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(prefix, h);
        return ecrecover(prefixedHash, v, r, s);
    }
}
