/*
*
*(c) 2016 KUEKeN
* Urs Zeidler
*
*/
pragma solidity ^0.4.1;
/*
* Collection of basic functionalities.
*/


contract Owned {

	address public owner;
	// Start of user code Owned.attributes
	//TODO: implement
	// End of user code
	
	modifier onlyOwner
	{
	    if (msg.sender != owner) return;
	    _;
	}
	//
	// constructor for Owned
	//
	function Owned(){
	    owner = msg.sender;
	    //Start of user code Constructor.Owned
		//TODO: implement
		// deprecated use a normal function to model the constructor
	    //End of user code
	}
	
	
	function getOwner() public  onlyOwner returns (address result) {
		 result = owner;
		
		//Start of user code Owned.function.getOwner
		//TODO: implement
		//End of user code
	}
	
	
	
	function changeOwner(address newOwner) public  onlyOwner  {
		 owner = newOwner;
		
		//Start of user code Owned.function.changeOwner_address
		//TODO: implement
		//End of user code
	}
	
	
	
	function kill() public  onlyOwner  {
		 suicide(owner);
		
		//Start of user code Owned.function.kill
		//TODO: implement
		//End of user code
	}
	
	// Start of user code Owned.operations
	//TODO: implement
	// End of user code
}

/*
* A basic class to introduce an access control.
* All registered manager can access.
* A registered manager is an address mapped with true.
*/
contract Manageable {

	uint public mangerCount;
	mapping (address=>bool)public managers;
	// Start of user code Manageable.attributes
	// End of user code
	
	modifier onlyManager
	{
	    if (!canAccess()) throw;
	    _;
	}
	
	
	event ManagerChanged(uint _state,address _address,uint _managerCount);
	
	
	function Manageable() public   {
		//Start of user code Manageable.constructor.Manageable
	    managers[msg.sender] = true;
		mangerCount++;
		ManagerChanged(0,msg.sender,mangerCount);
		//End of user code
	}
	
	
	
	function canAccess() internal  returns (bool ) {
		 
		
		//Start of user code Manageable.function.canAccess
		return managers[msg.sender];
		//End of user code
	}
	
	
	
	function addManager(address _newManagerAddress) public  onlyManager  {
		 
		
		//Start of user code Manageable.function.addManager_address
		if(!managers[_newManagerAddress]){
			mangerCount++;
			ManagerChanged(0,_newManagerAddress,mangerCount);	
		}
		
		managers[_newManagerAddress] = true;
		//End of user code
	}
	
	
	
	function removeManager(address _managerAddress) public  onlyManager  {
		 
		
		//Start of user code Manageable.function.removeManager_address
		if(managers[_managerAddress]){
			mangerCount--;
			ManagerChanged(1,_managerAddress,mangerCount);
		}
		managers[_managerAddress] = false;
		//End of user code
	}
	
	
	
	function isManager(address _managerAddress) public   constant returns (bool ) {
		//Start of user code Manageable.function.isManager_address
		if( managers[_managerAddress])
			return true;
		
		return false;
		//End of user code
	}
	
	// Start of user code Manageable.operations
	//TODO: implement
	// End of user code
}


