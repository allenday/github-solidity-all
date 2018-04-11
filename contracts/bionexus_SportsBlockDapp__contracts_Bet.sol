pragma solidity ^0.4.0;

/// @title Bet contract
/// @author The Sports Block Team

import "BettingToken.sol";


/// @notice The Bet contract allows the users to bet
/// on the outcome of a sports event. It creates BettingTokens
/// to keep track of the shares of the jackpot in case of a
/// won bet.
contract Bet
{
    //========================================================================/
    // Access rights
    //========================================================================/

    // store the owner of the contract.
    address public contractOwner;

    // This array contains the addresses of contracts
    // that have the permission to submit game outcomes
    address[] private delegatedEmployees;


    modifier onlyOwner { if(msg.sender == contractOwner) _; }

    modifier onlyDelegatedEmployeesAndOwner
    {
        if(msg.sender == contractOwner) _;
        else
        {
            for(uint i = 0; i < delegatedEmployees.length; i++)
            {
                if(msg.sender == delegatedEmployees[i]) _;
            }
        }
    }

    //========================================================================/
    // Bet info
    //========================================================================/
    BettingToken private teamATokens;
    BettingToken private tieTokens;
    BettingToken private teamBTokens;

    // This string provides the user with information on which team
    // is Team A and wich one is Team B.
    // eg: "Eagles = Team A---Titans = Team B"
    string betDescription;

    //========================================================================/
    // Game outcome & Lock
    //========================================================================/

    // A wins = 1; tie = 0; B wins = 2; default = 3
    uint gameOutcome = 3;

    // When does the game start? After the game starts the makeBet
    // function will be locked
    uint gameStartTime;

    modifier onlyAfterMatchBegins { if(block.timestamp > gameStartTime) _; }
    modifier onlyBeforeMatchBegins { if(block.timestamp < gameStartTime) _; }

    //========================================================================/
    // Contract creation Methods / Setters
    //========================================================================/

    /// @notice create a new Bet contract
    /// @dev Creates the 3 Betting Token contracts automatically
    /// @param owner Address of the contract that owns this one
    /// @param description The betDescription to be set
    /// @param gameStart Timestamp of the beginning of the game
    function Bet(address owner, string description, uint gameStart)
    {
        contractOwner = owner;
        betDescription = description;

        teamATokens = new BettingToken();
        teamBTokens = new BettingToken();
        tieTokens = new BettingToken();

        gameStartTime = gameStart;
    }

    /// @notice adds an employee so he can submit the game results
    /// @param employeeAddress Address of the contract that shall be
    /// able to submit a game result
    function addEmployee(address employeeAddress) onlyOwner()
    {
        delegatedEmployees.push(employeeAddress);
    }

    /// @notice Sets a new owner
    /// @dev We want to create bet contracts via a factory contract.
    /// However, the factory should be able to set the employees but
    /// afterwards the it does not need the owner permissions anymore.
    /// @param newOwner address of the new owner
    function setOwner(address newOwner) onlyOwner()
    {
        contractOwner = newOwner;
    }

    //========================================================================/
    // Methods relevant for betting
    //========================================================================/

    /// @notice places a bet. In order to bet Eth has to be sent when
    /// calling this function.
    /// @param estimatedOutcome what team to bet on. 1 = Team A, 2 = Team B,
    /// 0 = tie
    function makeBet(uint estimatedOutcome) payable onlyBeforeMatchBegins()
    {
        if(msg.value > 0)
        {
            if(estimatedOutcome == 1)
            {
                teamATokens.addTokens(msg.sender, msg.value);
            }
            else if(estimatedOutcome == 0)
            {
                tieTokens.addTokens(msg.sender, msg.value);
            }
            else if(estimatedOutcome == 2)
            {
                teamBTokens.addTokens(msg.sender, msg.value);
            }
            else
            {
                throw;
            }
        }
    }

    //========================================================================/
    // Game Result and Payout
    //========================================================================/

    /// @notice sets the game result
    /// @param result team that has won. A=1, Tie=0, B=2
    function submitGameResults(uint result)
        onlyDelegatedEmployeesAndOwner()
        onlyAfterMatchBegins()
    {
        if(result > 2) throw;
        gameOutcome = result;
    }

    /// @notice destroys the loosing tokens and triggers the payout in
    /// the remaining token contract. Then it destroys that contract too
    /// @dev Eth has to be sent to the winning contract
    function payout() onlyDelegatedEmployeesAndOwner onlyAfterMatchBegins
    {
        if(gameOutcome == 3)
        {
            throw;
        }
        address winningContract;

        if(outcome == 1)
        {
            winningContract = teamATokens;
            teamBTokens.kill();
            tieTokens.kill();
        }
        else if(outcome == 2)
        {
            winningContract = teamBTokens;
            teamATokens.kill();
            tieTokens.kill();
        }
        else if(outcome == 0)
        {
            winningContract = tieTokens;
            teamATokens.kill();
            teamBTokens.kill();
        }
        winningContract.payout();
        winningContract.kill();

    }

    /// @notice Executes submitGameResults() and payout(). Suicides afterwards
    /// @param result result for submitGameResults()
    function submitGameResultAndTriggerPayout(uint result)
        onlyDelegatedEmployeesAndOwner()
        onlyAfterMatchBegins()
        {
            submitGameResults(result);
            payout();
            selfdestruct(contractOwner);
        }

}
