/*
 * Procedure for Making Micropayments
 *
 * 1. Someone constructs the payment channel with two addresses.
 * 2. Participant one signs an amount to pay out and sends it to participant zero.
 * 3. Participant zero sends that amount to the contract.
 * 4. Participant one then sends however much they need to send to the contract.
 * 5. Micropayments are made by signing transactions with an amount to pay to participant zero
 *    and an ever-increasing nonce.
 * 6. Once participants wish to cash out, they will send a transaction with the signed values.
 * 7. After the first "cash out" transaction has been sent, participants may contest the cash out
 *    by sending a signed transaction with a greater nonce.
 * 8. After the cashout period has elapsed, someone can send a final command to cash out the contract.
 */

contract PaymentChannel {
    event ContractUpdate(address sender, uint nonce, uint paymentToAddressZero, uint paymentToAddressOne);
    event ContractPaid(address sender, uint paymentToAddressZero, uint paymentToAddressOne);

    address[2] participants;
    uint timeout;
    uint payToZero = 0;
    uint nonce = 0;
    uint lastTimestamp = 0;

    function PaymentChannel(address address0, address address1, uint _timeout) {
        participants[0] = address0;
        participants[1] = address1;
        timeout = _timeout;
    }

    function endContract(uint _payToZero, uint _nonce, uint8 v, bytes32 r, bytes32 s) returns (bool) {
        if (nonce >= _nonce || payToZero < 0 || this.balance - payToZero < 0) {
            return false;
        }

        if ((msg.sender == participants[0] && ecrecover(getHash(_payToZero, _nonce), v, r, s) == participants[1])
                || (msg.sender == participants[1] && ecrecover(getHash(_payToZero, _nonce), v, r, s) == participants[0])) {
            ContractUpdate(msg.sender, _nonce, payToZero, this.balance - payToZero);
            payToZero = _payToZero;
            nonce = _nonce;
            lastTimestamp = now;
            return true;
        }
        else {
            return false;
        }
    }

    function finaliseContract() returns (bool) {
        if (lastTimestamp > 0 && lastTimestamp + timeout > now) {
            ContractPaid(msg.sender, payToZero, this.balance - payToZero);
            participants[0].send(payToZero);
            selfdestruct(participants[1]);
            return true;
        }
        else {
            return false;
        }
    }

    function getHash(uint payToZero, uint nonce) constant returns (bytes32) {
        return sha3(payToZero, nonce);
    }
}
