pragma solidity ^0.4.15;


import './token/ERC20Basic.sol';
import './token/SafeERC20.sol';
import './ownership/Ownable.sol';
import './math/SafeMath.sol';


/**
 * @title TokenVesting
 */
contract TokenVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Basic;

    ERC20Basic token;
    // vesting
    mapping (address => uint256) totalVestedAmount;

    struct Vesting {
        uint256 amount;
        uint256 vestingDate;
    }

    address[] accountKeys;
    mapping (address => Vesting[]) public vestingAccounts;

    // events
    event Vest(address indexed beneficiary, uint256 amount);
    event VestingCreated(address indexed beneficiary, uint256 amount, uint256 vestingDate);

    // modifiers here
    modifier tokenSet() {
        require(address(token) != address(0));
        _;
    }

    // vesting constructor
    function TokenVesting(address token_address){
       require(token_address != address(0));
       token = ERC20Basic(token_address);
    }

    // set vesting token address
    function setVestingToken(address token_address) external onlyOwner {
        require(token_address != address(0));
        token = ERC20Basic(token_address);
    }

    // create vesting by introducing beneficiary addres, total token amount, start date, duration for each vest period and number of periods
    function createVestingByDurationAndSplits(address user, uint256 total_amount, uint256 startDate, uint256 durationPerVesting, uint256 times) public onlyOwner tokenSet {
        require(user != address(0));
        require(startDate >= now);
        require(times > 0);
        require(durationPerVesting > 0);
        uint256 vestingDate = startDate;
        uint256 i;
        uint256 amount = total_amount.div(times);
        for (i = 0; i < times; i++) {
            vestingDate = vestingDate.add(durationPerVesting);
            if (vestingAccounts[user].length == 0){
                accountKeys.push(user);
            }
            vestingAccounts[user].push(Vesting(amount, vestingDate));
            VestingCreated(user, amount, vestingDate);
        }
    }

    // get current user total granted token amount
    function getVestingAmountByNow(address user) constant returns (uint256){
        uint256 amount;
        uint256 i;
        for (i = 0; i < vestingAccounts[user].length; i++) {
            if (vestingAccounts[user][i].vestingDate < now) {
                amount = amount.add(vestingAccounts[user][i].amount);
            }
        }

    }

    // get user available vesting amount, total amount - received amount
    function getAvailableVestingAmount(address user) constant returns (uint256){
        uint256 amount;
        amount = getVestingAmountByNow(user);
        amount = amount.sub(totalVestedAmount[user]);
        return amount;
    }

    // get list of vesting users address
    function getAccountKeys(uint256 page) external constant returns (address[10]){
        address[10] memory accountList;
        uint256 i;
        for (i=0 + page * 10; i<10; i++){
            if (i < accountKeys.length){
                accountList[i - page * 10] = accountKeys[i];
            }
        }
        return accountList;
    }

    // vest
    function vest() external tokenSet {
        uint256 availableAmount = getAvailableVestingAmount(msg.sender);
        require(availableAmount > 0);
        totalVestedAmount[msg.sender] = totalVestedAmount[msg.sender].add(availableAmount);
        token.transfer(msg.sender, availableAmount);
        Vest(msg.sender, availableAmount);
    }

    // drain all eth and tokens to owner in an emergency situation
    function drain() external onlyOwner {
        owner.transfer(this.balance);
        token.transfer(owner, this.balance);
    }
}
