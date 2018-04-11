/*
*
*
*/
pragma solidity ^0.4.0;



contract ChecksumDatabase {
    
    struct ChecksumEntry {
    	string version;
    	string checksum;
    	uint date;
    }

	string public name;
	string public url;
	string public description;
	address public owner;
	uint public count;
	mapping (uint=>ChecksumEntry)public entries;
	// Start of user code ChecksumDatabase.attributes
	// End of user code
	
	modifier onlyOwner
	{
	    if(msg.sender!=owner) throw;
	    _;
	}
	
	
	event VersionChecksum(string version,string checksum,uint date,uint id);
	
	/*
	* A Constructor.
	* 
	* _name -
	* _url -
	* _description -
	*/
	function ChecksumDatabase(string _name,string _url,string _description) public   {
		//Start of user code ChecksumDatabase.constructor.ChecksumDatabase_string_string_string
		owner = msg.sender;
		name= _name;
		url = _url;
		description = _description;
		//End of user code
	}
	
	
	/*
	* Add an entry to the database.
	* 
	* _version -The version the checksum belongs to.
	* _checksum -The checksum of the version.
	*/
	function addEntry(string _version,string _checksum) public  onlyOwner  {
		//Start of user code ChecksumDatabase.function.addEntry_string_string
		entries[count].version = _version;
		entries[count].checksum = _checksum;
		entries[count].date = now;
		VersionChecksum(_version,_checksum,now,count);
		count++;
		//End of user code
	}
	
	
	
	function changeOwner(address newOwner) public  onlyOwner  {
		//Start of user code ChecksumDatabase.function.changeOwner_address
		owner = newOwner;
		//End of user code
	}
	
	
	
	function getEntry(uint id) public   constant returns (string _version,string _checksum,uint _date) {
		//Start of user code ChecksumDatabase.function.getEntry_uint
		_version = entries[id].version;
		_checksum = entries[id].checksum;
		_date = entries[id].date;
		return;
		//End of user code
	}
	
	function() {
		// Start of user code ChecksumDatabase default.function
		throw;
		// End of user code
	}
	// Start of user code ChecksumDatabase.operations
	//TODO: implement
	// End of user code
}

