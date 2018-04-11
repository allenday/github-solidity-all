pragma solidity ^0.4.15;

/*
There are four types of parties.
1. Owner of the contract. Can kill and terminate the contract
2. Splitter address - can set up the two parties for receiving splitter money.
3. party1
4. party2 - they are receipients of the split

If the ether is sent to contract and the party1 and party2 are specified, that the value is split and distributed between party1 and party2,
otherwise it is just stored on the balance of the sender.
*/
contract Splitter {
    // Owner of this contract
    address public owner;

    // the splitters, who decided to participate in splitting
    // mapping (address => SplitterUsers) splitters;
    mapping (address => uint) balances;

    event LogSplitted(uint amount, address splitter, address party1, address party2);
    event LogWithdrawn(uint amount, address beneficiary);

    function Splitter() 
        public {
        owner = msg.sender;
    }

    function getBalance(address account) 
        public 
        constant
        returns (uint) {
        return balances[account];
    }

    function contributeLocal() 
        payable
        hasMoney
        public {
        contribute(msg.sender, msg.sender);
    }

    function contribute(address party1, address party2)
        payable
        hasMoney
        public {
        require(party1 != address(0x0));
        require(party2 != address(0x0));

        // safe distribution in two parts
        uint party1part = msg.value / 2;
        balances[party1] += party1part;
        balances[party2] += msg.value - party1part;
        LogSplitted(msg.value, msg.sender, party1, party2);
    }

    modifier hasMoney() {
        require (msg.value > 0);
        _;
    }

    function withdrawRefund() external {
        uint refund = balances[msg.sender];
        require(refund > 0);
        balances[msg.sender] = 0;
        msg.sender.transfer(refund);
        LogWithdrawn(refund, msg.sender);
    }

    /*
    As mentioned here, this is the default way to handle this function.
    https://ethereum.stackexchange.com/questions/7570/whats-a-fallback-function-when-using-address-send
    */
    function() public {
        revert();
    }
}