contract Bank {

    // We want an owner that is allowed to selfdestruct.
    address owner;

    mapping (address => uint) balances;

    // Constructor
    function Bank(){
        owner = msg.sender;
    }

    // This will take the value of the transaction and add to the senders account.
    function deposit() {
        balances[msg.sender] += msg.value;
    }

    // Attempt to withdraw the given 'amount' of Ether from the account.
    function withdraw(uint amount) {
        // Skip if someone tries to withdraw 0 or if they don't have enough Ether to make the withdrawal.
        if (balances[msg.sender] < amount || amount == 0)
            return;
        balances[msg.sender] -= amount;
        msg.sender.send(amount);
    }

    function remove() {
        if (msg.sender == owner){
            selfdestruct(owner);
        }
    }

}