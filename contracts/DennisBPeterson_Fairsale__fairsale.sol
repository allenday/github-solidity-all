pragma solidity 0.4.2;

contract Fairsale {
    address public owner;
    uint public finalblock;
    uint public target;
    uint public raised;
    bool funded;
    mapping(address => uint) public balances;
    mapping(address => bool) public refunded;

    function Fairsale(uint _blocks, uint _target) {
        owner = msg.sender;
        finalblock = block.number + _blocks;
        target = _target;
    }

    function _deposit() private {
        if (block.number > finalblock) throw;
        balances[msg.sender] += msg.value;
        raised += msg.value;
    }

    function deposit() payable {
        _deposit();
    }

    function() payable {
        _deposit();
    }

    function withdrawRefund() {
        if (block.number <= finalblock) throw;
        if (raised <= target) throw;
        if (refunded[msg.sender]) throw;

        uint deposit = balances[msg.sender];
        uint keep = (deposit * target) / raised;
        uint refund = deposit - keep;
        if (refund > this.balance) refund = this.balance;

        refunded[msg.sender] = true;
        if (!msg.sender.call.value(refund)()) throw;
    }

    function fundOwner() {
        if (block.number <= finalblock) throw;
        if (funded) throw;
        funded = true;
        if (raised < target) {
            if (raised > this.balance) raised = this.balance;
            if (!owner.call.value(raised)()) throw;
        } else {
            if (target > this.balance) target = this.balance;
            if (!owner.call.value(target)()) throw;
        }
    }
}
