pragma solidity ^0.4.2;

import "Stoppable.sol";

contract BSTokenData is Stoppable {
    string public standard = 'BSToken 0.1';
    string public name = 'BSToken';
    string public symbol = 'BST';
    uint8 public decimals = 2;

    /* Only logics contracts can interact with the data */
    mapping (address => bool) public logics;

    struct Account {
        uint256 balance;
        bool frozen;
        mapping (address => uint256) allowance;
        mapping (address => bool) frozenForLogic;
    }

    function BSTokenData(address permissionManagerAddress) {
        super.init(permissionManagerAddress);
    }

    /* Total token supply */
    uint256 public totalSupply;
    /* Accounts or "wallets" */
    mapping (address => Account) public accounts;

    function setBalance(address account, uint256 balance) onlyAdminOrLogics stopInEmergency {
        accounts[account].balance = balance;
    }

    function getBalance(address account) constant returns (uint256) {
        return accounts[account].balance;
    }

    function setTotalSupply(uint256 aTotalSupply) onlyAdminOrLogics stopInEmergency {
        totalSupply = aTotalSupply;
    }

    function getTotalSupply() constant returns (uint256) {
        return totalSupply;
    }

    function setAllowance(address account, address spender, uint256 amount) onlyAdminOrLogics stopInEmergency {
        accounts[account].allowance[spender] = amount;
    }

    function getAllowance(address account, address spender) constant returns (uint256) {
        return accounts[account].allowance[spender];
    }

    function freezeAccount(address account, bool freeze) onlyAdmin {
        accounts[account].frozen = freeze;
    }

    function frozenAccount(address account) constant returns (bool) {
        return accounts[account].frozen;
    }

    function freezeAccountForLogic(address account, bool freeze) onlyAdminOrLogics stopInEmergency {
        accounts[account].frozenForLogic[msg.sender] = freeze;
    }

    function frozenAccountForLogic(address account) constant returns (bool) {
        return accounts[account].frozenForLogic[msg.sender];
    }

    function addLogic(address logic) onlyAdmin {
        logics[logic] = true;
    }

    function removeLogic(address logic) onlyAdmin {
        delete logics[logic];
    }

    modifier onlyAdminOrLogics {
        if (!pm.getNetworkAdmin(pm.getRol(msg.sender)) && !logics[msg.sender]) throw;
        _;
    }
}