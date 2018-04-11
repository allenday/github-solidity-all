pragma solidity ^0.4.14;

// 
// Atomic cross-chain trading - Bitcoin Wiki https://en.bitcoin.it/wiki/Atomic_cross-chain_trading
// Hashed Timelock Contracts - Bitcoin Wiki https://en.bitcoin.it/wiki/Hashed_Timelock_Contracts
// Atomic Swaps: How the Lightning Network Extends to Altcoins — Bitcoin Magazine 
// https://bitcoinmagazine.com/articles/atomic-swaps-how-the-lightning-network-extends-to-altcoins-1484157052/
// 

contract User {
    
    function () payable {}
    
    function createPaymentChannel(address _to, uint _timeout, uint _amount) returns (address){
        // (new B).value(10)(); //construct a new B with 10 wei
        PaymentChannel pc =  (new PaymentChannel).value(_amount)(_to,_timeout);
        return pc;
    }
    
     function closeChannel(address channel , uint value){
         PaymentChannel pc = PaymentChannel(channel);
         pc.closeChannel(value);
     }
}

contract TestPayment{
    
    function () payable {}
    
    function testCloseChannel(){
        User alice = new User();
        User bob = new User();
        alice.transfer(2 ether);
        address channelAddress = alice.createPaymentChannel(bob, 60, 1 ether);
        PaymentChannel pc = PaymentChannel(channelAddress);
        require(alice.balance == 1 ether);
        require(pc.balance == 1 ether);
        alice.closeChannel(pc, 0.5 ether);
        // 
        // TODO closeAndRevealSecret()
        // 
        bob.closeChannel(pc, 0.5 ether);
        require(pc.balance == 0 ether);
        require(bob.balance == 0.5 ether);
        require(alice.balance == 1.5 ether);
    }

}

contract PaymentChannel {

    address public channelSender;
    address public channelRecipient;
    uint public startDate;
    uint public channelTimeout;
    mapping (bytes32 => address) signatures;
    // TODO
    bytes32 secret;
    
    function () payable {}

    function PaymentChannel(address to, uint timeout) payable {
        channelRecipient = to;
        channelSender = msg.sender;
        startDate = now;
        channelTimeout = timeout;
    }

    function closeChannel(uint value){
        address signer = msg.sender;
        require(signer == channelSender || signer == channelRecipient);
        bytes32 proof = sha3(this, value);
        
        if (signatures[proof] == 0)
            signatures[proof] = signer;
        else if (signatures[proof] != signer){
            if (!channelRecipient.send(value)) throw;
            selfdestruct(channelSender);
        }
    }

    // library ECRecovery 
    // https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/ECRecovery.sol
    // 
    
    function closeChannelEcrecover(bytes32 h, uint8 v, bytes32 r, bytes32 s, uint value){

        address signer = ecrecover(h, v, r, s);
        require(signer == channelSender || signer == channelRecipient);
        bytes32 proof = sha3(this, value);
        require(proof == h);

        if (signatures[proof] == 0)
            signatures[proof] = signer;
        else if (signatures[proof] != signer){
            if (!channelRecipient.send(value)) throw;
            selfdestruct(channelSender);
        }
    }

    function channelTimeout(){
        require(startDate + channelTimeout > now);
        selfdestruct(channelSender);
    }
}


// TODO

// alice = account[0] 
// bob = account[1]
// TestPayment

// 
// raiden-network/raiden: Raiden Network https://github.com/raiden-network/raiden
// https://github.com/raiden-network/raiden/blob/master/raiden/smart_contracts/NettingChannelLibrary.sol#L98
// 