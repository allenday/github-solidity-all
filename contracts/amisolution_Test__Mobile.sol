pragma solidity ^0.4.8;

/*
This creates a public contract in the Ethereum Blockchain. 
Experimental contract based on https://github.com/Shultzi/Solidity/blob/master/demo.sol
and partially rewritten by amisolution: https://github.com/amisolution/Test/blob/master/Mobile.sol.
 This contract is intended for testing purposes, you are fully responsible for compliance with
present or future regulations of finance, communications and the 
universal rights of digital beings.
Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.
Challenges of setting contract:
=> Additional TimeFrame of Delivery required
=> Short Contract duration TimeFrame cannot be handled by large mobile carrier.
=> Service Provider Interexchange Platform to be created for each SIM provider.
*/


contract ContractDestruction{

	address public owner;
	uint ownerbalance; 		// TIP: uint is an alias for uint256. Ditto int and int256.

	function mortal(){

		owner = msg.sender;

	}

	modifier onlyOwner{
		if (msg.sender != owner){
			throw;
		}else{
			_;
		}
	}

	function kill() onlyOwner{

		suicide(owner);
	}


}

contract MyUserName is ContractDestruction{

	string public userName;

	mapping(address=>Service) public services;

	struct Service{
		bool active;
		uint lastUpdate;
		uint256 debt;
	}

	function MyUserName(string _name){

		userName = _name;
	}

	function registerToProvider(address _providerAddress) onlyOwner {

		services[_providerAddress] = Service({
			active: true,
			lastUpdate: now,
			debt: 0
			});

	}

	function setDebt(uint256 _debt){
		if(services[msg.sender].active){
			services[msg.sender].lastUpdate = now;
			services[msg.sender].debt 		= _debt;

			}else{
				throw;
			}
	}
	
	function payToProvider(uint256 _debt, address _providerAddress){
		if (!_providerAddress.send(services[msg.sender].debt))
		    throw;
	}
	
	function unsubscribe(address _providerAddress){
		if(services[_providerAddress].debt == 0){
			services[_providerAddress].active = false;

			}else{
				throw;
			}
	}


}

contract ServiceProvider is ContractDestruction{

	string public ServiceProvider;
	string public operator;
	string public servicebill;
	
	function ServiceProvider(
		string _UserId,
		string _operator,
		string _PayMyBill){

		ServiceProvider = _UserId;
		operator  = _operator;
		servicebill  = _PayMyBill;

	}

	function setDebt(uint256 _debt, address _userAddress){

		MyUserName imediation = MyUserName(_userAddress);
		imediation.setDebt(_debt);

	}

}
