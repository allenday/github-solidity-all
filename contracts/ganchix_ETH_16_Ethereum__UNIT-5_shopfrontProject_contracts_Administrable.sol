pragma solidity ^0.4.5;

contract Administrable{

	address administrator;

	event LogAdminChangeEvent(address oldAdministrator, address newAdministrator);

	function Administrable(address administratorAddress) 
		public
	{
        require(administratorAddress != address(0));
        administrator = administratorAddress;
	}
    

    
    modifier isAdministrator 
	{
		require(msg.sender == administrator);
		_;
	}

	function getAdministrator()
		constant 
		public 
		returns(address _administrator)
	{
		return administrator;
	}

	function setAdministrator(address newAdministrator)
		isAdministrator
		public
		returns (bool success)
	{
		require(newAdministrator != address(0));
		require(newAdministrator != administrator);
		administrator = newAdministrator;
		LogAdminChangeEvent(msg.sender, newAdministrator);
		return true;

	}


}