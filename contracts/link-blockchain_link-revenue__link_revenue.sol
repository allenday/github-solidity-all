pragma solidity ^0.4.10;


/**
 * @title LinkRevenue
 * @author Jonathan Brown <jbrown@link-blockchain.org>
 */
contract LinkRevenue {

    uint public startTime;
    uint public withdrawn;
    address public owner;

    /**
     * @dev The owner of this contract has chanaged.
     * @param oldOwner Old owner of this contract.
     * @param newOwner New Owner of this contract.
     */
    event ChangeOwner(address oldOwner, address newOwner);

    /**
     * @dev A withdrawal has occured.
     * @param recipient Recipient of the withdrawal.
     * @param amount Amount of Link withdrawn.
     */
    event Withdraw(address recipient, uint amount);

    /**
     * @dev Throws if the sender is not the owner of the contract.
     */
    modifier isOwner() {
        require (msg.sender == owner);
        _;
    }

    /**
     * @dev Constructor.
     */
    function LinkRevenue() {
        startTime = block.timestamp;
        owner = msg.sender;
    }

    /**
     * @dev Changes the owner of the contract.
     * @param newOwner The new owner of the contract.
     */
    function changeOwner(address newOwner) external isOwner {
        owner = newOwner;
        ChangeOwner(msg.sender, newOwner);
    }

    /**
     * @dev Withdraws any available funds to the owner.
     */
    function withdraw() external isOwner {
        uint released = getReleased();
        uint amount = released - withdrawn;
        withdrawn = released;
        owner.transfer(amount);
        Withdraw(owner, amount);
    }

    /**
     * @dev Determines how much Link has been released in total so far.
     */
    function getReleased() constant returns (uint released) {
        uint dailyAmount = 50000 ether;
        int elapsed = int((block.timestamp - startTime) / 1 days);

        while ((dailyAmount != 0) && (elapsed > 0)) {
            released += uint((elapsed < 200) ? elapsed : 200) * dailyAmount;
            dailyAmount -= 5000 ether;
            elapsed -= 200;
        }
    }

}
