/*
*
*(c) 2016 KUEKeN
* Urs Zeidler
*
*/
pragma solidity ^0.4.1;

import "./basics.sol";
import "./members.sol";
import "./publishing.sol";
import "./voting.sol";

/*
* An organ is part of the party, defined in the constitution.
* It is populated by functions party members.
*/
contract Organ is Manageable,MemberAware,MessagePublisher {

	string public organName;
	uint public lastFunctionId;
	BlogRegistry public blogRegistry;
	bool public isActive;
	ShortBlog internal organBlog;
	uint public ballotCount;
	BallotFactory public ballotFactory;
	mapping (uint=>BasicBallot)private ballots;
	mapping (uint=>OrganFunction)internal organFunctions;
	// Start of user code Organ.attributes
	// End of user code
	
	modifier onlyIsFunction
	{
	    
	
	    _;
	}
	
	
	event FunctionMemberChange(address oldMember,uint functionId,address newMember);
	
	
	event FunctionChange(uint _type,OrganFunction _function);
	
	
	/*
	* Publish the message to the blog.
	* 
	* message -The message to send.
	* hash -The hash of the message.
	* er -The external resource of the message.
	*/
	function publishMessage(string message,string hash,string er) public   {
		//Start of user code Organ.function.publishMessage_string_string_string
		//TODO: shielder
		organBlog.sendMessage(message,hash,er);
		//End of user code
	}
	
	/*
	* Change the member of the function.
	* 
	* _id -
	* _address -
	*/
	function changeMember(uint _id,address _address) public  onlyManager()  {
		//Start of user code Organ.function.changeMember_uint_address

		//FunctionMemberChange(organFunctions[_id].currentMember,_id,_address);
		
		OrganFunction a = organFunctions[_id];
		FunctionMemberChange(_address,_id,a);
		organFunctions[_id].setCurrentMember(_address);
		organBlog.sendMessage("change member","","");
		//End of user code
	}
	
	
	/*
	* Create a function of this organ.
	* 
	* _functionName -The name of the organ function.
	* _constittiutionHash -
	*/
	function createFunction(string _functionName,string _constittiutionHash) public  onlyManager()  {
		//Start of user code Organ.function.createFunction_string_string
		OrganFunction of1 = new OrganFunction(_functionName,_constittiutionHash);
		organFunctions[lastFunctionId]=of1;
		ShortBlog b = blogRegistry.registerBlog(_functionName);
		of1.setPublisher(b);
		lastFunctionId++;
		of1.addManager(msg.sender);
		FunctionChange(1,of1);

		//End of user code
	}
	
	
	
	function initalizeOrgan() public   {
		//Start of user code Organ.function.initalizeOrgan
		//blogRegistry = new BlogRegistry();		
		
		organBlog = blogRegistry.registerBlog(organName);
		isActive = true;
//		organBlog.changeOwner(this);
		
		//End of user code
	}
	
	
	/*
	* Publish a message at a function blog.
	* 
	* id -
	* message -
	* hash -
	* er -
	*/
	function publishFunctionMessage(uint id,string message,string hash,string er) public   {
		//Start of user code Organ.function.publishFunctionMessage_uint_string_string_string

		OrganFunction of1 = organFunctions[id];
		of1.publishMessage(message,hash,er);
		//End of user code
	}
	
	
	/*
	* Creates a new ballot for this organ.
	* 
	* ballotType -
	* _registry -The member registry for the voting.
	* _name -The name of the ballot.
	* _hash -The hash of the actual text.
	* returns
	*  -
	*/
	function createBallot(uint ballotType,address _registry,string _name,string _hash) public  returns (uint ) {
		//Start of user code Organ.function.createBallot_uint_address_string_string
		
		ballotCount++;
		ballots[ballotCount] = ballotFactory.create(ballotType,this,_name,_hash);
		
		//End of user code
	}
	
	
	
	function getLastBallot() public   constant returns (address ) {
		//Start of user code Organ.function.getLastBallot
		return ballots[ballotCount];
		//End of user code
	}
	
	
	
	function getOrganBlog() public   constant returns (address ) {
		//Start of user code Organ.function.getOrganBlog
		return organBlog;
		//End of user code
	}
	
	
	
	function addOrganFunction(address _of,string _name) public   {
		//Start of user code Organ.function.addOrganFunction_address_string
		OrganFunction of1 = OrganFunction(_of);
		organFunctions[lastFunctionId]=of1;
		ShortBlog b = blogRegistry.registerBlog(_name);
		of1.setPublisher(b);
		lastFunctionId++;
		FunctionChange(1,of1);
		//End of user code
	}
	
	
	
	function getOrganFunction(uint _id) public   constant returns (OrganFunction ) {
		//Start of user code Organ.function.getOrganFunction_uint
		return organFunctions[_id];
		//End of user code
	}
	
	// getOrganName getter for the field organName
	function getOrganName() constant returns(string) {
		return organName;
	}
	// setOrganName setter for the field organName
	function setOrganName (string aOrganName) {
		organName = aOrganName;
	}
	
	// setBlogRegistry setter for the field blogRegistry
	function setBlogRegistry (address aBlogRegistry) {
		blogRegistry = BlogRegistry(aBlogRegistry);
	}
	
	// setBallotFactory setter for the field ballotFactory
	function setBallotFactory (address aBallotFactory) onlyManager() {
		ballotFactory = BallotFactory(aBallotFactory);
	}
	
	// Start of user code Organ.operations
	//TODO: implement 
	// End of user code
}

