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
contract ContractStorage
{
	// data structure to contain message, image and tags
	struct Contract
	{
        string partner;
        string text;
	}

	// create a mapping from account-address to UserState,
	// this way, each user can store his own state,
	// the history is within the blockchain and can be retrieved as well
	// --> nothing lost
	mapping (address => Contract) contractMapping;

	function getContract(address target) constant returns(string, string)
	{
        return (contractMapping[target].partner,
                contractMapping[target].text);
	}

	function createNewContract(string partner, string text)
	{
		contractMapping[msg.sender].partner = partner;
		contractMapping[msg.sender].text = text;
	}
}
