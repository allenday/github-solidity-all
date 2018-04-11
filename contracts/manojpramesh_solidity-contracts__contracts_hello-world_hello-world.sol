// Summary: Simple contract to set and display a variable
contract HelloWorld
{
    string greeting;

    // Summary: Constructor that accepts value during deployment
    // Input: string
    function HelloWorld(string _greeting) public
    {
        creator = msg.sender;
        greeting = _greeting;
    }

    // Summary: Shows the greeting message.
    // Returns string
    function greet() constant returns (string)          
    {
        return greeting;
    }
    
    // Summary: Set a new value for the contract
    // Input: string
    function setGreeting(string _newgreeting) 
    {
        greeting = _newgreeting;
    }
    
    // Summary: Kill function to destroy the contract
    function kill()
    { 
        if (msg.sender == creator)
            suicide(creator);
    }
}