// Hudson Jameson (Souptacular) Created December 2015

contract owned
{
    function owned()
    {
        owner = msg.sender;
    }

    modifier onlyowner()
	{
	    if (msg.sender == owner)
	        _
	}

    address owner;
}

contract Marriage is owned
{
    // Store marriage data
    bytes32 public partner1;
    bytes32 public partner2;
    uint256 public marriageDate;
    bytes32 public marriageStatus;
    bytes public marriageProofDoc;
    
    // Create initial marriage contract
    function createMarriage(bytes32 partner1Entry, bytes32 partner2Entry, uint256 marriageDateEntry, bytes32 status, bytes description)
    {
        partner1 = partner1Entry;
        partner2 = partner2Entry;
        marriageDate = marriageDateEntry;
        setStatus(marriageStatus);
        bytes28 name = "Marriage Contract Creation";
        
        MajorEvent(block.timestamp, marriageDate, name, description);
    }
    
    // Set the marriage status if it changes
    function setStatus(bytes32 status)
    {
        marriageStatus = status;
    }
    
    // Upload documentation for proof of marrage like a marriage certificate
    function marriageProof(bytes IPFSHash)
    {
        marriageProofDoc = IPFSHash;
    }
    
    // Log major life events
    function majorEvent(bytes32 name, bytes description, uint256 eventTimeStamp)
    {
        MajorEvent(block.timestamp, eventTimeStamp, name, description);
    }
    
   	// Withdraw my vacation fund
    function returnFunds()
	{
		uint256 balance = address(this).balance;
		address(owner).send(balance);
    }
    
    event MajorEvent(uint256 logTimeStamp, uint256 eventTimeStamp, bytes32 indexed name, bytes indexed description);
}