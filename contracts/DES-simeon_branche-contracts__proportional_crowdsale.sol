pragma solidity ^0.4.4;

contract BrancheProportionalCrowdsale {
    address public owner;
    uint public deadline;
    uint public adminRefundDate;
    uint public target;
    uint public raised;
    bool funded;
    mapping(address => uint) public balances;
    mapping(address => bool) public refunded;

    event TargetHit(uint amountRaised);
    event CrowdsaleClosed(uint amountRaised);
    event FundTransfer(address backer, uint amount);
    event Refunded(address backer, uint amount);
    event AdminRefund(address depositAddr, address recipientAddr);

    function BrancheProportionalCrowdsale(uint _durationInMinutes, uint _targetETH) {
        owner = msg.sender;
        deadline = now + _durationInMinutes * 1 minutes;
        adminRefundDate = deadline + 14400 * 1 minutes; //10 days
        target = _targetETH * 1 ether;
    }

    function _deposit() private {
        if (now >= deadline) throw;
        balances[msg.sender] += msg.value;
        raised += msg.value;
        FundTransfer(msg.sender, msg.value);
    }

    function deposit() payable {
        _deposit();
    }

    function() payable {
        _deposit();
    }

    function safebalance(uint bal) returns (uint) {
        if (bal > this.balance) {
            return this.balance;
        } else {
            return bal;
        }
    }

    function refund(address recipient) private {
        if (refunded[recipient]) throw;
        uint deposit = balances[recipient];
        uint keep = (deposit * target) / raised;
        uint refund = safebalance(deposit - keep);
        Refunded(msg.sender, refund);
        refunded[recipient] = true;
        if (!recipient.call.value(refund)()) throw;
    }

    function adminRefund(address deposit_addr, address recipient) {
        if (msg.sender != owner) throw;
        if (now <= deadline) throw;
        if (balances[recipient]!=0) throw;
        balances[recipient] = balances[deposit_addr];
        refunded[deposit_addr] = true;
        AdminRefund(deposit_addr, recipient);
        refund(recipient);
    }

    function withdrawRefund() {
        if (now <= deadline) throw;
        if (raised <= target) throw;
        refund(msg.sender);
    }

    function fundOwner() {
        if (now <= deadline) throw;
        if (funded) throw;
        funded = true;
        CrowdsaleClosed(raised);
        if (raised < target) {
            if (!owner.call.value(safebalance(raised))()) throw;
        } else {
            TargetHit(raised);
            if (!owner.call.value(safebalance(target))()) throw;
        }
    }
}