/*
* A basic party contract.
*/
contract Party is Manageable {

	string public name;
	MemberRegistry public memberRegistry;
	string public constitutionHash;
	uint public organCount;
	BlogRegistry public blogregistry;
	Party public parent;
	uint public subDivisionCount;
	mapping (uint=>Organ)public organs;
	mapping (uint=>Party)public subDivisions;
	// Start of user code Party.attributes
	// End of user code
	
	
	event ConstiutionChange();
	
	
	event OrganChanged(Organ _organ,uint _changeType);
	
	
	event DivisionChanged(address divisionAddress,address changer,uint state);
	
	
	
	function createOrgan(string organName) public   {
		//Start of user code Party.function.createOrgan_string
		Organ o = new Organ();
		o.setOrganName(organName);
		blogregistry.addManager(o);
		o.setBlogRegistry(blogregistry);
		o.setMemberRegistry(memberRegistry);	
		o.initalizeOrgan();	
		organs[organCount] = o;
		OrganChanged(o,1);
		organCount++; 
		//End of user code
	}
	
	
	/*
	* Adds an organ to the party.
	* 
	* _organ -
	*/
	function addOrgan(address _organ) public  onlyManager()  {
		//Start of user code Party.function.addOrgan_address
		Organ o = Organ(_organ);
		blogregistry.addManager(_organ);
		o.setBlogRegistry(blogregistry);
		o.setMemberRegistry(memberRegistry);	
		o.initalizeOrgan();	
		organs[organCount] = o;
		OrganChanged(o,1);
		organCount++; 
		//End of user code
	}
	
	
	/*
	* Add a subdivision of this party, the contrains are:
	* the party must be a mananger of the subdivision
	* the blogregistry must be the same
	* the member regstry must be the same
	* 
	* _subDivision -
	*/
	function addSubDivision(address _subDivision) public   {
		//Start of user code Party.function.addSubDivision_address
		Party p = Party(_subDivision);
		//check the constrains
		if(!p.isManager(this)) throw;
//		if(p.blogregistry()!=blogregistry) throw;
//		if(p.memberRegistry()!=memberRegistry) throw;
//		if(p.parent()!= this) throw;
		//TODO; a foundation conference should be done

		p.setParent(this);
		subDivisions[subDivisionCount] = p;
		DivisionChanged(p,msg.sender,1);
		subDivisionCount++;
		
		//End of user code
	}
	
	
	
	function removeSubDivision(uint _divisionId) public   {
		//Start of user code Party.function.removeSubDivision_uint
		Party p = subDivisions[_divisionId];
		p.setParent(0x0);
		DivisionChanged(p,msg.sender,0);
		//End of user code
	}
	
	// getMemberRegistry getter for the field memberRegistry
	function getMemberRegistry() constant returns(MemberRegistry) {
		return memberRegistry;
	}
	// setMemberRegistry setter for the field memberRegistry
	function setMemberRegistry (address aMemberRegistry) {
		memberRegistry = MemberRegistry(aMemberRegistry);
	}
	
	// setBlogregistry setter for the field blogregistry
	function setBlogregistry (address aBlogregistry) {
		blogregistry = BlogRegistry(aBlogregistry);
	}
	
	// Start of user code Party.operations
	
	/**
	*  setName
	*/
	function setName(string aName) public onlyManager{
		name = aName;
	}
	
	/**
	*  setParent
	*/
	function setParent(address _parent) public onlyManager{
		parent = Party(_parent); 
	}
	// End of user code
}

