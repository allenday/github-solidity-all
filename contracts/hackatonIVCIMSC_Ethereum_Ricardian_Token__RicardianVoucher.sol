pragma solidity ^0.4.11;

contract ricardianVoucher {
	// Generic Voucher Language https://tools.ietf.org/html/draft-ietf-trade-voucher-lang-07
	// The Ricardian Financial Instrument Contract http://www.systemics.com/docs/ricardo/issuer/contract.html
	
    // Owner of this smart contract
    address public owner;
  
    /* voucherToken MANAGEMENT */ 
	
    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    string public legalContract;
    string public logo;  				        // swarm hash of a voucher or voucherToken icon or logo
    uint public validity_start; 				// start date of the contract. Validity period of the voucher to redeem merchandises
    uint public validity_end; 					// end date of the contract. Provides restrictions on the validity period of the voucher
    
	function get () constant returns (uint _totalSupply, string _name, string _symbol, uint8 _decimals, string _logo, uint _validity_start, uint _validity_end) {
		return (totalSupply, name, symbol, decimals, logo, validity_start, validity_end);
	}

    /* Initializes voucherToken with initial supply voucherTokens to the creator of the contract */
    function ricardianVoucher(
        uint _totalSupply,
        string _name,
        uint8 _decimals,
        string _symbol,
        string _legalContract,
        string _logo,
        uint8 _validity_start_inDays, 					
        uint8 _validity_end_inDays 					    
        ) {
    	owner = msg.sender;
        balances[owner] = uint(totalSupply);       	    // Give the creator all initial voucherTokens
        totalSupply = _totalSupply;                     // Update total supply
        name = _name;                                   // Set the name for display purposes
        symbol = _symbol;                               // Set the symbol for display purposes
        decimals = _decimals; 							// Amount of decimals for display purposes
        legalContract = _legalContract;
        logo = _logo;
        validity_start = now + _validity_start_inDays * 1 days;
        validity_end = now + _validity_end_inDays * 1 days; 
    }
    
    // Balances for each account
    mapping(address => uint) balances; 
    
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;
    
    /* CONTRACT DETAILS */

    string[] merchandises; 						// Provides restrictions on the object to be claimed. Domain-specific meaning of the voucher
    string[] definitions; 						// Includes terms and definitions that generally desire to be defined in a contract
    string[] conditions; 						// Provides any other applicable restrictions
    
    /* write contract terms */
    // only the owner can write the contract terms
    // contract terms can only be written before circulation 
    
    function writeMerchandises (uint8 _number, string _merchandise) {
        if (msg.sender == owner) {
    	merchandises[_number] = _merchandise;
        }
    }
    function writeDefinitions (uint8 _number, string _definition) {
        if (msg.sender == owner) {
    	definitions[_number] = _definition;
        }
    }
    function writeConditions (uint8 _number, string _condition) {
        if (msg.sender == owner) {
    	conditions[_number] = _condition;
        }
    }
       
    /* VOUCHER CICULATION */  

    /* Send voucherTokens */
    function transfer(address _to, uint _amount) {
        if (balances[msg.sender] >= _amount && _amount > 0) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
        } 
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _amount amount.
    // If this function is called again it overwrites the current allowance with _amount.
     function approve(address _spender, uint _amount) {
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
    }
     
     // Send _amount amount of voucherTokens from address _from to address _to
     // The transferFrom method is used for a withdraw workflow, allowing contracts to send
     // voucherTokens on your behalf, for example to "deposit" to a contract address and/or to charge
     // fees in sub-currencies; the command should fail unless the _from account has
     // deliberately authorized the sender of the message via some mechanism; we propose
     // these standardized APIs for approval:
     function transferFrom(address _from, address _to, uint _amount) {
         //same as above. Replace this line with the following if you want to protect against wrapping uints.
         //if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && balances[_to] + _amount > balances[_to]) {
         if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0) {
             balances[_to] += _amount;
             balances[_from] -= _amount;
             allowed[_from][msg.sender] -= _amount;
             Transfer(_from, _to, _amount);
                      } 
     }
    
    /* PROVIDERS MANAGEMENT */
    
    // Providers
    struct providers {
        bool member;
    	string name; 			// the name you are normally known by in the street
        string country; 		// two letter ISO code that indicates the jurisdiction
        string registration; 	// legal registration code of the provider (legal person or legal entity)
        string legal; 			// swarm hash of the signer human readable registry document
        uint promise;
        bool promiseApproved;
        uint sales;
    }
    
    mapping(address => providers) provider;
    
    address[] providerIndex;
    
    function applyAsProvider (string _name, string _country, string _registration, string _legal) {
    	provider[msg.sender].name =_name; 
        provider[msg.sender].country =_country; 		
        provider[msg.sender].registration=_registration; 	
        provider[msg.sender].legal=_legal;
        ApplicationProvider(msg.sender, _name, now);
    }
    
    function approveProvider (address _provider) {
        if (msg.sender == owner && provider[msg.sender].member == false) {
    	provider[_provider].member = true;
    	providerIndex[providerIndex.length + 1] = _provider;
    	provider[_provider].promiseApproved = false;
    	ApproveProvider (_provider, provider[_provider].name, now);
        }
    }
    
    function makePromise (uint _promise) {
        if (provider[msg.sender].member == true && provider[msg.sender].promiseApproved == false) {
        provider[msg.sender].promise = _promise;
        MakePromise (msg.sender, _promise, now);
        }
    }
    
    function approvePromise (address _provider) {
        if (provider[_provider].member == true && provider[msg.sender].promiseApproved == false) {
        provider[_provider].promiseApproved = true;
        balances[_provider] += provider[msg.sender].promise;
        totalSupply += provider[msg.sender].promise;
        ApprovePromise (_provider, provider[_provider].promise, now);
        }
    }
  
 
    /* SALES MANAGEMENT */
    
    function redeem (address _provider, uint _value, string _billDescription) {
        if (provider[_provider].member == true) {
            if (balances[msg.sender] < _value) throw;   	
            balances[msg.sender] -= _value;            	
            provider[_provider].sales += _value;         	
            totalSupply -= _value;
            Redeem (msg.sender, _provider, _value, _billDescription, now);
            }
        }
    
    /* GET INFORMATION */
    
    // What is the balance of a particular account?
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

	function allowance(address _owner, address _spender) constant returns (uint remaining) {
	    return allowed[_owner][_spender];
	}
	
    function getProviderData (address _provider) constant returns  (bool _member, string _name, string _country, string _registration, string _legal) {
        return (provider[_provider].member,
                provider[_provider].name,
                provider[_provider].country,
                provider[_provider].registration,
                provider[_provider].legal
        );
    }
    
    function getProviderSales (address _provider) constant returns  (bool _member, string _name, uint _promise, bool _promiseApproved, uint _sales) {
        return (provider[_provider].member,
                provider[_provider].name,
                provider[_provider].promise,
                provider[_provider].promiseApproved,
                provider[_provider].sales
        );
    }
    /* EVENTS */
	
    /* This generates public events on the blockchain that will notify clients */
    
    // Triggered when voucherTokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint _value);

     // Triggered whenever approve(address _spender, uint _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
    event ApplicationProvider (address indexed _from, string _name, uint _timestamp);
	
	event ApproveProvider (address _provider, string _name, uint _timestamp);
	
	event MakePromise (address indexed _provider, uint _promise, uint _timestamp);
    
    event ApprovePromise (address indexed _provider, uint _promise, uint _timestamp);
    
    event Redeem (address _customer, address _provider, uint _sale, string _billDescription, uint _timestamp);
    
    /* OVERALL */
    

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}