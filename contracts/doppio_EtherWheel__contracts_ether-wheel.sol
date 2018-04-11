contract EtherWheel {
    address public host;
    uint public goal;
    uint public increment;
    mapping(address => uint) public contributions;
    address[] public contributors;

    struct Win {
        address winner;
        uint timestamp;
        uint contribution;
    }

    Win[] public recentWins;
    uint recentWinsCount;

    event Won(address winner, uint timestamp, uint contribution);
    event ChangedContribution(address contributor);

    function EtherWheel(uint _goalInFinney, uint _incrementInFinney, uint8 _recentWinsCount) {
        if(_goalInFinney % _incrementInFinney != 0) throw;

        host = msg.sender;
        goal = _goalInFinney * 1 finney;
        increment = _incrementInFinney * 1 finney;
        recentWinsCount = _recentWinsCount;
    }

    function numContributors() constant returns (uint) {
        return contributors.length;
    }

    function numWinners() constant returns (uint) {
        return recentWins.length;
    }

    function() {
        addToContribution();
    }

    function addToContribution() {
        addValueToContribution(msg.value);
    }

    function addValueToContribution(uint value) internal {
        // First, make sure this is a valid transaction.
        // It needs to be a valid increment and must not overshoot the goal.
        if(value == 0 || value % increment != 0) throw;
        if(this.balance > goal) throw;

        if(contributions[msg.sender] == 0) {
            // This account hasn't contributed any ether yet.
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += value;
        ChangedContribution(msg.sender);

        if(this.balance == goal) {
            // Woohoo, the wheel has been filled! Choose a winner.
            address winner = selectWinner();

            // Send the developer a 1% coffee tip. ;)
            host.send(this.balance / 100);

            // Send the winner the remaining balance on the contract.
            winner.send(this.balance);

            // Make a note that someone won, then start all over!
            recordWin(winner);
            Won(winner, block.timestamp, contributions[winner]);
            reset();
        }
    }

    /* Refunds are allowed at any time before a winner is chosen. */
    function removeFromContribution(uint amount) {
        if(amount == 0 || amount % increment != 0 || msg.value > 0 || amount > contributions[msg.sender]) throw;

        msg.sender.send(amount);
        contributions[msg.sender] -= amount;

        if(contributions[msg.sender] == 0)
        {
            // Cut the contributor from the array, and shift the others over.
            for(uint i = 0; i < contributors.length; ++i) {
                if(contributors[i] == msg.sender) {
                    for(uint j = i; j < contributors.length - 1; ++j) {
                        contributors[j] = contributors[j + 1];
                    }

                    contributors.length--;
                    break;
                }
            }
        }

        ChangedContribution(msg.sender);
    }

    /* A safer way to directly set a contribution. This way, a user can directly set
    their contribution to a specific value, without accidentally adding or removing
    more than once. */
    function setContribution(uint amount) {
        if(amount % increment != 0 || amount == contributions[msg.sender]) throw;

        if(amount > contributions[msg.sender]) {
            // The user is adding value to their contribution.
            var refund = msg.value - (amount - contributions[msg.sender]);
            if(refund > 0) {
                msg.sender.send(refund);
            } else if(refund < 0) {
                throw;
            }

            addValueToContribution(amount - contributions[msg.sender]);
        } else {
            // The user is removing value from their contribution.
            if(msg.value > 0) msg.sender.send(msg.value);
            removeFromContribution(contributions[msg.sender] - amount);
        }
    }

    function selectWinner() internal returns (address winner) {
        /* Note that the block hash of the last block is used to determine
        a pseudo-random winner. Since this could possibly be manipulated
        by miners, wheel goals should remain at 5 ether or less for security.
        There is no incentive to cheat a wheel with less than 5 ether, since
        that would result in a net loss for the cheating miner. */

        uint semirandom = uint(block.blockhash(block.number - 1)) % this.balance;
        for(uint i = 0; i < contributors.length; ++i) {
            if(semirandom < contributions[contributors[i]]) return contributors[i];
            semirandom -= contributions[contributors[i]];
        }
    }

    function recordWin(address winner) internal {
        if(recentWins.length < recentWinsCount) {
            recentWins.length++;
        } else {
            // Already at capacity for the number of winners to remember.
            // Forget the oldest one by shifting each entry 'left'
            for(uint i = 0; i < recentWinsCount - 1; ++i) {
                recentWins[i] = recentWins[i + 1];
            }
        }

        recentWins[recentWins.length - 1] = Win(winner, block.timestamp, contributions[winner]);
    }

    function reset() internal {
        // Return the contributors' funds, since this wheel is ending early.
        for(uint i = 0; i < contributors.length; ++i) {
            delete contributions[contributors[i]];
        }

        delete contributors;
    }

    function changeHost(address newHost) {
        if(msg.sender != host) throw;
        host = newHost;
    }

    /* This should only be needed if a bug is discovered
    in the code and the contract must be destroyed. */
    function destroy() {
        if(msg.sender != host) throw;

        // Refund everyone's contributions.
        for(uint i = 0; i < contributors.length; ++i) {
            contributors[i].send(contributions[contributors[i]]);
        }

        selfdestruct(host);
    }
}
