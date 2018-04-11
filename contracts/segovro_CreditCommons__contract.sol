pragma solidity ^0.4.10;

contract creditCommons {

        // @title creditCommons
        // @author Rogelio SEGOVIA; Matthew Slatter	
		// @param sysAdmin is the system administrator address, the creator of the contract

		address public sysAdmin = msg.sender;  
		uint nrMembers;
		uint nrGroups;
		uint nrProposals;
		uint nrBills;
	
	// @notice at creating the contract we declare the general variables
	function creditCommons() {
				// @param the initial sysAdmin is the address from which the contract is created
				
			    nrMembers = 0;
			    nrGroups = 0;
			    nrProposals = 0;
			    nrBills = 0;
        }
	
    function getTotals () constant returns (uint, uint, uint, uint) {
    	return (nrMembers, nrGroups, nrProposals, nrBills);
    }
	
	event NewGroup(address indexed _creator, uint indexed _groupIDN, string _groupNameN, uint _NGTimeStamp);
	event ModifyGroup (address indexed _modifier, uint indexed _groupIDM, string _groupNameM, uint _MGTimeStamp);
	event NewMember (address indexed _memberAddressN, string _memberAliasN, string _descriptionN, uint _NMTimeStamp);
	event JoinGroup (address _memberJG, string _aliasJG, uint _groupJG, string _groupNameJG, uint _JGTimeStamp);
	event ResignGroup (address _memberRG, string _aliasRG, uint _groupRG, string _groupNameRG, uint _RGTimeStamp);

	// @notice function to name a new sysAdmin
    function transferSysAdmin(address newSysAdmin) {
		if (msg.sender == sysAdmin) {
        sysAdmin = newSysAdmin;
		}
    }
	
	// @notice create a structure to file all members
	struct members {
		// @parameter key ID parameters
		bool isMember;
		string alias;
		string whisperID;
		string memberDescription;
		uint memberGroup;	
		bool isIntertrade;
		bool isCommune;
		// @parameter balance is expressed in the member currency. Can only be modified by system operations
		int balance;
		uint mDebitLimit;
		uint mCreditLimit;
		string imageLink;
	}
	
	// @notice map the members structure into an array indexed by the members ethereum address 
	mapping(address => members) member;
	
	// @notice create an index of members for listing purposes
	address[] memberIndex;
	
	// @notice anybody with an ethereum account can register in the system
	function registerSystem (string _alias, string _whisperID, string _description, string _imageLink) {
		// @notice the caller provides a valid alias
		if (bytes(_alias).length != 0) {
		// @notice the caller is not already the system
			if (member[msg.sender].isMember != true) {
			member[msg.sender].isMember = true;
			member[msg.sender].alias = _alias;
			member[msg.sender].whisperID = _whisperID;
			member[msg.sender].memberDescription = _description;
			member[msg.sender].memberGroup = 0;
			member[msg.sender].isIntertrade = false;
			member[msg.sender].isCommune = false;
			member[msg.sender].balance = 0;
			member[msg.sender].mDebitLimit = 0;
			member[msg.sender].mCreditLimit = 0;
			member[msg.sender].imageLink = _imageLink;
		NewMember (msg.sender, _alias, _description, now);
		memberIndex[memberIndex.length ++] = msg.sender;
		nrMembers = nrMembers + 1;
				} 
			} 
		}
	
	function modifyMember (string _alias, string _whisperID, string _description, string _imageLink) {
		if (bytes(_alias).length != 0) {member[msg.sender].alias = _alias;}
		if (bytes(_whisperID).length != 0) {member[msg.sender].whisperID = _whisperID;}
		if (bytes(_description).length != 0) {member[msg.sender].memberDescription = _description;}
		if (bytes(_imageLink).length != 0) {member[msg.sender].imageLink = _imageLink;}
		}
	
	function modifyMemberLimits (address _groupMember, uint _newDebitLimit, uint _newCreditLimit) {
		// @notice only the group commune can do 
		if (msg.sender == group[member[msg.sender].memberGroup].commune) {
					member[_groupMember].mDebitLimit = _newDebitLimit;
					member[_groupMember].mCreditLimit = _newCreditLimit;
		}
	}

	// @notice anybody in the system can join a group if the group is open
	function joinGroup (uint _groupJ) {
					// @notice if the group is open 
					if (group[_groupJ].open = true) {
						makeMemberOfGroup (msg.sender, _groupJ);
					} 
					// @notice if the group is not open "proposeNewMember"
	}
	
	function acceptAtGroup ( address _newMember, uint _groupJ) {
		// @notice the commune can accept a new member in the group
		if (group[_groupJ].commune == msg.sender) {
			makeMemberOfGroup (_newMember, _groupJ);	
		}
	}
	
	function makeMemberOfGroup (address _newMember, uint _groupJ) internal {
		// @notice the member is in the system
		// @notice the member is not in a group
		if ((member[_newMember].isMember = true) && (member[_newMember].memberGroup == 0)) {
		member[_newMember].memberGroup = _groupJ;
		member[_newMember].balance = 0;
		member[_newMember].mDebitLimit = group[_groupJ].defaultMemberDebitLimit;
		member[_newMember].mCreditLimit = group[_groupJ].defaultMemberCreditLimit;
		group[_groupJ].nrMembers = group[_groupJ].nrMembers + 1;
		JoinGroup (_newMember, member[_newMember].alias, _groupJ, group[_groupJ].groupName, now);
		}
	}
	
	function resignFromGroup () {
				uint _groupD = member[msg.sender].memberGroup; 
				// @notice balance cannot be negative
				if (member[msg.sender].balance >= 0) {
					deleteMemberOfGroup (msg.sender, _groupD);
				}
			}	
	
	function kickOutGroup (address _memberOfGroup, uint _groupD) {
		// @notice the commune can delete a new member in the group
		if (group[_groupD].commune == msg.sender) {
			deleteMemberOfGroup (_memberOfGroup, _groupD);
		}
	}
	
	function deleteMemberOfGroup (address _memberOfGroup, uint _groupD) internal {
		// @notice the account is not a group account and the member is not commune of the group
		if ((member[_memberOfGroup].isCommune == false) && (member[msg.sender].isCommune == false)) {
		member[group[_groupD].commune].balance += member[_memberOfGroup].balance;
		member[_memberOfGroup].balance = 0;
		member[_memberOfGroup].memberGroup = 0;
		member[_memberOfGroup].mDebitLimit = 0;
		member[_memberOfGroup].mCreditLimit = 0;
		group[_groupD].nrMembers = group[_groupD].nrMembers - 1;
		ResignGroup (_memberOfGroup, member[_memberOfGroup].alias, _groupD, group[_groupD].groupName, now);		
		}
	}

	function getMember (address _memberG) constant returns (bool, string, string, uint, int, uint, uint) {
	    return (member[_memberG].isMember, member[_memberG].alias, member[_memberG].memberDescription, member[_memberG].memberGroup, member[_memberG].balance, member[_memberG].mDebitLimit, member[_memberG].mCreditLimit);
	}
	
	function getMemberStatus (address _memberG) constant returns (bool, bool) {
	   return (member[_memberG].isIntertrade, member[_memberG].isCommune);
	}
	
	function getMemberWhisper (address _memberG) constant returns (string, string) {
	   return (member[_memberG].whisperID, member[_memberG].imageLink);
	}
			
	function getMPbyIndex (uint _mIndex) constant returns (address _getMemberID) {
		_getMemberID = memberIndex[_mIndex];
	}

    // @notice create a structure to file all groups and their parameters
    struct groups {
    	string groupName;
    	string groupDescription;
    	string currencyName;
    	address intertradeAccount;
    	address commune;
    	// @parameter the exchange rate against the base currency is given in percentage (100 = 1/1)
    	uint rate;
    	uint defaultMemberDebitLimit;
    	uint defaultMemberCreditLimit;	
    	bool open;
    	uint nrMembers;
    	uint quorum;
    	string imageLink;
    }

    // @notice map the exchanges structure into an array indexed by a string (the string we use is the CES Exchange ID)
    mapping(uint => groups) group;
    
    // @notice create an index of exchanges for listing purposes
    uint[] groupIndex;
    
    // @notice A group can be created by any account in the system that is not in a group. 
    // @notice A group is also an account and is identified by its account number. 
    // @notice A group has two special members:
    // @notice the intertrade account holding the external balance against other groups
    // @notice the commune account holding the group common moneys, such as taxes
    function createGroup (string _groupName, string _description, string _currencyName, uint _rate, uint _debitLimit, uint _creditLimit, uint _intertradeDebitLimit, uint _intertradeCreditLimit, bool _open) {
    	// @notice the member exists in the system and the member is not in a group and the name is valid
    	if (member[msg.sender].isMember = true) {
    		if (member[msg.sender].memberGroup == 0) { 
    				if (bytes(_groupName).length != 0) {
    					uint groupID = now;	
    					group[groupID].groupName = _groupName;
    					group[groupID].currencyName = _currencyName;
    					group[groupID].intertradeAccount = msg.sender;
    					group[groupID].commune = msg.sender;
    					group[groupID].rate = _rate;
    					group[groupID].defaultMemberDebitLimit = _debitLimit;
    					group[groupID].defaultMemberCreditLimit = _creditLimit;
    					group[groupID].open = _open;
    					group[groupID].nrMembers = 1;
    					group[groupID].quorum = 3;
    						NewGroup(msg.sender, groupID, _groupName, now);
    						// @notice make the creator member of the group and set the group intertrade limits
    						member[msg.sender].memberGroup = groupID;
    						member[msg.sender].isIntertrade = true;
    						member[msg.sender].isCommune = true;
    						member[msg.sender].balance = 0;
    						member[msg.sender].mDebitLimit = _intertradeDebitLimit;
    						member[msg.sender].mCreditLimit = _intertradeCreditLimit;
    					groupIndex[groupIndex.length ++] = groupID;
    					nrGroups = nrGroups +1;
    				} 
    			}
    	    } 
    	} 

    // @notice transfer group intertrade account. Old intertrade or sysAdmin can transfer group intertrade to another member of the group
    // @notice the reason to include sysAdmin is for the case the old commune disappears
    function transferGroupIntertrade (uint _groupID, address _newIntertrade) {
    	if ((msg.sender == group[_groupID].intertradeAccount) || (msg.sender == sysAdmin)) {
    		if (member[_newIntertrade].memberGroup == _groupID) {
        		member[group[_groupID].intertradeAccount].isIntertrade = false;
        		group[_groupID].intertradeAccount = _newIntertrade;
        		member[_newIntertrade].isIntertrade = true;
    			string _groupName = group[_groupID].groupName;
    			ModifyGroup (msg.sender, _groupID, _groupName, now);
    	} 
    	} 
    }
    
    // @notice transfer group commune. Old commune or sysAdmin can transfer group commune to another member of the group
    // @notice the reason to include sysAdmin is for the case the old commune disappears
    function transferGroupCommune (uint _groupID, address _newCommune) {
    	if ((msg.sender == group[_groupID].commune) || (msg.sender == sysAdmin)) {
    		if (member[_newCommune].memberGroup == _groupID) {
        		member[group[_groupID].commune].isCommune = false;
        		group[_groupID].commune = _newCommune;
        		member[_newCommune].isCommune = true;
    			string _groupName = group[_groupID].groupName;
    			ModifyGroup (msg.sender, _groupID, _groupName, now);
    	} 
    	} 
    }
    	
    // @notice the commune can modify one, several or all parameters of a group. If one parameter is left empty, it remains the same. Only the exchange commune can change its parameters
    function modifyGroup (uint _groupID, string _groupName, string _description, string _currencyName, uint _rate, uint _debitLimit, uint _creditLimit, uint _intertradeDebitLimit, uint _intertradeCreditLimit, bool _open, uint _newQuorum) {
    	        if (msg.sender == group[_groupID].commune) {
    			// @notice if a value for a parameter is given, change the parameter, if empty retain old value
    			if (bytes(_groupName).length != 0) {group[_groupID].groupName = _groupName;}
    			if (bytes(_description).length != 0) {group[_groupID].groupDescription = _description;}
    			if (bytes(_currencyName).length != 0) {group[_groupID].currencyName = _currencyName;}
    			if (_rate != 0) {group[_groupID].rate = _rate;}	
    			if (_debitLimit != 0) {group[_groupID].defaultMemberDebitLimit = _debitLimit;}
    			if (_creditLimit != 0) {group[_groupID].defaultMemberCreditLimit = _creditLimit;}
    			if (_intertradeDebitLimit != 0) {member[group[_groupID].intertradeAccount].mDebitLimit = _intertradeDebitLimit;}
    			if (_intertradeCreditLimit != 0) {member[group[_groupID].intertradeAccount].mCreditLimit = _intertradeCreditLimit;}
    			if (_open == true) {group[_groupID].open = true;}	
    			if (_newQuorum != 0) {group[_groupID].quorum = _newQuorum;}	
    			ModifyGroup (msg.sender, _groupID, _groupName, now);				
    				}     					
    }
    
    function getGroupDescription (uint _groupG) constant returns (string, string, string, bool, uint) {
    return (group[_groupG].groupName, group[_groupG].groupDescription, group[_groupG].currencyName, group[_groupG].open, group[_groupG].nrMembers);
    }
    
    function getGroupRates (uint _groupG) constant returns (uint, uint, uint) {
    return (group[_groupG].rate, group[_groupG].defaultMemberDebitLimit, group[_groupG].defaultMemberCreditLimit);
    }
    
    function getGroupManagement (uint _groupG) constant returns (address, address) {
    return (group[_groupG].intertradeAccount, group[_groupG].commune);
    }    
   
    function getGroupbyIndex (uint _gIndex) constant returns (uint _getGroupID) {
    	_getGroupID = groupIndex[_gIndex];
    }
    
    event Transaction (address indexed _sender, uint _senderAmount, address indexed _receiver, int _receiverAmount, uint _tTimeStamp);
    event Bill (uint _billNumber, address indexed _payee, address indexed _payer, string _description, uint _billAmount, uint _bTimeStamp);

	// @notice function transfer form the member of the same exchange or to the member of another exchange. The amount is expressed in the sender currency
	function transfer (address _to, uint _fromAmount) {		
		// @notice the given amount is converted to integer in order to work with only integers
		int _intFromAmount = int (_fromAmount);
		int _intFromDLimit = - int(member[msg.sender].mDebitLimit);
		int _intToCLimit = int(member[msg.sender].mCreditLimit);
		int _toAmount = 0;
		// @notice check if both accounts are in the same group 
		if (member[msg.sender].memberGroup == member[_to].memberGroup) {
			_toAmount = _intFromAmount;
		} else {
			// @notice conversions if the transaction is accross groups
			address _fromGroupAccount = group[member[msg.sender].memberGroup].intertradeAccount;
			address _toGroupAccount = group[member[_to].memberGroup].intertradeAccount;
			// @the amount is converted to the receiver currency
			uint _rateSenderU = group[member[msg.sender].memberGroup].rate;
			uint _rateReceiverU = group[member[_to].memberGroup].rate;
			int _rateSender = int(_rateSenderU);
			int _rateReceiver = int(_rateReceiverU);
			_toAmount = _intFromAmount * _rateSender/ _rateReceiver;
			// @notice if the group limits are not surpassed, we proceed with the transfer
			if (((member[_fromGroupAccount].balance - _intFromAmount) > - int(member[_fromGroupAccount].mDebitLimit)) 
				&& ((member[_toGroupAccount].balance + _toAmount) < int(member[_toGroupAccount].mCreditLimit))) {
				} 
		} 
		// @notice if the member limits are not surpassed, we proceed with the transfer
			if (((member[msg.sender].balance - _intFromAmount) > _intFromDLimit) 
				&& ((member[_to].balance + _toAmount) < _intToCLimit)) { 
				member[msg.sender].balance -= _intFromAmount;
				member[_to].balance += _toAmount;
				// @notice adjust intertrade accounts
				if (member[msg.sender].memberGroup != member[_to].memberGroup) {			
					member[_fromGroupAccount].balance -= _intFromAmount;
					member[_toGroupAccount].balance += _toAmount;
					} 
			} 
 			Transaction (msg.sender, _fromAmount, _to, _toAmount, now);
		}		
 
    event ProposalAdded(uint proposalNumber, uint group, string description, address creator);
    event Voted(address voter, uint proposalNumber, int8 vote, int result);
    event ProposalResult(uint proposalNumber, int result, uint quorum, bool active);
	
    struct Proposals {
		address creator;
    	uint proposalGroup;
    	string title;
        string description;
        uint votingDeadline;
        uint quorumProposal;
        bool closed;
        bool proposalPassed;
        uint numberOfVotes;
        int currentResult;
		mapping (address => Voters) voters;
    }	
	
	struct Voters {
		bool alreadyVoted;		
	}
 
	mapping (uint => Proposals) proposal;
	
	// @ notice Function to create a new proposal
    function newProposal (uint _proposalGroup, string _title, string _description, uint _days, uint _quorum) {   
        nrProposals ++;
        uint proposalNumber = nrProposals;
		proposal[proposalNumber].creator = msg.sender;
        proposal[proposalNumber].proposalGroup = _proposalGroup;
        proposal[proposalNumber].title = _title;
        proposal[proposalNumber].description = _description;
        proposal[proposalNumber].votingDeadline = now + _days * 1 days;
        proposal[proposalNumber].quorumProposal = _quorum;
        proposal[proposalNumber].closed = false;
        proposal[proposalNumber].proposalPassed = false;
        proposal[proposalNumber].numberOfVotes = 0;
        proposal[proposalNumber].currentResult = 0;
		proposal[proposalNumber].voters[msg.sender].alreadyVoted = false; 		
        ProposalAdded(proposalNumber, _proposalGroup, _description, msg.sender);
    }
	
	function proposeAcceptanceAsMember (uint _candidateGroup) {
		if (member[msg.sender].isMember = true) {
		newProposal (_candidateGroup, "Accept Member", member[msg.sender].memberDescription, 10, group[_candidateGroup].quorum);
		}
	}
	
    function vote(uint _proposalNumber, int8 _choice) {
		if (now > proposal[_proposalNumber].votingDeadline) {closeProposal(_proposalNumber);}	
		if (proposal[_proposalNumber].closed == false) {
		if (member[msg.sender].memberGroup == proposal[_proposalNumber].proposalGroup) {
					if (proposal[_proposalNumber].voters[msg.sender].alreadyVoted == false) {                
        				proposal[_proposalNumber].numberOfVotes += 1;    
						proposal[_proposalNumber].voters[msg.sender].alreadyVoted = true;  
			if (_choice == 1) {proposal[_proposalNumber].currentResult += 1; } 
			if (_choice == -1) {proposal[_proposalNumber].currentResult -= 1; }
        // Create a log of this event
        Voted(msg.sender, _proposalNumber, _choice, proposal[_proposalNumber].currentResult);
					}
					}
				}
			}

    function closeProposal(uint _proposalNumber) {           
        /* If difference between support and opposition is larger than margin */
		if (now > proposal[_proposalNumber].votingDeadline) {
		if (proposal[_proposalNumber].closed == false) {
        if ((proposal[_proposalNumber].numberOfVotes > proposal[_proposalNumber].quorumProposal) 
        		|| (proposal[_proposalNumber].currentResult > 0))
        {
            proposal[_proposalNumber].proposalPassed = true;
        } else {
            proposal[_proposalNumber].proposalPassed = false;
        }
        // Fire Events
        ProposalResult(_proposalNumber, proposal[_proposalNumber].currentResult, proposal[_proposalNumber].numberOfVotes, proposal[_proposalNumber].proposalPassed);
			}}}    
  
    function getProposal (uint _proposalNumber) constant returns ( address, uint, string, string, uint, uint) {
		if (now > proposal[_proposalNumber].votingDeadline) {closeProposal(_proposalNumber);}	
    	return (proposal[_proposalNumber].creator,
    			proposal[_proposalNumber].proposalGroup, 
    			proposal[_proposalNumber].title,
    			proposal[_proposalNumber].description, 
    			proposal[_proposalNumber].quorumProposal,
    			proposal[_proposalNumber].votingDeadline				
    			);
    }
	
	function getIfVoted (uint _proposalNumber, address _member) constant returns (bool) {
		return (proposal[_proposalNumber].voters[msg.sender].alreadyVoted);
	}
    
    function getProposalVotes (uint _proposalNumber) constant returns (uint, int, bool, bool) {
    	return (proposal[_proposalNumber].numberOfVotes, 
    			proposal[_proposalNumber].currentResult,
    			proposal[_proposalNumber].closed,
    			proposal[_proposalNumber].proposalPassed    			
    			);
    }	
	
}
