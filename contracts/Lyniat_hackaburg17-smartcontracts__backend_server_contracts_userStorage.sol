/*
Introduction:
Workshop Example Code from the Blockchain and Machine Learning Workshop at START Summit 2017 in Switzerland

Description:
This file implements the smart contract to be sent to the Blockchain.

Author:
Thomas Schmiedel, Data Reply 2017

Mail:
t.schmiedel@reply.de

Note:
This is just example code and not perfect yet, if you have any questions, advice, ..., just drop me a mail :-)
*/

pragma solidity ^0.4.0;

/*
 * The actual smart contract that can store a message, an image and tags for each user
 */
contract UserStorage
{
	// data structure to contain message, image and tags
	struct User
	{
        string transactionHashes;
        string identityDocuments;
	}

	// create a mapping from account-address to UserState,
	// this way, each user can store his own state,
	// the history is within the blockchain and can be retrieved as well
	// --> nothing lost
	mapping (address => User) userMapping;

	function getUser(address target) constant returns(string, string)
	{
        return (userMapping[target].transactionHashes,
                userMapping[target].identityDocuments);
	}

	function getUserTransactions() constant returns(string)
	{
		return userMapping[msg.sender].transactionHashes;
	}

	function setUserTransactions(string transHashes)
	{
		userMapping[msg.sender].transactionHashes = transHashes;
	}

	function setUserIdentityDocs(string identityDocs)
	{
		userMapping[msg.sender].identityDocuments = identityDocs;
	}
}
