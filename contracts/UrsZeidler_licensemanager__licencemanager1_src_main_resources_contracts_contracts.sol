/*
*
*
*/
pragma solidity ^0.4.0;
/*
* A number of contracts to issue license.
* (c) Urs Zeidler
*/

/*
* The licensmanager creates an issuer contract and holds the payment address.
*/
contract LicenseManager {

	address public owner;
	address public paymentAddress;
	string public issuerName;
	uint public contractCount;
	mapping (uint=>LicenseIssuer)public contracts;
	// Start of user code LicenseManager.attributes
	// End of user code
	
	modifier onlyOwner
	{
	     if(owner != msg.sender) throw;
	    _;
	}
	
	
	function LicenseManager(address _paymentAddress,string _name) public   {
		//Start of user code LicenseManager.constructor.LicenseManager_address_string
		owner = msg.sender;
		issuerName = _name;
		paymentAddress = _paymentAddress;
		//End of user code
	}
	
	
	/*
	* Change the address which receive the payment for an issued license. Only new issued licenses are affected.
	* 
	* _newPaymentAdress -
	*/
	function changePaymentAddress(address _newPaymentAdress) public  onlyOwner  {
		//Start of user code LicenseManager.function.changePaymentAddress_address
		owner = _newPaymentAdress;
		//End of user code
	}
	
	
	/*
	* Create a new licenseissuer contract.
	* The price is in finney.
	* 
	* itemName -
	* textHash -
	* url -
	* lifeTime -
	* price -
	*/
	function createIssuerContract(string itemName,string textHash,string url,uint lifeTime,uint price) public  onlyOwner  {
		//Start of user code LicenseManager.function.createIssuerContract_string_string_string_uint_uint
		 contracts[contractCount] = new LicenseIssuer(itemName, textHash, url, lifeTime, price, paymentAddress);
		 contractCount++;
		//End of user code
	}
	
	
	/*
	* Stopps the licence issuer from issue any more licences.
	* 
	* licenseId -
	*/
	function stopIssuing(uint licenseId) public  onlyOwner  {
		//Start of user code LicenseManager.function.stopIssuing_uint
		 contracts[licenseId].stopIssuing();
		//End of user code
	}
	
	
	/*
	* Change the address which receive the payment for an issued license for a specific license issuer. 
	* 
	* _newPaymentAddress -
	* licenseId -
	*/
	function changePaymentAddress(address _newPaymentAddress,uint licenseId) public  onlyOwner  {
		//Start of user code LicenseManager.function.changePaymentAddress_address_uint
		 if(!contracts[licenseId].getIssuable())
		 	throw;
		 contracts[licenseId].changePaymentAddress(_newPaymentAddress);
		//End of user code
	}
	
	
	
	function changeOwner(address _newOwner) public  onlyOwner  {
		//Start of user code LicenseManager.function.changeOwner_address
		owner = _newOwner;
		//End of user code
	}
	
	function() {
		// Start of user code LicenseManager default.function
		throw;
		// End of user code
	}
	// Start of user code LicenseManager.operations
	// End of user code
}

