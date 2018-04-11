/**
 * RoleLookup
 * 
 * ====================================================================
 * Provides entity relation model (yellowpages, who-implements-what)
 * to StromDAO Business Objects. A single consensframe must always share
 * a single RoleLookup deployment.
 */
contract RoleLookup {
	mapping(uint256 => uint8) public roles;
	mapping(address=>mapping(uint8=>address)) public relations;
	mapping(address=>mapping(address=>uint8)) public relationsFrom;
	mapping(uint8=>address) public defaults;
	event Relation(address _from,uint8 _for, address _to);
	
	function RoleLookup() {
		roles[0]= 0;
		roles[1]= 1;
		roles[2]= 2;
		roles[3]= 3;
		roles[4]= 4;
		roles[5]= 5;
	}
	function setDefault(uint8 _role,address _from) {
		if(msg.sender!=address(0xD87064f2CA9bb2eC333D4A0B02011Afdf39C4fB0)) throw;
		defaults[_role]=_from;
	}
	function setRelation(uint8 _for,address _from) {
		relations[msg.sender][_for]=_from;
		Relation(_from,_for,msg.sender);
	}
	function setRelationFrom(uint8 _for,address _from) {
		relationsFrom[msg.sender][_from]=_for;
		Relation(_from,_for,msg.sender);
	}
}
