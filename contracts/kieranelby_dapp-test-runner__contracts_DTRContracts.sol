// Some contracts that can be useful when testing.

// Fallback + reject function always throw an exception.

contract DTRRejector {
    function() {
        reject();
    }
    function reject() {
        throw;
    }
}

// A basic wallet with adjustable gas cost for deposits and control over exactly how spends are sent.

contract DTRExpensiveWallet {

    address walletOwner;
    uint256 eatGasAmount;

    event WalletCreated(address by);
    event DepositMade(address from, uint value);
    event WithdrawalMade(address to, uint value);
    event AccessDenied(address from, address versus);

    function DTRExpensiveWallet(uint256 eatGasAmount_) {
        walletOwner = tx.origin;
        eatGasAmount = eatGasAmount_;
        WalletCreated(walletOwner);
    }

    function() {
        uint256 startGas = msg.gas;
        DepositMade(tx.origin, msg.value);
        uint256 junk = 1;
        while (msg.gas + eatGasAmount >= startGas) {
            junk += uint256(sha3(junk));
        }
    }

    function spend(address dst, uint256 val) {
        if (tx.origin != walletOwner) {
          AccessDenied(tx.origin, walletOwner);
          return;
        }
        dst.call.value(val)();
        WithdrawalMade(dst, val);
    }

    function spendWithGas(address dst, uint256 val, uint256 extraGasAmount) {
        if (tx.origin != walletOwner) {
          AccessDenied(tx.origin, walletOwner);
          return;
        }
        dst.call.value(val).gas(extraGasAmount)();
        WithdrawalMade(dst, val);
    }

    function spendWithGasAndData(address dst, uint256 val,uint256 extraGasAmount, bytes callData) {
        if (tx.origin != walletOwner) {
          AccessDenied(tx.origin, walletOwner);
          return;
        }
        dst.call.value(val).gas(extraGasAmount)(callData);
        WithdrawalMade(dst, val);
    }

    function kill() {
        if (tx.origin != walletOwner) {
          AccessDenied(tx.origin, walletOwner);
          return;
        }
        suicide(walletOwner);
    }
}
