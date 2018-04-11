// https://docs.google.com/presentation/d/1vBViqLBR0bD3hOY_SgQUwMFj9Nq8eCgggCmlx6_Tz04/edit#slide=id.g9c64d1696_0_20

// https://gist.github.com/kobigurk/19265d90e835d033680a

contract token {
    mapping (address => uint) balances;

    // Initializes contract with 10 000 tokens to the creator of the contract
    function token() {
        balances[msg.sender] = 10000;
    }

    // Very simple trade function  
    function sendToken(address receiver, uint amount) returns(bool sufficient) {
        if (balances[msg.sender] < amount) return false;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        return true;
    }

    // Check balances of any account
    function getBalance(address account) returns(uint balance) {
        return balances[account];
    }
}
 