pragma solidity ^0.4.4;

/**
 * @title D-Transport
 * @author Victor Le <https://github.com/Coac>
 * @author Mathieu Porcel <https://github.com/mathieu-porcel>
 */
contract DTransport {

	/**
	 * Transport company which provides validation terminal
	 */
	struct Company {
		uint creationDate;
		string name;
		string location;
	}

	/**
	 * Validation terminal used to validate "ticket"
	 */
	struct ValidationTerminal {
		uint creationDate;
		uint location;
		address company;
	}

	/**
	 * "Ticket" validation
	 */
	struct Validation {
		uint date;
		address terminal;
	}

	/**
	 * Authorization given by a terminal to a user to validate
	 */
	struct Authorization {
		uint expiration;
	}

	/**
	 * User who uses the transport service
	 */
	struct User {
		uint creationDate;
		uint validationCount;
		mapping (uint => Validation) validations;
		mapping (address => Authorization) authorizations;
	}

	/**
	 * Admin is the one who created the contract
	 * He is the only one able to add companies
	 * The admin can be changed in the future
	 */
	address public admin;

	modifier onlyAdmin() {
		if (msg.sender != admin) throw;
		_;
	}

	address[] public terminalsAddress;
	mapping(address => ValidationTerminal) public terminals;

	address[] public companiesAddress;
	mapping(address => Company) public companies;

	address[] public usersAddress;
	mapping(address => User) public users;

	function DTransport() {
		admin = msg.sender;
	}


	/**
	 * @notice Add a transport company to the system
	 * @param company the company ethereum address
	 * @param name the company name
	 */
	function addCompany (address company, string name) onlyAdmin {
		companiesAddress.push(company);
		companies[company] = Company({
				creationDate: now,
        name: name,
				location: 'location'
    });
	}

	/**
	 * @notice Get Company by index
	 * @return user
	 */
	function getCompany(uint index) constant returns (address, uint, string, string) {
		return (companiesAddress[index], companies[companiesAddress[index]].creationDate, companies[companiesAddress[index]].name, companies[companiesAddress[index]].location);
	}

	/**
	 * @notice Get Companies count
	 * @return userCount
	 */
	function getCompanyCount() constant returns (uint) {
		return companiesAddress.length;
	}

	/**
	 * @notice Add a terminal to the system
	 * @param terminal the terminal ethereum address
	 * @param location the terminal location
	 * @param company the company which own the terminal ethereum address
	 */
	function addTerminal (address terminal, uint location, address company) {
		terminalsAddress.push(terminal);
		terminals[terminal] = ValidationTerminal({
				creationDate: now,
        company: company,
				location: location
    });
	}

	/**
	 * @notice Get Terminal by index
	 * @return user
	 */
	function getTerminal(uint index) constant returns (address, uint, uint, address) {
		return (terminalsAddress[index], terminals[terminalsAddress[index]].creationDate, terminals[terminalsAddress[index]].location, terminals[terminalsAddress[index]].company);
	}

	/**
	 * @notice Get Terminals count
	 * @return userCount
	 */
	function getTerminalCount() constant returns (uint) {
		return terminalsAddress.length;
	}

	/**
	 * @notice Used by an User to validate to a terminal
	 * @dev Checks if the the user is authorized then create the entry
	 * @param terminal the terminal ethereum address
	 */
	function validate(address terminal) returns (bool) {
		if(users[msg.sender].authorizations[terminal].expiration > now) {
			users[msg.sender].validations[users[msg.sender].validationCount] = Validation(now, terminal);
			users[msg.sender].validationCount += 1;
			return true;
		}
		return false;
	}

	/**
	 * @notice Used by an Terminal to give an User authorization to validate
	 * @param userAddr the user ethereum address
	 */
	function giveAuthorization (address userAddr) {
		users[userAddr].authorizations[msg.sender] = Authorization(now + 10 minutes);
	}

	/**
	 * @notice Register as an User
	 */
	function register() {
		if(users[msg.sender].creationDate == 0) {
			usersAddress.push(msg.sender);
			users[msg.sender] = User(now, 0);
		}
	}

	/**
	 * @notice Get user by index
	 * @return user
	 */
	function getUser(uint index) constant returns (address, uint, uint) {
		return (usersAddress[index], users[usersAddress[index]].creationDate, users[usersAddress[index]].validationCount);
	}

	/**
	 * @notice Get user count
	 * @return userCount
	 */
	function getUsersCount() constant returns (uint) {
		return usersAddress.length;
	}

	/**
	 * @notice Get authorization date from user given by a terminal
	 * @param user the user ethereum address
	 * @param terminal the terminal ethereum address
	 * @return date
	 */
	function getAuthorizationDate(address user, address terminal) constant returns (uint) {
		if(users[user].creationDate == 0) {
			return 1;
		}

		if(users[user].authorizations[terminal].expiration == 0) {
			return 2;
		}

		return users[user].authorizations[terminal].expiration;
	}

	function getValidation(address user, uint index) constant returns (uint, address) {
		if(users[user].creationDate == 0) {
			return (1, 0x0);
		}

		if(index >= users[user].validationCount) {
			return (2, 0x0);
		}

		return (users[user].validations[index].date, users[user].validations[index].terminal);
	}
}
