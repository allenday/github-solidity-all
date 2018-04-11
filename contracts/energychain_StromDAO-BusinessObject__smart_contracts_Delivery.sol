contract Delivery is owned {
	RoleLookup public roles;
	address public dso;
	uint8 public role;
	
	uint256 public deliverable_startTime;
	uint256 public deliverable_endTime;
	uint256 public deliverable_power;
	address public resolution;
	address public account;
	 event Destructed(address _destruction);
	 event Included(address _address,uint256 power,uint256 startTime,uint256 endTime,uint256 role);
 
	
	function Delivery(RoleLookup _roles,address _meterpoint,uint8 _mprole,uint256 _startTime,uint256 _endTime, uint256 _power)  {
		roles=_roles;
		role=_mprole;

		deliverable_startTime=_startTime;
		deliverable_endTime=_endTime;
		deliverable_power=_power;
		
		// check sender is MPO for MP
	   // if(msg.sender!=roles.relations(_meterpoint,roles.roles(1))) throw;
		//dso=roles.relations(_meterpoint,roles.roles(2)); TODO: Check why that throws
		//if(address(0)==dso) throw;
		account=_meterpoint;    
		
	}
	
	function includeDelivery(Delivery _delivery) onlyOwner {
		if(_delivery.owner()!=address(this)) throw; // Operation only allowed if not owned by this Delivery
		
	   
		if(deliverable_startTime>_delivery.deliverable_startTime()) deliverable_startTime=_delivery.deliverable_startTime();
		if(deliverable_endTime<_delivery.deliverable_endTime()) deliverable_endTime=_delivery.deliverable_endTime();
		if(_delivery.role()==role) { 
			// add
			deliverable_power+=_delivery.deliverable_power();
		} else {
			// substract (Need to change Role, if lt 0)
			if(_delivery.deliverable_power()>deliverable_power) throw; // Not a include!
		   deliverable_power-=_delivery.deliverable_power();
		}
		Included(address(_delivery),_delivery.deliverable_power(),_delivery.deliverable_startTime(),_delivery.deliverable_endTime(),_delivery.role());
		_delivery.destructWith(this);
		
	}
   
	function destructWith(Delivery _delivery) onlyOwner { 
		
		if(address(resolution)!=0) throw;
		deliverable_power=0;
		Destructed(address(_delivery));
		
		resolution=address(_delivery);
		transferOwnership(account);
		
	}
}
