pragma solidity ^0.4.0;

contract IdentityRegistry {
    /* Define variable owner of the type address*/
    address public owner;
	mapping(address => Account) accounts;
	mapping(string => EmailAddress) emailAddresses;

	struct Account {
		mapping(string => EmailAddress) emailAddresses;
	}

	struct EmailAddress {
	    address owner;
	    string emailAddress;
	}

	event EmailAddressRegistered(address sender, string emailAddress);

    /* this function is executed at initialization and sets the owner of the contract */
    function IdentityRegistry() { owner = msg.sender; }

    /* Function to recover the funds on the contract */
    function kill() { if (msg.sender == owner) selfdestruct(owner); }

    function registerEmailAddress(address addr, string emailAddress) returns(bool registered) {
        // Only owner of contract is allowed to add email adresses to the registry
        if (msg.sender == owner) {
            Account account = accounts[addr];
            account.emailAddresses[emailAddress] = EmailAddress({owner: addr, emailAddress: emailAddress});
            emailAddresses[emailAddress] = EmailAddress({owner: addr, emailAddress: emailAddress});
            EmailAddressRegistered(addr, emailAddress);
            return true;
        }
    }

    function removeEmailAddress(string emailAddress) returns(bool registered) {
        // Owner of contract and owner of emailadress are allowed to remove email addresses
        EmailAddress registryEmail = emailAddresses[emailAddress];

        if (msg.sender == owner || msg.sender == registryEmail.owner) {
            delete emailAddresses[emailAddress];
            return true;
        }
    }

    function verifyEmailAddress(address addr, string emailAddress) returns(bool verified) {
        EmailAddress registryEmail = emailAddresses[emailAddress];

        if (registryEmail.owner == addr) {
            return true;
        } else {
            return false;
        }
    }

    function getEmailAddressOwner(string emailAddress) returns(address owner) {
        EmailAddress email = emailAddresses[emailAddress];
        return email.owner;
    }
}