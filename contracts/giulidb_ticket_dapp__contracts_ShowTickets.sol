pragma solidity ^0.4.0;

/** @title Contract for a show tickets sell  .*/
/** @author Giulia Di Bella .*/

contract ShowTickets{ 

    address public organizer;
    uint public eventTime;
    uint public ticketPrice;
    uint public numTickets;
    uint public ticketSold;
    uint public incomes;
    mapping (address => Ticket) ticketOf;

    struct Ticket{
        uint num;
        bool used;
    }


    // Use of an event to pass along return values from contracts, 
	// to an app's frontend
	event TicketPayed(address _from, uint _amount, uint _id, uint _timestamp);
	event RevenueCollected(address _owner, uint _amount, uint _timestamp);
    event UserRefunded(address _to, uint _amount);
    event Checkin(address user, uint _timestamp);

	
	// This means that if the organizer calls this function, the
	// function is executed and otherwise, an exception is
	// thrown.
	modifier onlyOrganizer {
		if (msg.sender != organizer)
			throw;
		_;
	}


    // This means that if a function is executed only if it's called
    // during a certain time period.
	modifier onlyBefore() { if (now >= eventTime) throw; _; }
    modifier onlyAfter() { if (now <= eventTime) throw; _; }
    
    
    // This modifier requires a certain
    // price being associated with a function call.
    // If the caller sent too much, he or she is
    // refunded, but only after the function body.
    // This was dangerous before Solidity version 0.4.0,
    // where it was possible to skip the part after `_;`.
    modifier costs(uint _amount, address addr) {
        if (msg.value < _amount)
            throw;
        _;
        if (msg.value > _amount)
            // TODO: modify this part such that a user case withdraw by hismself
            // or cancel the operation mantain data consistency
           if(addr.send(msg.value - _amount))
               UserRefunded(addr,msg.value - _amount);
    }


    //This means that the function will be executed
    //only if incomes > 0
    modifier onlyValue() { if (incomes > 0 ) _; else throw; }
    
	
	/// This is the constructor whose code is
    /// run only when the contract is created.	
	function ShowTickets(uint _eventTime, uint _ticketPrice, uint _numTickets) {
		organizer = msg.sender;	
		eventTime = _eventTime;
 		ticketPrice = _ticketPrice;
 		numTickets = _numTickets;
		ticketSold = 0;
        incomes = 0;
	}
    

    /// Returns num of tickets still buyable
    function getLeftTickets() constant public returns(uint){
        return numTickets-ticketSold;
    }


	function buyTicket() onlyBefore costs(ticketPrice,msg.sender) public payable{
	    
       // Sending back the money by simply using
       // organizer.send(tickePrice) is a security risk
       // because it can be prevented by the caller by e.g.
       // raising the call stack to 1023. It is always safer
       // to let the recipient withdraw their money themselves.	    
       
	   if(ticketSold >= numTickets || ticketOf[msg.sender].num != 0){
	       // throw ensures funds will be returned
	       throw;
	   }
	
	    ticketSold++;
	    incomes += ticketPrice;
	    ticketOf[msg.sender] = Ticket({num: ticketSold, used: false});
	    TicketPayed(msg.sender, msg.value,ticketOf[msg.sender].num,now);
	    	
	}


    /// Check-in function 
    /// @dev return false if msg.sender doesn't have ticket
    /// or he has already used it otherwise change the state
    /// of the ticket and return true
    function checkin() public returns(bool){
        if( ticketOf[msg.sender].num == 0 || ticketOf[msg.sender].used == true){
            return false;
        }else{
            ticketOf[msg.sender].used = true;
            Checkin(msg.sender,now);
            return true;
        }         
    }

    /// function get ticket
    function getTicket(address user) public returns(uint,bool){
        return (ticketOf[user].num, ticketOf[user].used);
    }
	
	
    /// withdraw pattern fot the organizer
	function withdraw() onlyOrganizer onlyValue public returns(bool){
	    
        uint amount = incomes;
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        incomes = 0;
        if (msg.sender.send(amount)) {
            RevenueCollected(msg.sender, amount,now);
            return true;
        } else {
            incomes = amount;
            return false;
         }
    }

	
	/// closing contract and send value to its creator
	function destroy()  onlyOrganizer{
	    suicide(organizer);
		
	}
	
}