contract Game {
    uint public totalPlayers;
    address public contractOwner;
    
    mapping(uint => address) public Players;
    mapping(address => bool) public isPlayer;
    mapping(address => uint256) public minedetherByAddress;
    mapping(address => Reactor) public reactorByAddress;
    mapping(address => CrystalMine) public crystalmineByAddress;

    
    struct Reactor {
        uint level;
        uint availableMineUpgrades;
        uint256 nextLVLrequirement;
    }
    
    struct CrystalMine {
        uint level;
        uint256 output;
        uint256 nextLVLrequirement;
        uint lastCollectDate;
        uint nextCollectDate;
    }
    
    function upgradeReactor() {
        if(isPlayer[msg.sender]) {
            uint256 x = reactorByAddress[msg.sender].nextLVLrequirement;
            if(msg.value >= x) {
                msg.sender.send(msg.value - x);
                contractOwner.send((x * 10) / 100);
                reactorByAddress[msg.sender].level += 1;
                reactorByAddress[msg.sender].availableMineUpgrades *= 2;
                reactorByAddress[msg.sender].nextLVLrequirement *= 2;
            } else if(msg.value < x) {
                throw;
            }
        } else {
            throw;
        }
    }
    
    function upgradeCrystalMine() {
        if(isPlayer[msg.sender]) {
            uint x = crystalmineByAddress[msg.sender].nextLVLrequirement;
            uint y = reactorByAddress[msg.sender].availableMineUpgrades;
            uint z = crystalmineByAddress[msg.sender].level + 1;
            if(z <= y) {
                if(msg.value >= x) {
                    msg.sender.send(msg.value - x);
                    contractOwner.send((x * 10) / 100);
                    crystalmineByAddress[msg.sender].level += 1;
                    crystalmineByAddress[msg.sender].output += 50000000000 wei;
                    crystalmineByAddress[msg.sender].nextLVLrequirement *= 2;
                } else if(msg.value < x) {
                 throw;
                }
            } else {
                throw;
            }
        } else {
            throw;
        }
    }
    
    function Mine() {
        if(isPlayer[msg.sender]) {
            if(msg.value > 0) throw;
            uint lastCollect = crystalmineByAddress[msg.sender].lastCollectDate;
            uint nextCollect = crystalmineByAddress[msg.sender].nextCollectDate;
            if(now >= nextCollect) {
                minedetherByAddress[msg.sender] += crystalmineByAddress[msg.sender].output;
                crystalmineByAddress[msg.sender].lastCollectDate = now;
                crystalmineByAddress[msg.sender].nextCollectDate = now + 8 hours;
            } else {
                throw;
            }
        } else {
            throw;
        }
    }
    
    function Collect(){
        if(msg.value > 0) throw;
        if(isPlayer[msg.sender]) {
            if(minedetherByAddress[msg.sender] > 0) {
                msg.sender.send(minedetherByAddress[msg.sender]);
            } else {
                throw;
            }
        }
    }
    
    function newPlayer() {
        if(msg.value >= 50 finney) {
            contractOwner.send(5 finney);
            msg.sender.send(msg.value - 50 finney);
            isPlayer[msg.sender] = true;
            Players[totalPlayers++] = msg.sender;
            reactorByAddress[msg.sender] = Reactor({
                level: 1,
                availableMineUpgrades: 5,
                nextLVLrequirement: 2000000000000 wei
            });
            crystalmineByAddress[msg.sender] = CrystalMine({
                level: 1,
                output: 800000000000 wei,
                nextLVLrequirement: 1000000000000 wei,
                lastCollectDate: now,
                nextCollectDate: now + 8 hours
            });
        } else if(msg.value < 50 finney) {
            throw;
        }
    }
    
    function Game() {
        contractOwner = msg.sender;
    }
    
    function () {
        throw;
    }
}
