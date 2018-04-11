pragma solidity ^0.4.0;

// Title SafecontractsTREXToken.sol

import "StandardToken.sol";
import "AbstractSafecontractsTREXFund.sol";
import "AbstractSafecontractsTREXCrowdfunding.sol";


// @title Token contract - Implements token issuance.
// @author Stefan George - <stefan.george@consensys.net>
// Customize @author Rocky Fikki - <rocky@fikki.net>
// Credit - https://github.com/ConsenSys/singulardtv-contracts

contract SafecontractsTREXToken is StandardToken {

    /*
     *  External contracts
     */
    SafecontractsTREXFund constant safecontractsTREXFund = SafecontractsTREXFund({{SafecontractsTREXFund}});
    SafecontractsTREXCrowdfunding constant safecontractsTREXCrowdfunding = SafecontractsTREXCrowdfunding({{SafecontractsTREXCrowdfunding}});

    /*
     *  Token meta data
     */
    string constant public name = "SafecontractsTREX";
    string constant public symbol = "TREX";
    uint8 constant public decimals = 0;

    /*
     *  Modifiers
     */
    modifier noEther() {
        if (msg.value > 0) {
            throw;
        }
        _
    }

    modifier trexdevshopWaited1Years() {
        // Workshop can only transfer shares after a one years period.
        if (msg.sender == safecontractsTREXFund.trexdevshop() && !safecontractsTREXCrowdfunding.trexdevshopWaited1Years()) {
            throw;
        }
        _
    }

    modifier isCrowdfundingContract () {
        // Only crowdfunding contract is allowed to proceed.
        if (msg.sender != address(safecontractsTREXCrowdfunding)) {
            throw;
        }
        _
    }

    /*
     *  Contract functions
     */
    // @dev Crowdfunding contract issues new tokens for address. Returns success.
    // @param _for Address of receiver.
    // @param tokenCount Number of tokens to issue.
    function issueTokens(address _for, uint tokenCount)
        external
        isCrowdfundingContract
        returns (bool)
    {
        if (tokenCount == 0) {
            return false;
        }
        balances[_for] += tokenCount;
        totalSupply += tokenCount;
        return true;
    }

    // @dev Transfers sender's tokens to a given address. Returns success.
    // @param to Address of token receiver.
    // @param value Number of tokens to transfer.
    function transfer(address to, uint256 value)
        noEther
        trexdevshopWaited1Years
        returns (bool)
    {
        // Both parties withdraw their revenue first
        safecontractsTREXFund.softWithdrawRevenueFor(msg.sender);
        safecontractsTREXFund.softWithdrawRevenueFor(to);
        return super.transfer(to, value);
    }

    // @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    // @param from Address from where tokens are withdrawn.
    // @param to Address to where tokens are sent.
    // @param value Number of tokens to transfer.
    function transferFrom(address from, address to, uint256 value)
        noEther
        trexdevshopWaited1Years
        returns (bool)
    {
        // Both parties withdraw their revenue first
        safecontractsTREXFund.softWithdrawRevenueFor(from);
        safecontractsTREXFund.softWithdrawRevenueFor(to);
        return super.transferFrom(from, to, value);
    }

    // @dev Contract constructor function sets initial token balances.
    function SafecontractsTREXToken() noEther {

        // Set initial share distribution
        balances[safecontractsTREXFund.trexdevshop()] = 650000000; // ~650M (300 + 350) Pool Vault

        // Seed Founders - Advisors - Initial Stakeholders - Seed investors 250M
        balances[0x8394a052eb6c32fb9defcaabc12fcbd8fea0b8a8] = 25000000;
        balances[0xb48dafc23dc5f232f2e7a35a2d2bb1b4ab02c48a] = 25000000;
        balances[0xb56aea97a14a10f536fa4f770b900e12231a018e] = 25000000;
        balances[0xace8a25b438c0d8c16cf578ddeb015fd1f714896] = 25000000;
        balances[0x1fdb174686981ce2f4bb3d911547480403f11fd3] = 25000000;
        balances[0xe68d3f1c9d7325d45706aab95a67f7ac6f373509] = 25000000;
        balances[0x968ea5eed1d40486a7f87991c3299d383a8e85d2] = 25000000;
        balances[0x69a3f2957e65cd5dfdcd9ec16c3951f6a2ac0d45] = 25000000;
        balances[0x3b2652709d13f0dcd7327618c3003a02b0baac05] = 25000000;
        balances[0x88a1ac6e8b6e2e50401c6b269f2180764b7471a9] = 25000000;
        
        totalSupply = 100000000; // 100M
    }
}
