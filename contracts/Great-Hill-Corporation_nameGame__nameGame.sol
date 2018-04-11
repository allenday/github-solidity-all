pragma solidity ^0.4.2;
contract NameGame {

    struct Player {
        string name;
        address addr;
    }

    Player [] public players;
    uint public nPlayers;
    uint public nNeeded;

    uint public current;
    uint public entryFee;
    uint public endTime;
    uint public dur;

    address owner;

    // ---------------------------------------
    function NameGame(uint _n, uint _dur, uint _entryFee) {
        nNeeded = (_n < 2 ? 2 : (_n > 5 ? 5 : _n));
        dur = (_dur < 30 ? 30 : (_dur > 300 ? 300 : _dur));
        entryFee = _entryFee; // this is in wei
        owner = msg.sender;
    }

    // ---------------------------------------
    function joinGame(string _name) payable isNotPlayer() waitingForPlayers() {

        // Note: We want to know that each player has the same
        // amount (i.e. 'entryFee') of ethers in the game.
        if (msg.value != entryFee)
            throw;

        // Must provide a name
        if (bytes(_name).length==0)
            throw;

        players[nPlayers].name = _name;
        players[nPlayers].addr = msg.sender;
        nPlayers++;

        if (nPlayers==1) {
            // First player becomes first current
            current = 0;

        } else if (nPlayers==nNeeded) {
            // Game starts when last player registers
            endTime = now + dur;
        }
    }

    // ---------------------------------------
    function playGame(uint id) isPlayer() readyToPlay() {

        // Note: because function is not 'payable' it can receive no ether

        // Any player may play the game at any time. Current is
        // incremented with each call to this function.
        current = (current+1)%nPlayers;

        // If the function is called after the end of the game, the
        // current 'current' wins the pot and resets the game.
        if (now >= endTime) {
            if (players[current].addr.send(entryFee*nPlayers))
                nPlayers = 0;
        }
    }

    // ---------------------------------------
    function findPlayer(address addr) internal returns (bool) {
        for (uint i=0;i<nPlayers;i++) {
            if (addr == players[i].addr) {
                return true;
            }
        }
        return false;
    }

    // ---------------------------------------
    modifier isPlayer() {
        if (!findPlayer(msg.sender))
            throw;
        _;
    }

    // ---------------------------------------
    modifier isNotPlayer() {
        if (findPlayer(msg.sender))
            throw;
        _;
    }

    // ---------------------------------------
    modifier waitingForPlayers() {
        // Do we have all players?
        if (nPlayers == nNeeded)
            throw;
        _;
    }

    // ---------------------------------------
    modifier readyToPlay() {
        // Do we have enough players?
        if (nPlayers < nNeeded)
            throw;
        _;
    }

    // ---------------------------------------
    modifier isOwner() {
        if (msg.sender != owner)
            throw;
        _;
    }

    function destroyContract() isOwner() waitingForPlayers() {
        // Only owner may kill the contract, but everyone gets their stake back
        //
        // This function tries to return each player's entry fee. Note: one
        // or more of the refunds may fail, in which case the 'current' gets
        // the remaining stake. Players must correct for this externally.
        for (uint i=0;i<nPlayers;i++)
            if (!players[i].addr.send(entryFee))
                throw;

        suicide(players[current].addr);
    }
}
