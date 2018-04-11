pragma solidity ^0.4.4;

// need a way to review ratings otherwise anyone can increase ratings
contract Rated {
	uint public totalRatings;
	uint public numberOfRatings;

	function rate(uint rating) public {
		totalRatings += rating;
		numberOfRatings++;
	}
}

contract Person is Rated {
	string name; // we can have more details
	address public account; // this is the address of the person's ether account

	// only government or some organisation should be able to create a person
	function Person(string n, address a) {
		name = n;
		account = a;
	}

	function getAccountAddress() returns (address) {
	    return account;
	}

}

// in geographic sense - this is a polygon and a property would lie within this polygon
contract Locality is Rated {
	string name;

	function Locality(string n) {
		name = n;
	}
}

contract EjariRulesC {
	address owner;

	struct Rule {
		uint incrementPercentage;
		uint maxRent;
	}

	mapping (address => Rule) localityRules;

	function EjariRulesC() {
		owner = msg.sender;
	}

	function addEjariRule(Locality locality, uint incrementPercentage, uint maxRent) {
		if (msg.sender != owner) {
			throw;
		}

		localityRules[address(locality)] = Rule(incrementPercentage, maxRent);
	}

	function isValidCondition(Locality locality, uint rent, uint incrementPercentage) public returns (bool) {
		Rule rule = localityRules[address(locality)];

		if (incrementPercentage > rule.incrementPercentage || rent > rule.maxRent) {
			return false;
		}

		return true;

	}

}

contract PropertyC is Rated {
    string latitude;
    string longitude;
    Locality locality;

    function PropertyC(string lt, string ln, Locality loc) {
        latitude = lt;
        longitude = ln;
        locality = loc;
    }

    function getLocality() returns (Locality) {
        return locality;
    }
}

contract Registry {
    address public registrar;
    EjariRulesC public ejariRules;

    mapping(address => Person) public ownership; // no shared ownership at the moment

    function Registry(EjariRulesC ejariRule) {
        registrar = msg.sender;
    }

    function assignOwnership(Person owner, address property) {
        if (msg.sender != registrar) throw;
        ownership[property] = owner;
    }


    function isValidTenancy(PropertyC property, uint rent, uint incrementPercentage) public returns (bool) {
        Person owner = ownership[address(property)];
        if (msg.sender != owner.getAccountAddress()) return false;

		return ejariRules.isValidCondition(property.getLocality(), rent, incrementPercentage);
    }
}


contract Tenancy {
    struct Condition {
    	uint rent;
        uint security;
        uint startTime;
        uint endTime;
    }

    // negotiation is necessary (and sometimes fun) in such dealings
    // would be good for demo too
    struct Negotiation {
        Person tenant;
        Condition condition;
        uint valid; // just to check if negotiation is null or not
        bool rejected;
    }

    enum State { Created, Locked, Terminated }

    address public property;
    Person public owner; // most likely we can get away with storing only address
    Person public tenant; // maybe this should be an array
	Condition public condition; // owner should be able to update conditions

	State public state;

    mapping (address => Negotiation) negotiations;

    // Events allow light clients to react on changes.
    event Negotiate(address prospectiveTenant, address owner);
    event Withdraw(address prospectiveTenant, address owner);
    event RejectNegotiation(address owner, address prospectiveTenant);

    function Tenancy(Registry registry, Person person, PropertyC property, uint rent, uint security, uint start, uint end) {
        // check if tenancy is valid as per ejari rules
        if (registry.isValidTenancy(property, rent, 0)) {
            owner = person;
            property = property;
            condition = Condition(rent, security, start, end);
            state = State.Created;
        } else {
            throw;
        }
    }

    modifier isActive() {
    	if (state == State.Terminated) throw;
    	_;
    }

    modifier onlyOwner() {
    	if (msg.sender != owner.getAccountAddress()) throw;
    	_;
    }

    modifier onlyTenant() {
		if (msg.sender != tenant.getAccountAddress()) throw;
		_;
	}

    modifier onlyNegotiator {
        Negotiation negotiation = negotiations[msg.sender];
        if (negotiation.valid == 0) throw;
        _;
    }

    function updateCondition(uint rent, uint security, uint start, uint end) onlyOwner isActive {
    	condition = Condition(rent, security, start, end);
    }

    // we can possibly take some fee here from negotiator - although that sounds a bit evil
    function negotiate(Person person, uint rent, uint security, uint start, uint end) isActive {
        // can't act on behalf of someone else
        if (person.getAccountAddress() != msg.sender) throw;

        // if a tenancy has been confirmed then only negotiations possible are between current tenant and owner
        if (state == State.Locked) {
			if (tenant.getAccountAddress() != msg.sender) throw;
        }

        Negotiation negotiation = negotiations[msg.sender];

		negotiation.tenant = person;
        negotiation.condition = Condition(rent, security, start, end);
        negotiation.rejected = false;
        negotiation.valid = 1;

        negotiations[msg.sender] = negotiation;
        Negotiate(msg.sender, owner);
    }

    function withdraw() onlyNegotiator isActive {
    	Negotiation negotiation = negotiations[msg.sender];
    	negotiation.valid = 0;
    	Withdraw(msg.sender, owner);
	}

    function rejectNegotiation(address prospectiveTenant) onlyOwner isActive {
        Negotiation negotiation = negotiations[prospectiveTenant];
		negotiation.rejected = true;
    }

    Negotiation acceptedNegotiation;

    // we can possibly take some fee here from owner
    function acceptNegotiationOwner(address prospectiveTenant) onlyOwner isActive {
        if (msg.sender != owner.getAccountAddress()) throw;

        Negotiation negotiation = negotiations[prospectiveTenant];
        if (negotiation.valid == 0) throw;

        acceptedNegotiation = negotiation;
    }

	// we can possibly take some fee here from owner and tenant to make this economically viable - ha ha ha!
    function acceptNegotiationTenant() payable isActive {
    	// only prospective tenant chosen by landlord/ owner can accept and finalize the contract
    	if (msg.sender != acceptedNegotiation.tenant.getAccountAddress()) throw;

    	// paise kaun dega be
    	if (msg.value < acceptedNegotiation.condition.rent + acceptedNegotiation.condition.security) throw;

        // okay for now keeping 2% of rent with the contract
    	uint fee = (2 * acceptedNegotiation.condition.rent) / 100 ;
    	uint rent = acceptedNegotiation.condition.rent;
    	// contract will keep the security deposit and finally return it to tenant if all goes well
    	if (!owner.getAccountAddress().send(rent - fee)) throw;
    	state = State.Locked;
    	tenant = acceptedNegotiation.tenant;
    	condition = acceptedNegotiation.condition;
    }

    function terminate() payable {
    	if (!(msg.sender == owner.getAccountAddress() || msg.sender == tenant.getAccountAddress())) {
    		throw;
    	}
    	if (now > condition.endTime) {
    	    if (!tenant.getAccountAddress().send(security - fee)) throw; // ideally we would want to return some part of security
			state = State.Terminated;
			// keeping 10% of security deposit with contract
			uint fee = acceptedNegotiation.condition.security / 10 ;
    	    uint security = acceptedNegotiation.condition.security;
    	} else {
    		throw;
    	}
    }

    // EXTENTION OF TENANCY
    // TO BE DONE

}