/*
* An actual party.
* The KUEKen party.
*/
contract KUEKeNParty is Party {

	// Start of user code KUEKeNParty.attributes
	uint test;
	// End of user code
	
	
	function KUEKeNParty(string _name) public   {
		//Start of user code KUEKeNParty.constructor.KUEKeNParty_string
//		//TODO: implement
//		//End of user code
	}
	
	
	
	function boostrapParty(address fc,address br) public  onlyManager()  {
		//Start of user code KUEKeNParty.function.boostrapParty_address_address
//		memberRegistry = new MemberRegistry();
//		memberRegistry.addManager(msg.sender);
//		blogregistry = new BlogRegistry();
		
		FoundationConference organ = FoundationConference(fc);
		organs[organCount] = FoundationConference(fc);
		organ.setOrganName("Gruendungsversammlung");
		organ.setMemberRegistry(memberRegistry);
		organ.setBlogRegistry(br);
		blogregistry = BlogRegistry(br);
		organ.initalizeOrgan();
		organCount++;
		//End of user code
	}
	
	// Start of user code KUEKeNParty.operations
	/*
	*  bootstrap2
	*/
	function bootstrap2() public {
		createOrgan("TestOrgan1");
//		createOrgan("TestOran2");
		
		Organ o = organs[0];
		//o.publishMessage("A Test message from the gk.","hash","externalResorce");
		
	}
	// End of user code
}

/*
* A conference is a meeting of the party members.
*/
contract Conference is Organ {

	address[] private accreditation;
	uint public accreditatedMembers;
	uint public date;
	// Start of user code Conference.attributes
	// End of user code
	
	
	event MemberAccreditated(uint memberId,string memberName,address memberAddress);
	
	
	
	function accreditationMember(address _address) public   {
		//Start of user code Conference.function.accreditationMember_address
		if(!isMember(_address))throw;
		
		accreditation.push(_address);
		accreditatedMembers++;
		memberRegistry.publishMemberEvent(_address,1);
		//End of user code
	}
	
	// Start of user code Conference.operations
	// End of user code
}

/*
* Will found the party.
* In the first and only session.
*/
contract FoundationConference is Conference {

	// Start of user code FoundationConference.attributes
	//TODO: implement
	// End of user code
	
	// Start of user code FoundationConference.operations
	
	/*
	*  initalizeOrgan
	*/
	function initalizeOrgan() public {
		super.initalizeOrgan();
		isActive = true;
//		createFunction("test","");
	}
	// End of user code
}

/*
* The function definition.
* A function is defined in the constitution of the party.
* Normaly it is associated with a party member.
*/
contract OrganFunction is Manageable,MessagePublisher {

	address public currentMember;
	string public functionName;
	uint public id;
	string public constitutionHash;
	uint public lastMemberChanged;
	uint public lastConstitutionHashChanged;
	ShortBlog public publisher;
	// Start of user code OrganFunction.attributes
	// End of user code
	
	
	function OrganFunction(string _name,string _ch) public   {
		//Start of user code OrganFunction.constructor.OrganFunction_string_string
		functionName = _name;
		constitutionHash = _ch;
		lastConstitutionHashChanged = now;
		//End of user code
	}
	
	
	/*
	* Publish the message to the blog.
	* 
	* message -The message to send.
	* hash -The hash of the message.
	* er -The external resource of the message.
	*/
	function publishMessage(string message,string hash,string er) public   {
		//Start of user code OrganFunction.function.publishMessage_string_string_string
		//TODO: shielder
		publisher.sendMessage(message,hash,er);
		//End of user code
	}
	
	
	function getFunctioName() public   constant returns (string ) {
		//Start of user code OrganFunction.function.getFunctioName
		return functionName;
		//End of user code
	}
	
	// setCurrentMember setter for the field currentMember
	function setCurrentMember (address aCurrentMember) onlyManager() {
		currentMember = aCurrentMember;
	}
	
	// setPublisher setter for the field publisher
	function setPublisher (address aPublisher) onlyManager() {
		publisher = ShortBlog(aPublisher);
	}
	
	// Start of user code OrganFunction.operations
	//TODO: implement
	// End of user code
}

