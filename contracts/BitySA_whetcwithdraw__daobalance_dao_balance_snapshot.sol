

// This contract publishes the balances of the DAO at the moment of the hardfork
// After the deployment of the contract the function fill is called many times
// in order to fill the balance of each account.


contract DAOBalanceSnapShot {

    uint constant D160 = 0x10000000000000000000000000000000000000000;

    mapping (address => uint) public balanceOf;

    address public owner;

    function DAOBalanceSnapShot() {
        owner = msg.sender;
    }


    uint public totalSupply;
    uint public totalAccounts;
    bool public sealed;

    // The 160 LSB is the address of the balance
    // The 96 MSB is the balance of that address.
    function fill(uint[] data) {
        if ((msg.sender != owner)||(sealed))
            throw;

        for (uint i=0; i<data.length; i++) {
            address a = address( data[i] & (D160-1) );
            uint amount = data[i] / D160;
            if (balanceOf[a] == 0) {   // In case it's filled two times, it only increments once
                totalAccounts ++;
                balanceOf[a] = amount;
                totalSupply += amount;
            }
        }
    }

    function seal() {
        if ((msg.sender != owner)||(sealed))
            throw;

        sealed= true;
    }
}
