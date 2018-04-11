contract SmallProject {
    address owner;
    address account1;
    address account2;
    uint256 amount;

    mapping(address=>Account) public accounts;

    struct Account {
        uint lastUpdate;
        uint256 accBalance;
    }

    function SmallProject() {
        owner = msg.sender;
    }

    function Accounts(address _account1, address _account2) {
        account1 = _account1;
        account2 = _account2;
    }

    function SplitAmount(address _account1, address _account2, uint256 _amount) returns (uint256) {
        amount = _amount / 2;

        accounts[_account1].lastUpdate = now;
        accounts[_account1].accBalance += amount;
        accounts[_account2].lastUpdate = now;
        accounts[_account2].accBalance += amount;

        return amount;
    }

    function SendAmount(address _account1, address _account2, uint256 _amount) returns (bool) {
        if (_account1.send(_amount))
            if (_account2.send(_amount))
                return true;
            else throw;
        else throw;
    }

    function GetBalance(address _address) returns (uint256) {
        //return accounts[_address].accBalance;
        return _address.balance;
    }

    function KillContract() {
        if (msg.sender == owner) {
            suicide(owner);
        }
    }
}