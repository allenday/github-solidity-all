pragma solidity ^0.4.18;

import './Ownable.sol';
import './Withdrawable.sol';

contract StateChannel is Ownable, Withdrawable {

    event onChannelOpen(address origin, bytes32 channelId);
    event onChannelClose(address origin, bytes32 channelId);

    struct Channel {
        address sender;
        uint timeout;
        uint senderDeposit;
        uint bankrollDeposit;
        mapping (bytes32 => address) signatures;
    }

    mapping (bytes32 => Channel) channels;
    mapping (address => bytes32) activeIds;

    function openChannel() public payable {
        
        // Checks value and not already open.
        require(msg.value > 0);
        require(msg.sender != owner);
        require(activeIds[msg.sender] == bytes32(0));
        
        // Create a channel
        bytes32 id = keccak256(msg.sender, this, now);
        
        channels[id] = Channel({
            sender: msg.sender,
            timeout: now + 1 days,
            senderDeposit: msg.value,
            bankrollDeposit: 2 ether  // Commit 1.5% of the total bankroll
        });

        // Add it to the lookup table
        activeIds[msg.sender] = id;

        onChannelOpen(msg.sender, id);
    }

    function getChannelId(address from) public constant returns (bytes32) {
        return activeIds[from];
    }

    /**
     * @dev Verify a signed message is valid
     * @param v -> v of signature
     * @param value -> aggreed value by parties
     * @param h Array with 
     * h[0] -> Channel id
     * h[1] -> Hash of (id, value)
     * h[2] -> r of signature
     * h[3] -> s of signature
     */
    function verifyMessage(uint8 v, uint value, bytes32[4] h) public constant returns (bool) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(prefix, h[1]);

        // Check sender is the one who signed the message
        address signer = ecrecover(prefixedHash, v, h[2], h[3]);
        if (signer != channels[h[0]].sender && signer != owner) { 
            return false; 
        }

        // Proof that the value was hashed ok
        bytes32 proof = keccak256(h[0], value);
        if (proof != h[1]) { 
            return false; 
        }

        // bytes32 hash = keccak256(previousHash, currentHash, signer, balance, nonce);
        // bytes32 prefixedHash = keccak256(prefix, hash);

        // address signer = ecrecover(prefixedHash, v, r, s);

        // Check payment promise can be covered by channel
        if (signer == owner && value > channels[h[0]].bankrollDeposit) {
            return false;
        }
        else if (value > channels[h[0]].senderDeposit) {
            return false;
        }

        return true;
    }

    /**
     * @dev Close an open payment channel
     * @param v -> v of signature
     * @param value -> aggreed value by parties
     * @param h Array with 
     * h[0] -> Channel id
     * h[1] -> Hash of (id, value)
     * h[2] -> r of signature
     * h[3] -> s of signature
     */
    function closeChannel(uint8 v, uint value, bytes32[4] h) public {

        Channel storage ch = channels[h[0]];
        
        // Check open channel and participants
        require(ch.senderDeposit > 0);
        require(msg.sender == owner || msg.sender == ch.sender);
        
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(prefix, h[1]);

        // Check signers are the contract owner or the original sender.
        address signer = ecrecover(prefixedHash, v, h[2], h[3]);
        require(signer == ch.sender || signer == owner);

        // Check msg proof is hashed ok
        bytes32 proof = keccak256(h[0], value); 
        require(proof == h[1]);

        if (ch.signatures[proof] == 0) {
            ch.signatures[proof] = signer;

        } else if (ch.signatures[proof] != signer) {
            // Both signatures provided for this hash.

            // Add funds for withdrawal
            pendingWithdrawals[ch.sender] += value;
            
            // Delete channel
            delete channels[h[0]];
            delete activeIds[ch.sender];
            
            onChannelClose(msg.sender, h[0]);
        }
    }

    /**
     * @dev Free sender's deposited funds if called when
     * channel is expired and still open.
     */
    function channelTimeout() public {

        // Check this is an open channel
        require(activeIds[msg.sender] != bytes32(0));

        bytes32 chId = activeIds[msg.sender];
        
        if (channels[chId].timeout < now) {
            
            // Add funds to pendingWithdrawals
            pendingWithdrawals[msg.sender] += channels[chId].senderDeposit;

            // Close the channel
            delete channels[chId];
            delete activeIds[msg.sender];

            onChannelClose(msg.sender, chId);
        }
    }
}