/*
* The license issuer is a contract containing the description of a particular license.
* It grands a license to an address by receiving the fund and holds a register of the 
* issued licenses.
*/
contract LicenseIssuer {
    /*
    * Hold one issued license for the item.
    */
    struct IssuedLicense {
    	address licenseOwnerAdress;
    	string licenseOwnerName;
    	uint issuedDate;
    }

	string public licensedItemName;
	string public licenseTextHash;
	string public licenseUrl;
	uint256 public licencePrice;
	uint public licenseLifetime;
	uint public licenseCount;
	bool public issuable;
	address public paymentAddress;
	address public licenseManager;
	mapping (uint=>IssuedLicense)public issuedLicenses;
	mapping (address=>IssuedLicense)public licenseOwners;
	// Start of user code LicenseIssuer.attributes
	//TODO: implement
	// End of user code
	
	modifier onlyLicenseManager
	{
	    if(licenseManager != msg.sender) throw;
	    _;
	}
	
	modifier onlyExactAmount
	{
	    if(msg.value!=licencePrice|| !issuable) throw;
	    _;
	}
	
	
	event LicenseIssued(address ownerAddress,string name,bool succesful);
	
	
	function LicenseIssuer(string itemName,string textHash,string url,uint lifeTime,uint price,address _pa) public   {
		//Start of user code LicenseIssuer.constructor.LicenseIssuer_string_string_string_uint_uint_address
		licensedItemName = itemName;
		licenseTextHash = textHash;
		licenseUrl = url;
		licencePrice = price  * 1 finney;
		licenseLifetime = lifeTime;
		paymentAddress = _pa;
		issuable = true;
		licenseManager = msg.sender;
		//End of user code
	}
	
	
	/*
	* Check the liceses by a given signature.
	* 
	* factHash -
	* v -
	* sig_r -
	* sig_s -
	* returns
	*  -
	*/
	function checkLicense(bytes32 factHash,uint8 v,bytes32 sig_r,bytes32 sig_s) public   constant returns (bool ) {
		//Start of user code LicenseIssuer.function.checkLicense_bytes32_uint8_bytes32_bytes32
		 address _address = ecrecover(factHash, v, sig_r, sig_s);
		 IssuedLicense data = licenseOwners[_address];
		 if(data.issuedDate == 0)
		 	return false;
		 if((licenseLifetime<1)||(licenseLifetime+now<data.issuedDate))
		 	return true;
		 return false;
		//End of user code
	}
	
	
	/*
	* Simply lookup the license and check if it is still valid.
	* 
	* _address -
	* returns
	*  -
	*/
	function checkLicense(address _address) public   constant returns (bool ) {
		//Start of user code LicenseIssuer.function.checkLicense_address
		 IssuedLicense data = licenseOwners[_address];
		 if(data.issuedDate == 0)
		 	return false;
		 if((licenseLifetime<1))
		 	return true;
		 if(now<data.issuedDate+licenseLifetime)
		 	return true;
		 return false;
		//End of user code
	}
	
	
	/*
	* Change the payment address.
	* 
	* _newPaymentAddress -
	*/
	function changePaymentAddress(address _newPaymentAddress) public  onlyLicenseManager  {
		//Start of user code LicenseIssuer.function.changePaymentAddress_address
		 paymentAddress = _newPaymentAddress;
		//End of user code
	}
	
	
	/*
	* Stop accecpting buying a license.
	*/
	function stopIssuing() public  onlyLicenseManager  {
		//Start of user code LicenseIssuer.function.stopIssuing
		 issuable = false;
    	//End of user code
	}
	
	
	/*
	* Issue a license for the item by sending the address data and the amount of money.
	* 
	* _address -
	* _name -
	*/
	function buyLicense(address _address,string _name) public  onlyExactAmount payable  {
		//Start of user code LicenseIssuer.function.buyLicense_address_string
		  if(_address==address(0))
		    _address = msg.sender;
		
		 uint date = licenseOwners[_address].issuedDate;
		 if( (date!=0 && (licenseLifetime<1)||(licenseLifetime+now<date)) ) throw;
		 issuedLicenses[licenseCount].licenseOwnerName = _name;
		 issuedLicenses[licenseCount].issuedDate = now;
		 issuedLicenses[licenseCount].licenseOwnerAdress = _address;
		 licenseOwners[_address] = issuedLicenses[licenseCount];
		 licenseCount++;
		 bool ret = paymentAddress.send(msg.value);
		 LicenseIssued(_address,_name,ret);
		//End of user code
	}
	
	// getIssuable getter for the field issuable
	function getIssuable() constant returns(bool) {
		return issuable;
	}
	
	function() {
		// Start of user code LicenseIssuer default.function
		throw;
		// End of user code
	}
	// Start of user code LicenseIssuer.operations
	//TODO: implement
	// End of user code
}

