pragma solidity ^0.4.0;

// Contract used to answer https://ethereum.stackexchange.com/questions/42207/solidity-deleting-a-struct-from-a-storage-array
contract Lockers {
    struct Locker {
        uint creationTime;
        uint holdTime;
        uint balance;
    }

    mapping (address => Locker[]) lockersByAddress;

    event Withdrawal(address sender, uint balance);

    function store(uint holdTime) external payable {
        Locker memory locker = Locker(now, holdTime, msg.value);
        lockersByAddress[msg.sender].push(locker);
    }

    // Original function
    function withdrawAll() public {
        Locker[] storage lockers = lockersByAddress[msg.sender];
        for (uint i = 0; i < lockers.length; i++) {
            if (lockers[i].creationTime + lockers[i].holdTime < now) {
                msg.sender.transfer(lockers[i].balance);
                Withdrawal(msg.sender, lockers[i].balance);
                delete lockers[i];
            }
        }
    }

    // Modified function that demonstrates how to clear an array
    // Note: withdrawAll is a misnomer and no effort was made to deal with demonstrating how to deal with the edge case of a "locker" not being able to be deleted.
    function withdrawAll2() public {
        Locker[] memory memLockers = lockersByAddress[msg.sender];
        // Avoid any re-entrancy issues
        delete lockersByAddress[msg.sender];
        for (uint i = 0; i < memLockers.length; i++) {
            if (memLockers[i].creationTime + memLockers[i].holdTime < now) {
                msg.sender.transfer(memLockers[i].balance);
                Withdrawal(msg.sender, memLockers[i].balance);
            }
        }
    }

    function getNumLockers(address owner) external view returns(uint) {
        return lockersByAddress[owner].length;
    }

    function getLockerDetails(address owner, uint index) external view returns(uint creationTime, uint holdTime, uint balance) {
        Locker memory locker = lockersByAddress[owner][index];
        creationTime = locker.creationTime;
        holdTime = locker.holdTime;
        balance = locker.balance;
    }
}
