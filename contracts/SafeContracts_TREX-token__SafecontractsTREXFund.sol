pragma solidity ^0.4.0;

// Title SafecontractsTREXFund.sol

import "AbstractSafecontractsTREXToken.sol";
import "AbstractSafecontractsTREXCrowdfunding.sol";


// @title Fund contract - Implements revenue distribution.
// @author Stefan George - <stefan.george@consensys.net>
// Customize @author Rocky Fikki - <rocky@fikki.net>
// Credit - https://github.com/ConsenSys/singulardtv-contracts

contract SafecontractsTREXFund {

    /*
     *  External contracts
     */
    SafecontractsTREXToken public safecontractsTREXToken;
    SafecontractsTREXCrowdfunding public safecontractsTREXCrowdfunding;

    /*
     *  Storage
     */
    address public owner;
    address constant public trexdevshop = {{MistWallet}};
    uint public totalRevenue;

    // User's address => Revenue at time of withdraw
    mapping (address => uint) public revenueAtTimeOfWithdraw;

    // User's address => Revenue which can be withdrawn
    mapping (address => uint) public owed;

    /*
     *  Modifiers
     */
    modifier noEther() {
        if (msg.value > 0) {
            throw;
        }
        _
    }

    modifier onlyOwner() {
        // Only guard is allowed to do this action.
        if (msg.sender != owner) {
            throw;
        }
        _
    }

    modifier campaignEndedSuccessfully() {
        if (!safecontractsTREXCrowdfunding.campaignEndedSuccessfully()) {
            throw;
        }
        _
    }

    /*
     *  Contract functions
     */
    // @dev Deposits revenue. Returns success.
    function depositRevenue()
        external
        campaignEndedSuccessfully
        returns (bool)
    {
        totalRevenue += msg.value;
        return true;
    }

    // @dev Withdraws revenue share for user. Returns revenue share.
    // @param forAddress Shareholder's address.
    function calcRevenue(address forAddress) internal returns (uint) {
        return safecontractsTREXToken.balanceOf(forAddress) * (totalRevenue - revenueAtTimeOfWithdraw[forAddress]) / safecontractsTREXToken.totalSupply();
    }

    // @dev Withdraws revenue share for user. Returns revenue share.
    function withdrawRevenue()
        external
        noEther
        returns (uint)
    {
        uint value = calcRevenue(msg.sender) + owed[msg.sender];
        revenueAtTimeOfWithdraw[msg.sender] = totalRevenue;
        owed[msg.sender] = 0;
        if (value > 0 && !msg.sender.send(value)) {
            throw;
        }
        return value;
    }

    // @dev Credits revenue share to owed balance.
    // @param forAddress Shareholder's address.
    function softWithdrawRevenueFor(address forAddress)
        external
        noEther
        returns (uint)
    {
        uint value = calcRevenue(forAddress);
        revenueAtTimeOfWithdraw[forAddress] = totalRevenue;
        owed[forAddress] += value;
        return value;
    }

    // @dev Setup function sets external contracts' addresses.
    // @param safecontractsTREXTokenAddress Token address.
    function setup(address safecontractsTREXCrowdfundingAddress, address safecontractsTREXTokenAddress)
        external
        noEther
        onlyOwner
        returns (bool)
    {
        if (address(safecontractsTREXCrowdfunding) == 0 && address(safecontractsTREXToken) == 0) {
            safecontractsTREXCrowdfunding = SafecontractsTREXCrowdfunding(safecontractsTREXCrowdfundingAddress);
            safecontractsTREXToken = SafecontractsTREXToken(safecontractsTREXTokenAddress);
            return true;
        }
        return false;
    }

    // @dev Contract constructor function sets guard and initial token balances.
    function SafecontractsTREXFund() noEther {
        // Set owner address
        owner = msg.sender;
    }
}
