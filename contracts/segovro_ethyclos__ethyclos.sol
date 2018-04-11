pragma solidity ^0.4.6;

contract ethyclos {

        // @title ethyclos
        // @author Rogelio SEGOVIA
		// @param sysAdmin is the system administrator address, the creator of
		// the contract

		address public sysAdmin;   
		uint nrMembers;
		uint nrCommunities;
		uint nrProposals;
	
	// @notice at creating the contract we declare the general variables
	function ethyclos() {
				// @param the initial sysAdmin is the address from which the
				// contract is created
				sysAdmin = msg.sender;
			    nrMembers = 0;
			    nrCommunities = 0;
			    nrProposals = 0;
        }
	
    function getTotals () constant returns (uint, uint, uint) {
    	return (nrMembers, nrCommunities, nrProposals);
    }
	
	event NewMember (address indexed _memberAddress, string _memberAlias, string _narrative, uint _TimeStamp);
	event NewCommunity(address indexed _creator, uint indexed _communityID);
	event ModifyCommunity (address indexed _modifier, uint indexed _communityID, uint _TimeStamp);
	event JoinCommunity (address _member, string _alias, uint _communityID, string _communityName, uint _TimeStamp);
	event ResignCommunity (address _member, string _alias, uint _communityID, string _communityName, uint _TimeStamp);

	// @notice function to name a new sysAdmin
    function transferSysAdmin(address newSysAdmin) {
		if (msg.sender == sysAdmin) {
        sysAdmin = newSysAdmin;
		}
    }
	
	// @notice create a structure to file all members
	struct Members {
		// @parameter key ID parameters
		bool isMember;
		string alias;
		string whisperID;
		string memberDescription;
		string mImagelink;
		uint memberCommunity;	
		bool isBank;
		bool isCommune;
		// @parameter balance is expressed in the member currency. Can only be
		// modified by system operations
		int balance;
		uint trust;
		int reputation;
		address moneyLender; 
		uint creditTrust;
		uint creditLine;
		uint creditDeadline;
		uint lastTransaction;
	}
	
	// @notice map the members structure into an array indexed by the members
	// ethereum address
	mapping(address => Members) member;
	
	// @notice create an index of members for listing purposes
	address[] memberIndex;
	
	// @notice anybody with an ethereum account can register in the system
	function registerSystem (string _alias, string _whisperID, string _narrative, string _imageLink) {
		// @notice the caller provides a valid alias
		if (bytes(_alias).length != 0) {
		// @notice the caller is not already the system
			if (member[msg.sender].isMember != true) {
			member[msg.sender].isMember = true;
			member[msg.sender].alias = _alias;
			member[msg.sender].whisperID = _whisperID;
			member[msg.sender].memberDescription = _narrative;
			member[msg.sender].mImagelink = _imageLink;
			member[msg.sender].memberCommunity = 0;
			member[msg.sender].isBank = false;
			member[msg.sender].isCommune = false;
			member[msg.sender].balance = 0;
			member[msg.sender].reputation = 0;
			member[msg.sender].trust = 0;			
			member[msg.sender].creditLine = 0;
			member[msg.sender].creditDeadline = 0;	
			member[msg.sender].lastTransaction = now;
		NewMember (msg.sender, _alias, _narrative, now);
		memberIndex[memberIndex.length ++] = msg.sender;
		nrMembers ++;
				} 
			} 
		}
	
	function modifyMemberInfo (string _alias, string _whisperID, string _narrative, string _imageLink) {
		if (bytes(_alias).length != 0) {member[msg.sender].alias = _alias;}
		if (bytes(_whisperID).length != 0) {member[msg.sender].whisperID = _whisperID;}
		if (bytes(_narrative).length != 0) {member[msg.sender].memberDescription = _narrative;}
		if (bytes(_imageLink).length != 0) {member[msg.sender].mImagelink = _imageLink;}
		}
	
	// @notice anybody in the system can join a community if the community is
	// open
	function joinCommunity (uint _communityID) {
					// @notice if the community is open
					if (community[_communityID].open = true) {
						makeMemberOfCommunity (msg.sender, _communityID);
					} 
					// @notice if the community is not open "proposeNewMember"
	}
	
	function acceptAtCommunity ( address _newMember, uint _communityID) {
		// @notice the commune can accept a new member in the community
		if (community[_communityID].commune == msg.sender) {
			makeMemberOfCommunity (_newMember, _communityID);	
		}
	}
	
	function makeMemberOfCommunity (address _newMember, uint _communityID) internal {
		// @notice the member is in the system
		// @notice the member is not in a community
		if ((member[_newMember].isMember = true) && (member[_newMember].memberCommunity == 0)) {
		member[_newMember].memberCommunity = _communityID;
		member[_newMember].balance = 0;
		member[_newMember].creditLine = community[_communityID].defaultCreditLine;
		member[_newMember].trust = community[_communityID].defaultTrust;		
		community[_communityID].nrMembers ++;
		JoinCommunity (_newMember, member[_newMember].alias, _communityID, community[_communityID].communityName, now);
		}
	}
	
	function resignFromCommunity () {
				uint _communityID = member[msg.sender].memberCommunity; 
				// @notice balance cannot be negative
				if (member[msg.sender].balance >= 0) {
					deleteMemberOfCommunity (msg.sender, _communityID);
				}
			}	
	
	function kickOutCommunity (address _memberOfCommunity, uint _communityID) {
		// @notice the commune can delete a new member in the community
		if (community[_communityID].commune == msg.sender) {
			deleteMemberOfCommunity (_memberOfCommunity, _communityID);
		}
	}
	
	function deleteMemberOfCommunity (address _memberOfCommunity, uint _communityID) internal {
		// @notice the account is not a community account and the member is not
		// commune of the community
		if ((member[_memberOfCommunity].isCommune == false) && (member[msg.sender].isCommune == false)) {
		member[community[_communityID].commune].balance += member[_memberOfCommunity].balance;
		member[_memberOfCommunity].balance = 0;
		member[_memberOfCommunity].memberCommunity = 0;
		member[_memberOfCommunity].creditLine = 0;
		member[_memberOfCommunity].trust = 0;
		community[_communityID].nrMembers --;
		ResignCommunity (_memberOfCommunity, member[_memberOfCommunity].alias, _communityID, community[_communityID].communityName, now);		
		}
	}
	
	function like (address _member) {
		if (member[msg.sender].memberCommunity == member[_member].memberCommunity) {
		member[_member].reputation ++;
		}
	}
	
	function notLike (address _member) {
		if (member[msg.sender].memberCommunity == member[_member].memberCommunity) {
		member[_member].reputation --;
		}
	}

	function getMemberInfo (address _member) constant returns (bool, string, string, uint) {
	    return (member[_member].isMember, member[_member].alias, member[_member].memberDescription, member[_member].memberCommunity);
	}
	
	function getMemberWallet (address _member) constant returns (int, uint, uint, int, uint) {
		return (member[_member].balance, member[_member].creditLine, member[_member].trust, member[_member].reputation, member[_member].lastTransaction);
	}
	
	function getMemberCredit (address _member) constant returns (address, uint, uint, uint) {
		return (member[_member].moneyLender, member[_member].creditTrust, member[_member].creditLine, member[_member].creditDeadline);
	}
	
	function getMemberStatus (address _member) constant returns (bool, bool) {
	   return (member[_member].isBank, member[_member].isCommune);
	}
	
	function getMemberLinks (address _member) constant returns (string, string) {
	   return (member[_member].whisperID, member[_member].mImagelink);
	}
			
	function getMPbyIndex (uint _mIndex) constant returns (address _getMemberID) {
		_getMemberID = memberIndex[_mIndex];
	}
	
    // @notice create a structure to file all communities and their parameters
    struct Communities {
    	string communityName;
    	string communityDescription;
    	string currencyName;
    	string cImageLink;
    	address commune;
    	address communityBank;
    	// @parameter the bank exchangeRate against the base currency is given in
		// percentage (100 = 1/1)
    	uint exchangeRate;
    	uint transferTax;
    	uint accumulationTax;
    	uint importTax;
    	uint creditRewardRate;
    	uint defaultCreditLine;
    	uint defaultTrust;	
    	bool open;
    	uint nrMembers;
    	uint quorum; 	
    }

    mapping(uint => Communities) community;
    
    // @notice create an index of banks for listing purposes
    uint[] communityIndex;
    
    // @notice A community can be created by any account in the system that is
	// not in a community.
    // @notice A community is also an account and is identified by its account
	// number.
    // @notice A community has two special members:
    // @notice the bank account holding the external balance against other
	// communities
    // @notice the commune account holding the community common moneys, such as
	// taxes
    function createCommunity (string _communityName, string _narrative, string _currencyName, string _cImageLink, uint _exchangeRate, uint _creditRewardRate, uint _defaultCreditLine, uint _defaultTrust, bool _open, uint _quorum, uint _bankCreditLine, uint _bankTrust) {
    	// @notice the member exists in the system and the member is not in a
		// community and the name is valid
    	if (member[msg.sender].isMember = true) {
    		if (member[msg.sender].memberCommunity == 0) { 
    				if (bytes(_communityName).length != 0) {
    					uint _communityID = now;	
    					community[_communityID].communityName = _communityName;
    	    			community[_communityID].communityDescription = _narrative;
    	    			community[_communityID].currencyName = _currencyName;
                        community[_communityID].cImageLink = _cImageLink;
                        community[_communityID].commune = msg.sender;
                        community[_communityID].communityBank = msg.sender;
    	    			community[_communityID].exchangeRate = _exchangeRate;
    	    			community[_communityID].creditRewardRate = _creditRewardRate;
    	    			community[_communityID].defaultCreditLine = _defaultCreditLine;
    	    			community[_communityID].defaultTrust = _defaultTrust;
    	    			community[_communityID].open = false;
    	    			community[_communityID].nrMembers = 1;
    	    			community[_communityID].quorum = _quorum;
                        	// @notice make the creator member of the community
							// and set the community bank limits
    						member[msg.sender].memberCommunity = _communityID;
    						member[msg.sender].isBank = true;
    						member[msg.sender].isCommune = true;
    						member[msg.sender].balance = 0;
    						member[msg.sender].creditLine = _bankCreditLine;
    						member[msg.sender].trust = _bankTrust;
    					communityIndex[communityIndex.length ++] =_communityID;
    					nrCommunities = nrCommunities +1;
    					NewCommunity(msg.sender, _communityID);
    				} 
    			}
    	    } 
    	} 

    // @notice transfer community bank account. Old bank or sysAdmin can
	// transfer community bank to another member of the community
    // @notice the reason to include sysAdmin is for the case the old commune
	// disappears
    function transferCommunityBank (uint _communityID, address _newBank) {
    	address _oldBank = community[_communityID].communityBank;    
    	if ((msg.sender == _oldBank) || (msg.sender == sysAdmin)) {
    		if (member[_newBank].memberCommunity == _communityID) {
	    			member[_newBank].creditLine = member[_oldBank].creditLine;
	    			member[_newBank].trust = member[_oldBank].trust;
	    			member[_newBank].isBank = true;
	    			member[_oldBank].creditLine = community[_communityID].defaultCreditLine;
	    			member[_oldBank].trust = community[_communityID].defaultTrust;
	        		member[_oldBank].isBank = false;
	        		community[_communityID].communityBank = _newBank;
    			string _communityName = community[_communityID].communityName;
    			ModifyCommunity (msg.sender, _communityID, now);
    	} 
    	} 
    }
    
    // @notice transfer community commune. Old commune or sysAdmin can transfer
	// community commune to another member of the community
    // @notice the reason to include sysAdmin is for the case the old commune
	// disappears
    function transferCommunityCommune (uint _communityID, address _newCommune) {
    	address _oldCommune = community[_communityID].commune;
    	if ((msg.sender == _oldCommune) || (msg.sender == sysAdmin)) {
    		if (member[_newCommune].memberCommunity == _communityID) {
	    			member[_newCommune].creditLine = member[_oldCommune].creditLine;
	    			member[_newCommune].trust = member[_oldCommune].trust;
	    			member[_newCommune].isCommune = true;
	    			member[_oldCommune].creditLine = community[_communityID].defaultCreditLine;
	    			member[_oldCommune].trust = community[_communityID].defaultTrust;
	        		member[_oldCommune].isCommune = false;
    			string _communityName = community[_communityID].communityName;
    			ModifyCommunity (msg.sender, _communityID, now);
    	} 
    	} 
    }
    	
    // @notice the commune can modify one, several or all parameters of a
	// community. If one parameter is left empty, it remains the same. Only the
	// bank commune can change its parameters
    function modifyCommunityInfo (uint _communityID, string _communityName, string _narrative, string _currencyName, string _cImageLink) {
    	        address _commune = community[_communityID].commune;
    	        if (msg.sender == _commune) {
    			// @notice if a value for a parameter is given, change the
				// parameter, if empty retain old value
    			if (bytes(_communityName).length != 0) {community[_communityID].communityName = _communityName;}
    			if (bytes(_narrative).length != 0) {community[_communityID].communityDescription = _narrative;}
    			if (bytes(_currencyName).length != 0) {community[_communityID].currencyName = _currencyName;} 
    			if (bytes(_cImageLink).length != 0) {community[_communityID].cImageLink = _cImageLink;} 
    			ModifyCommunity (msg.sender, _communityID, now);				
    				}     					
    }
    
    function modifyCommunityRates (uint _communityID, uint _exchangeRate, uint _creditRewardRate, uint _defaultCreditLine, uint _defaultTrust, bool _open, uint _quorum, uint _bankCreditLine, uint _bankTrust) {
    	        address _commune = community[_communityID].commune;
    	        address _bank = community[_communityID].communityBank;
    	        if (msg.sender == _commune) {
    			// @notice if a value for a parameter is given, change the
				// parameter, if empty retain old value
				if (_exchangeRate != 0) {community[_communityID].exchangeRate = _exchangeRate;}
				if (_creditRewardRate != 0) {community[_communityID].creditRewardRate = _creditRewardRate;}
    			if (_defaultCreditLine != 0) {community[_communityID].defaultCreditLine = _defaultCreditLine;} 
    			if (_defaultTrust != 0) {community[_communityID].defaultTrust = _defaultTrust;}
    			if (_bankCreditLine != 0) {member[_bank].creditLine = _bankCreditLine;}
    			if (_bankTrust != 0) {member[_bank].trust = _bankCreditLine;}
    			if (_open == false) {community[_communityID].open = false;} 
    			if (_quorum != 0) {community[_communityID].quorum = _quorum;} 
    			ModifyCommunity (msg.sender, _communityID, now);				
    				}     					
    }
    
    function modifyCommunityTaxes (uint _communityID, uint _transferTax, uint _accumulationTax, uint _importTax) {
    	        address _commune = community[_communityID].commune;
    	        address _bank = community[_communityID].communityBank;
    	        if (msg.sender == _commune) {
    			// @notice if a value for a parameter is given, change the
				// parameter, if empty retain old value
    			if (_transferTax != 0) {community[_communityID].transferTax = _transferTax;} 
    			if (_accumulationTax != 0) {community[_communityID].accumulationTax = _accumulationTax;} 
    			if (_importTax != 0) {community[_communityID].importTax = _importTax;} 
    			ModifyCommunity (msg.sender, _communityID, now);				
    				}     					
    }
    
    function getCommunityDescription (uint _communityID) constant returns (string, string, string, string, bool, uint) {
    return (community[_communityID].communityName, community[_communityID].communityDescription, community[_communityID].currencyName, community[_communityID].cImageLink, community[_communityID].open, community[_communityID].nrMembers);
    }
    
    function getCommunityRates (uint _communityID) constant returns (uint, uint, uint) {
    return (community[_communityID].exchangeRate, community[_communityID].defaultCreditLine, community[_communityID].defaultTrust);
    }
    
    function getCommunityTaxes (uint _communityID) constant returns (uint, uint, uint) {
    return (community[_communityID].transferTax, community[_communityID].accumulationTax, community[_communityID].importTax);
    }
    
    function getCommunityManagement (uint _communityID) constant returns (address, address) {
    return (community[_communityID].communityBank, community[_communityID].commune);
    }    
   
    function getCommunitybyIndex (uint _gIndex) constant returns (uint _getCommunityID) {
    	_getCommunityID = communityIndex[_gIndex];
    }
    
    event Transfer (string _concept, uint indexed _communityID, address indexed _sender, address indexed _receiver, uint _amount, uint _TimeStamp);
    event Credit (address indexed _MoneyLender, address indexed _borrowerAddress, uint _cDealine, uint _endorsedUoT);
    event CreditExp (address indexed _moneyLender, address indexed _borrower, uint _creditCost, bool _success, uint _TimeStamp);

	// @notice function transfer from the member of the same bank or to the
	// member of another bank. The amount is expressed in the sender
	// currency
	function payment (address _to, uint _amount) external {		
		address _from = msg.sender;
		uint _toAmount = _amount;
		payAccTax (_amount);
		// @notice check if both accounts are in the same community
		if (member[msg.sender].memberCommunity == member[_to].memberCommunity) {
			transfer ("pay", _from, _to, _amount);
			payTrnsTax (_to, _amount);
		} else {
			exchange (_from, _to, _amount);
			}
		}
	
	function transfer (string _concept, address _from, address _to, uint _amount) internal {
		int _intAmount = int(_amount);
		if ((member[_from].balance - _intAmount) > - int((member[_from].creditLine)))  { 
			member[_from].balance -= _intAmount;
			member[_to].balance += _intAmount;
			Transfer (_concept, member[msg.sender].memberCommunity, msg.sender, _to, _amount, now);
		}
	}
		
	function exchange (address _from, address _to, uint _amount) internal {		
		address _fromExchange = community[member[_from].memberCommunity].communityBank;
		address _toExchange = community[member[_to].memberCommunity].communityBank;
		Transfer ("exchange", member[_from].memberCommunity, _from, _to, _amount, now);
		transfer ("exchangeOUT", _from, _fromExchange, _amount);
		uint _exchangeRateFrom = community[member[_from].memberCommunity].exchangeRate;
		uint _exchangeRateTo = community[member[_from].memberCommunity].exchangeRate;
		uint _amountTo = _amount * _exchangeRateFrom/_exchangeRateTo;
		int _intAmountFrom = int(_amount);
		int _intAmountTo = int(_amountTo);
		if ((member[_fromExchange].balance - _intAmountFrom) > - int((member[_fromExchange].creditLine)))  { 
			member[_fromExchange].balance -= _intAmountFrom;
			member[_toExchange].balance += _intAmountTo;
		}
		transfer ("exchangeIN", _toExchange, _to, _amountTo);
		payImportTax (_to, _amountTo);		
	}
	
	function payAccTax (uint _amount) internal {
		uint _communityID = member[msg.sender].memberCommunity;
		address _commune = community[_communityID].commune;
		uint _timeYears = (now - member[msg.sender].lastTransaction)/(1 years);
		uint _taxRate = community[_communityID].accumulationTax;
		if (member[msg.sender].balance > 0) {
			uint _tax = uint(member[msg.sender].balance) * _taxRate * _timeYears / 100;
			} else {
				_tax = 0;
			}
		member[msg.sender].lastTransaction = now;
		transfer ("capitalTax", msg.sender, _commune,  _tax);
	}
	
	function payTrnsTax (address _to, uint _amount) internal {
		uint _communityID = member[_to].memberCommunity;
		address _commune = community[_communityID].commune;
		uint _taxRate = community[_communityID].transferTax;
		uint _tax = _amount * _taxRate / 100;
		transfer ("vatTax", _to, _commune,  _tax);	
	}
	
	function payImportTax (address _to, uint _amount) internal {
		uint _communityID = member[_to].memberCommunity;
		address _commune = community[_communityID].commune;
		uint _taxRate = community[_communityID].importTax;
		uint _tax = _amount * _taxRate / 100;
		transfer ("importTax", _to, _commune,  _tax);	
	}
	
	// @notice function authorize a credit
	// @notice only members of a group can authorize or get a credit to a member
	// of the same group
	// @param _borrower is the address of the credit borrower
	// @param _credit is the amount of the credit line
	// @param _daysAfter is the deadline of the credit line in number of days
	// from today
	function endorseCredit (address _borrower, uint _credit, uint _daysAfter)  {
		if (member[msg.sender].memberCommunity == member[_borrower].memberCommunity) {
			uint _communityID = member[msg.sender].memberCommunity;
			updateCredit (_borrower); 	
		if (member[_borrower].creditLine > 0) {cancelCredit (_borrower);}
			uint _unitsOfTrust = _credit * _daysAfter;
			if (member[msg.sender].trust > _unitsOfTrust) {
				member[msg.sender].trust -= _unitsOfTrust;
				member[_borrower].creditLine += _credit;
				member[_borrower].moneyLender = msg.sender;
				// @notice the _deadline is established as a number of days
				// ahead
				uint _creditDeadline = now + _daysAfter * 1 days; 
				member[_borrower].creditDeadline = _creditDeadline; 
				member[_borrower].creditTrust = _unitsOfTrust;
				Credit(msg.sender, _borrower, _creditDeadline, _unitsOfTrust);		
			}
		}
	}
	
	function cancelCredit (address _borrower) internal {
		uint _communityID = member[_borrower].memberCommunity;
		uint _credit = member[_borrower].creditLine;
		address _moneyLender = member[_borrower].moneyLender;
		uint _unitsOfTrust = member[_borrower].creditTrust;
		member[_moneyLender].trust += _unitsOfTrust;
		member[_borrower].creditLine = 0;
		member[_borrower].creditDeadline = 0;	
	}
	
	function updateCredit (address _borrower) internal {
		uint _communityID = member[_borrower].memberCommunity;
		// @notice update the credit status
		if (member[_borrower].creditLine > 0) {
		// @notice check if deadline is over
			if (now >= member[_borrower].creditDeadline) {
				bool _success = false;
				uint _credit = member[_borrower].creditLine;
				uint _creditTrust = member[_borrower].creditTrust;
				uint _reward = _creditTrust * community[_communityID].creditRewardRate/100;
				address _moneyLender = member[_borrower].moneyLender;
			// @notice if time is over reset credit to zero, deadline to zero
				member[_borrower].creditDeadline = 0;
				member[_borrower].creditLine = 0;				
				// @notice if balance is negative the credit was not returned,
				// the money lender balanceReputation is not restored and is
				// penalized with a 20%
				// @notice as regards the borrower will not be able to make any
				// new transfer until future incomes cover the debts
				// @return money lender reputation penalized
				if (member[_borrower].balance < 0) {					
					member[_moneyLender].trust += _creditTrust - _reward;
				}
				// @notice if balance is not negative the credit was returned,
				// the money lender balanceReputation is restored and is
				// creditRewarded
				// @return money lender reputation rewarded
				else {
					_success = true;
					member[_moneyLender].trust += _creditTrust + _reward;
				}
				// @notice reset money lender information
				// @return money lender information deleted
				// @notice close access to monitor the account to money lender
				member[_borrower].moneyLender = _borrower; 
				member[_borrower].creditTrust = 0;
				CreditExp(_moneyLender, _borrower, _creditTrust , _success, now);
				} 
			}
		}	
  
    
    event ProposalAdded(uint proposalNumber, uint community, string narrative, address creator);
    event Voted(address voter, uint proposalNumber, int8 vote, int result);
    event ProposalResult(uint proposalNumber, int result, uint quorum, bool active);
	
    struct Proposals {
		address creator;
    	uint proposalCommunity;
    	string title;
        string narrative;
        uint votingDeadline;
        uint quorumProposal;
        bool ended;
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
    function newProposal (uint _proposalCommunity, string _title, string _narrative, uint _days, uint _quorum) {   
        nrProposals ++;
        uint proposalNumber = nrProposals;
		proposal[proposalNumber].creator = msg.sender;
        proposal[proposalNumber].proposalCommunity = _proposalCommunity;
        proposal[proposalNumber].title = _title;
        proposal[proposalNumber].narrative = _narrative;
        proposal[proposalNumber].votingDeadline = now + _days * 1 days;
        proposal[proposalNumber].quorumProposal = _quorum;
        proposal[proposalNumber].ended = false;
        proposal[proposalNumber].proposalPassed = false;
        proposal[proposalNumber].numberOfVotes = 0;
        proposal[proposalNumber].currentResult = 0;
		proposal[proposalNumber].voters[msg.sender].alreadyVoted = false; 		
        ProposalAdded(proposalNumber, _proposalCommunity, _narrative, msg.sender);
    }
	
	function proposeAcceptanceAsMember (uint _candidateCommunity) {
		if (member[msg.sender].isMember = true) {
		newProposal (_candidateCommunity, "Accept Member", member[msg.sender].memberDescription, 10, community[_candidateCommunity].quorum);
		}
	}
	
    function vote(uint _proposalNumber, int8 _choice) {
		if (now > proposal[_proposalNumber].votingDeadline) {closeProposal(_proposalNumber);}	
		if (proposal[_proposalNumber].ended == false) {
		if (member[msg.sender].memberCommunity == proposal[_proposalNumber].proposalCommunity) {
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
		if (proposal[_proposalNumber].ended == false) {
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
  
    function getProposal (uint _proposalNumber) constant returns (uint, string, string, uint, uint, address) {
		if (now > proposal[_proposalNumber].votingDeadline) {closeProposal(_proposalNumber);}	
    	return (proposal[_proposalNumber].proposalCommunity, 
    	        proposal[_proposalNumber].title, 
    			proposal[_proposalNumber].narrative, 
    			proposal[_proposalNumber].quorumProposal,
    			proposal[_proposalNumber].votingDeadline,
				proposal[_proposalNumber].creator
    			);
    }
	
	function getIfVoted (uint _proposalNumber, address _member) constant returns (bool) {
		return (proposal[_proposalNumber].voters[msg.sender].alreadyVoted);
	}
    
    function getProposalVotes (uint _proposalNumber) constant returns (uint, int, bool, bool) {
    	return (proposal[_proposalNumber].numberOfVotes, 
    			proposal[_proposalNumber].currentResult,
    			proposal[_proposalNumber].ended,
    			proposal[_proposalNumber].proposalPassed    			
    			);
    }	
    
}
