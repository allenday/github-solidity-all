
contract Lottery 
{
    address admin;
    uint fee;
    uint end;
    uint redemption;
    uint constant betAmount = 100;
    uint totalPot;
    uint whiteballs;
    uint powerball;

    struct Bet 
    {
        uint amount;
        uint whiteballs;
        uint powerball;
    }

    // mapping of ticket number to player.
    mapping(address => Bet[]) lotto;
    // list of winners.
    address[] winners;

    modifier AdminOnly() 
    {
        if (msg.sender == admin) 
        {
            _   // continue
        }
    }

    modifier InPlay() 
    {
        if(msg.sender != admin && block.timestamp < end) 
        {
            _   // continue
        }
    }
    
    modifier EndPlay() 
    {
        if(msg.sender != admin && 
            block.timestamp >= end &&
            block.timestamp < redemption) 
        {
            _   // continue
        }
    }

    event Logging(string output, address caller);
    
    // constructor
    function Lottery(uint feePercent, uint unixEndTime, uint daysToRedeem) 
    {
        if(admin != address(0)) 
        {
            throw;
        }
        
        fee = feePercent;
        end = unixEndTime;
        redemption = daysToRedeem * 86400; // unix seconds in a day.
        totalPot = 0;
        admin = msg.sender;
    }
    
    function DrawWinning(uint _whiteballs, uint _powerball) AdminOnly EndPlay 
    {
        // prevent administrator from calling this function more than once.
        if(whiteballs != 0 && powerball != 0)
        {
            Logging("This function has already called. It can only be called once.", msg.sender);
            return;
        }

        // pay administrative fee.
        uint _tax = totalPot * fee;
        if(!admin.send(_tax))
        {
            throw;
        }

        // reduce pot size by administrative fee.
        totalPot -= _tax;

        whiteballs = _whiteballs;
        powerball = _powerball;
    }

    function DisburseEarnings() AdminOnly EndPlay 
    {
        // split pot amongst winners. 
        uint _earnings = totalPot / winners.length;
        
        // disburse winnings.
        for(uint i = 0; i < winners.length; i++) 
        {
            if(!winners[i].send(_earnings)) 
            {
                throw;
            }
        }

        // pay admin administrative fee and terminate lottery contract [reference: #2 reported by zbobbert]
        selfdestruct(admin);
    }    

    // allow the player to collect their winnings [reference: #1 reported by zbobbert]
    function CollectEarning() EndPlay
    {
        // calculate winner's earnings.
        uint _earnings = totalPot / winners.length;
        
        // disburse winnings.
        for(uint i = 0; i < winners.length; i++) 
        {
            if(winners[i] == msg.sender)
            {
                if(!winners[i].send(_earnings)) 
                {
                    throw;
                }
                // remove player from winners list since they have been paid.
                delete winners[i];
                // reduce the size of the pot correspondingly.
		        totalPot -= _earnings;
		        break;
            }
        }
    }
    
    function Play(uint _whiteballs, uint _powerball) InPlay 
    {
    	// check betting amount is correct.
    	if(msg.value != betAmount) 
        {
            Logging("bet amount is incorrect", msg.sender);
    		return;
    	}

        // check if user hasn't already played the same number. 
        Bet[] _playerbets = lotto[msg.sender];
        // prevent players from playing the same number multiple times.
        for(uint i = 0; i < _playerbets.length; i++) 
        {
            if(_playerbets[i].whiteballs == _whiteballs) 
            {
                Logging("betting on the same number not permitted", msg.sender);
                return;
            }
        }

        // add bet to pot.
        totalPot += msg.value;
        
        // track player's bet.
        lotto[msg.sender].push(Bet({
        	amount: msg.value,
        	whiteballs: _whiteballs,
        	powerball: _powerball
        	}));
    }
    
    function Check() EndPlay 
    {
        if(whiteballs == 0 && powerball == 0) 
        {
            Logging("please check again. Winning balls have not been drawn yet.", msg.sender);
            return;
        }
        
        var _bets = lotto[msg.sender];
        
        for(uint i = 0; i < _bets.length; i++) 
        {
            if( _bets[i].whiteballs == whiteballs && 
                _bets[i].powerball == powerball) 
            {
                Logging("You're a PowerBall winner!", msg.sender);
                // track winners.
                winners.push(msg.sender);
            }
        }
    }
    
    function () 
    {
        throw;
    }
}