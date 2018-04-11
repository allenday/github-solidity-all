contract testAccess {
	address public AccessControlAddress;
	
	modifier onlySuperUser{
		address nameReg = AccessControlAddress;
		if (nameReg == 0) throw;
		if (!nameReg.call(bytes4(sha3("isSuperUser(address)")), msg.sender)) throw;
	}
	
	modifier onlyManager{
		address nameReg = AccessControlAddress;
		if (nameReg == 0) throw;
		if (!nameReg.call(bytes4(sha3("isManager(address)")), msg.sender)) throw;
		
	}
	
	modifier onlyUser{
		address nameReg = AccessControlAddress;
		if (nameReg == 0) throw;
		if (!nameReg.call(bytes4(sha3("isUser(address)")), msg.sender)) throw;
		
	}
	
	function testAccess(address acAddress){
		AccessControlAddress = acAddress;
	}
	
	
	function testSuperUser(address superUserAddress) onlySuperUser returns (bool) {
		return true;
	}

	function testManager(address superUserAddress) onlyManager returns (bool){
		return true;
	}

	function testUser(address superUserAddress) onlyUser returns (bool){
		return true;
	}
	
	function changeACAddress(address acAddress){
		AccessControlAddress = acAddress;
	}

	
}