contract Multiowned {
    
    struct PendingState {
    	uint yetNeeded;
    	uint ownersDone;
    	uint index;
    }

	uint public m_required;
	uint public m_numOwners;
	uint[250] public m_owners;
	uint constant  public c_maxOwners = 250;
	bytes32[] public m_pendingIndex;
	mapping (uint=>uint)public m_ownerIndex;
	mapping (bytes32=>PendingState)public m_pending;
	// Start of user code Multiowned.attributes
	//TODO: implement
	// End of user code
	
	modifier onlyManyOwners(bytes32 _operation)
	{
	    if (confirmAndCheck(_operation))
	    _;
	}
	
	
	event Confirmation(address owner,bytes32 operation);
	
	
	event Revoke(address owner,bytes32 operation);
	
	
	event OwnerChanged(address oldOwner,address newOwner);
	
	
	event OwnerAdded(address newOwner);
	
	
	event OwnerRemoved(address oldOwner);
	
	
	event RequirementChanged(uint newRequirement);
	
	
	/*
	* Constructor is given number of sigs required to do protected "onlymanyowners" transactions
	* as well as the selection of addresses capable of confirming them.
	* 
	* _owners -
	* _required -
	*/
	function Multiowned(address[] _owners,uint _required) public   {
		//Start of user code Multiowned.function.Multiowned_address_uint
		//TODO: implement
		//End of user code
	}
	
	
	/*
	* Revokes a prior confirmation of the given operation.
	* 
	* _operation -
	*/
	function revoke(bytes32 _operation) external   {
		//Start of user code Multiowned.function.revoke_bytes32
		//TODO: implement
		//End of user code
	}
	
	
	/*
	* Replaces an owner `_from` with another `_to`.
	* 
	* _from -
	* _to -
	*/
	function changeOwner(address _from,address _to) external  onlyManyOwners(sha3(msg.data))  {
		//Start of user code Multiowned.function.changeOwner_address_address
		//TODO: implement
		//End of user code
	}
	
	
	/*
	* Replaces an owner `_from` with another `_to`.
	* 
	* _owner -
	*/
	function addOwner(address _owner) external  onlyManyOwners(sha3(msg.data))  {
		//Start of user code Multiowned.function.addOwner_address
        if (isOwner(_owner)) return;

        clearPending();
        if (m_numOwners >= c_maxOwners)
            reorganizeOwners();
        if (m_numOwners >= c_maxOwners)
            return;
        m_numOwners++;
        m_owners[m_numOwners] = uint(_owner);
        m_ownerIndex[uint(_owner)] = m_numOwners;
        OwnerAdded(_owner);
		//End of user code
	}
	
	
	
	function removeOwner(address _owner) external  onlyManyOwners(sha3(msg.data))  {
		//Start of user code Multiowned.function.removeOwner_address
		//TODO: implement
		//End of user code
	}
	
	
	
	function changeRequirement(uint _newRequired) external  onlyManyOwners(sha3(msg.data))  {
		//Start of user code Multiowned.function.changeRequirement_uint
		//TODO: implement
		//End of user code
	}
	
	
	
	function isOwner(address _addr) public  returns (bool ) {
		//Start of user code Multiowned.function.isOwner_address
		//TODO: implement
		//End of user code
	}
	
	
	
	function hasConfirmed(bytes32 _operation,address _owner) public   constant returns (bool ) {
		//Start of user code Multiowned.function.hasConfirmed_bytes32_address
		//TODO: implement
		//End of user code
	}
	
	
	
	function confirmAndCheck(bytes32 _operation) internal  returns (bool ) {
		//Start of user code Multiowned.function.confirmAndCheck_bytes32
		//TODO: implement
		//End of user code
	}
	
	
	
	function reorganizeOwners() private   {
		//Start of user code Multiowned.function.reorganizeOwners
        uint free = 1;
        while (free < m_numOwners)
        {
            while (free < m_numOwners && m_owners[free] != 0) free++;
            while (m_numOwners > 1 && m_owners[m_numOwners] == 0) m_numOwners--;
            if (free < m_numOwners && m_owners[m_numOwners] != 0 && m_owners[free] == 0)
            {
                m_owners[free] = m_owners[m_numOwners];
                m_ownerIndex[m_owners[free]] = free;
                m_owners[m_numOwners] = 0;
            }
        }
		//End of user code
	}
	
	
	
	function clearPending() internal   {
		//Start of user code Multiowned.function.clearPending
        uint length = m_pendingIndex.length;
        for (uint i = 0; i < length; ++i)
            if (m_pendingIndex[i] != 0)
                delete m_pending[m_pendingIndex[i]];
        delete m_pendingIndex;
		//End of user code
	}
	
	// Start of user code Multiowned.operations
	//TODO: implement
	// End of user code
}

