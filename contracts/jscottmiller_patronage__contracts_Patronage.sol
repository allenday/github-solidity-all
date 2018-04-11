contract Patronage {
    address public payoutAddress;
    address public shareholders;
    string public username;

    function Patronage(string _username, address _payoutAddress, address _shareholders) {
        username = _username;
        payoutAddress = _payoutAddress;
        shareholders = _shareholders;
    } 

    function withdrawal() {
        uint currentBalance = this.balance;
        if (currentBalance <= 0) {
            throw;
        }
        uint userAmount = (currentBalance * 9) / 10;
        uint shareholderAmount = currentBalance - userAmount;
        if (!payoutAddress.send(userAmount)) {
            throw;
        }
        if (!shareholders.send(shareholderAmount)) {
            throw;
        }
    }

    function updatePayoutAddress(address newAddress) {
        if (payoutAddress != msg.sender) {
            throw;
        }
        payoutAddress = newAddress;
    }

    function () {
    }
}
