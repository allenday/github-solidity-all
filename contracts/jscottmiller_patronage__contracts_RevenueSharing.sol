import {Exchange, Custodian} from './Exchange.sol';
import {PatronageRegistry} from './PatronageRegistry.sol';

contract RevenueSharing is Custodian {
    struct Shareholder {
        bool active;
        int16 nextHolder;
        uint32 shareCount;
        address owner;
    }

    int16 head = -1;
    uint16 constant maximumShareholders = 10000;
    uint32 constant totalShares = 10000000;
    address owner;
    mapping (address => uint32) reservedShares;
    mapping (address => uint) dividendBalances;
    Shareholder[10000] shareholders;
    Exchange exchange;
    PatronageRegistry registry;

    function RevenueSharingContract() {
        owner = msg.sender;
        exchange = new Exchange();
        registry = new PatronageRegistry(address(this));
        shareholders[0] = Shareholder(true, -1, totalShares, owner);
        head = 0;
    }

    function withdrawal() returns (bool success) {
        uint amount = dividendBalances[msg.sender];
        if (amount == 0) {
            throw;
        }
        dividendBalances[msg.sender] = 0;
        if (!msg.sender.send(amount)) {
            throw
        }
    }

    function allocateDividends() {
        uint balance = this.balance;
        int16 currentHolder = head;
        while (currentHolder != -1) {
            uint index = uint(currentHolder);
            address shareholder = shareholders[index].owner;
            uint32 shareCount = shareholders[index].shareCount;
            uint allocation = balance * shareCount / totalShares;
            dividendBalances[shareholder] += allocation;
        }
    }

    function transfer(address oldOwner, address newOwner, uint shares) {
        if (msg.sender != oldOwner && msg.sender != address(exchange) {
            throw;
        }
        var (ownerIndex, ownerParentIndex) = findShareholder(oldOwner);
        if (ownerIndex == -1) {
            throw;
        }
        uint32 ownerBalance = shareholders[uint(ownerIndex)].shareCount - reservedShares[oldOwner];
        if (ownerBalance < shares) {
            throw;
        }
        if (ownerBalance == shares) {
            int16 nextIndex = shareholders[uint(ownerIndex)].nextHolder;
            if (ownerParentIndex != -1) {
                shareholders[uint(ownerParentIndex)].nextHolder = nextIndex;
            } else {
                head = nextIndex;
            }
            shareholders[uint(ownerIndex)].active = false;
        }
        var (newIndex, newParent) = findShareholder(newOwner);
        if (newIndex != -1) {
            shareholders[uint(newIndex)].shareCount += uint32(shares);
        } else {
            int16 targetIndex = allocateShareholder(newOwner, uint32(shares));
            if (newParent != -1) {
                shareholders[uint(newParent)].nextHolder = targetIndex;
            } else {
                head = targetIndex;
            }
        }
    }

    function reserve(address owner, uint shares) {
        if (msg.sender != address(exchange)) {
            throw;
        }
        var (index, _) = findShareholder(owner);
        if (index == -1) {
            throw;
        }
        uint32 ownedShares = shareholders[uint(index)].shareCount;
        uint32 availableShares = ownedShares - reservedShares[owner];
        if (availableShares < shares) {
            throw;
        }
        reservedShares[owner] = uint32(shares);
    }

    function unreserve(address owner, uint shares) {
        if (msg.sender != address(exchange)) {
            throw;
        }
        var (index, _) = findShareholder(owner);
        if (index == -1) {
            throw;
        }
        uint32 reserved = reservedShares[owner];
        if (reserved < shares) {
            throw;
        }
        reservedShares[owner] -= uint32(shares);
    }

    function findShareholder(address owner) private returns (int16 index, int16 parent) {
        int16 previous = -1;
        int16 current = head;
        while (current != -1) {
            if (shareholders[uint(current)].owner == owner) {
                return (current, previous);
            }
            previous = current;
            current = shareholders[uint(current)].nextHolder;
        }
        return (-1, previous);
    }

    function allocateShareholder(address owner, uint32 shares) private returns (int16 index) {
        for (uint i = 0; i < maximumShareholders; i++) {
            if (!shareholders[i].active) {
                shareholders[i] = Shareholder(true, -1, shares, owner);
                return int16(i);
            }
        }
        throw;
    }

    function () {
    }
}
