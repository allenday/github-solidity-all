pragma solidity ^0.4.2;

contract RaffleInternetBook {
    //////////////////////////////////////////////////////////
    //   Contract Contsruction
    //////////////////////////////////////////////////////////
    string public prizeName;
    uint public numPrizes;
    event raffleInitiated(string _prizeName, uint _numprizes);

    function RaffleInternetBook(string _prizeName, uint _numPrizes) {
        prizeName = _prizeName;
        numPrizes = _numPrizes;
        raffleInitiated(prizeName, numPrizes);
    }
    
    //////////////////////////////////////////////////////////
    //   Contract Stage Section
    //////////////////////////////////////////////////////////
    enum Stages {
        Registration,
        Disbursement,
        Finished
    }
    // This is the current contract stage
    Stages public stage = Stages.Registration;
    
    // For checking if function call is appropriate to current stage
    modifier atStage(Stages _stage) {
        if(stage != _stage) {
            throw;
        }
        _;
    }
    // For moving through contract stages
    function nextStage() internal {
        stage = Stages(uint(stage) + 1);
        stageChanged(uint(stage));
    }
    // Move stage to close registration
    function closeRegistration() public atStage(Stages.Registration) {
        nextStage();
    }

    //////////////////////////////////////////////////////////
    //   Contract variable declaration section
    //////////////////////////////////////////////////////////
    
    // Declare Events
    event ticketRegistered(string _username, address _address, uint _ticketId, uint _numTicketsTotal, uint _numUsersTotal);
    event stageChanged(uint _stage);
    event prizeWon(uint _ticketId, string _prize);
    
    // Declare raffle property variables
    uint nonce = 0;
    uint numTicketsTotal = 0;
    uint numUsersTotal = 0;
    
    // Create the ticket object
    struct Ticket{
        address addr;
        string prize;
        uint ticketId;
    }
    
    // Map Ticket ID to Ticket object
    mapping(uint => Ticket) public tickets;
    uint[] public ticketPool;
    
    mapping(address => bool) public userHasWon;
    

    //////////////////////////////////////////////////////////
    //   Contract Functionality Section
    //////////////////////////////////////////////////////////
    function generateNewTicket(address userAddress) internal returns (uint) {
        uint ticketID = numTicketsTotal;
        tickets[ticketID].addr = userAddress;
        tickets[ticketID].ticketId = ticketID;
        ticketPool.push(ticketID);
        numTicketsTotal += 1;
        return ticketID;
    }

    function registerTicketsToUser (string username, address userAddress, uint numTickets) atStage(Stages.Registration) {
        if (numTickets != 0) {
            numUsersTotal += 1;
            for (uint i = 0; i < numTickets; i++ ) {
                uint ticketId = generateNewTicket(userAddress);
                ticketRegistered(username, userAddress, tickets[ticketId].ticketId, numTicketsTotal, numUsersTotal);
            }
        }
    }
    
    function remove(uint index)  internal returns(uint[]) {
        if (index >= ticketPool.length) return;

        for (uint i = index; i<ticketPool.length-1; i++){
            ticketPool[i] = ticketPool[i+1];
        }
        delete ticketPool[ticketPool.length-1];
        ticketPool.length--;
        return ticketPool;
    }
    
    function generate_random(uint maxNum, string salt) internal returns (uint) {
        
        uint random_number = ( 
            uint(block.blockhash(block.number-1)) +
            uint(sha3(sha3(salt))) + 
            uint(sha3(nonce))
        )%maxNum;
        nonce++;
        return random_number;
    }
    
    function randomChoiceFromticketPool() internal returns(uint choice) {
        uint rand_index = generate_random(ticketPool.length, 'salting');
        uint winningIndex = ticketPool[rand_index];
        remove(rand_index);
        return winningIndex;
    }
    
    // Meat of the contract here
    function distributePrizes() public atStage(Stages.Disbursement) {
        if (numPrizes > numUsersTotal) {
            numPrizes = numUsersTotal;
        }
        for (uint i = 0; i < numPrizes; i++) {
            uint winner = randomChoiceFromticketPool();
            address winningAddress = tickets[winner].addr;
            if (! userHasWon[winningAddress]) {
                tickets[winner].prize = prizeName;
                prizeWon(tickets[winner].ticketId, tickets[winner].prize);
                userHasWon[winningAddress] = true;
            }
        }
        nextStage();
    }
    
    //////////////////////////////////////////////////////////
    //   Getter functions
    //////////////////////////////////////////////////////////
    function getNumUsers() public constant returns (uint) {
        return numUsersTotal;
    } 
    
    function getNumTickets() public constant returns (uint) {
        return numTicketsTotal;
    }

    function getStage() constant public returns (uint d) {
        d = uint256(stage);
    }
}