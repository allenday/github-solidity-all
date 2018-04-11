/*
This Token Contract implements the Peculium token (beta)
.*/

import "./MintableToken.sol";

pragma solidity ^0.4.8;

contract Peculium is MintableToken {

    /* Public variables of the token */
string public name = "Peculium"; //token name 
    	string public symbol = "PCL";
    	uint256 public decimals = 8;

	uint256 public constant NB_TOKEN = 20000000000; // number of token to create
        uint256 public constant MAX_SUPPLY_NBTOKEN   = NB_TOKEN*10**decimals;
	uint256 public bonus_Percent;
	// uint256 public constant START_ICO_TIMESTAMP   = 1501595111;
	uint256 public START_ICO_TIMESTAMP   = 1501595111; // not constant for testing 	(overwritten in the constructor) // Non constant pour les tests (reecrit dans le contructeur)
	using SafeMath for uint256;

	// Variable usefull for verifying that the assignedSupply matches that totalSupply // variable utile pour vérifier que le assignedSupply marche avec le totalSupply
	uint256 public assignedSupply;


	//Boolean to allow or not the initial assignement of token (batch) // Booléen qui autorise ou non le transfert initial de token (par lots)
	
	bool public batchAssignStopped = false;
	
	
	//constructeur de nos Tokens
	function PeculiumToken() {
		owner = msg.sender;
		uint256 amount = MAX_SUPPLY_NBTOKEN;
		uint256 amount2assign = amount * 25/ 100;
                balances[owner]  = amount2assign;
		
		
	}
	
	/**
   * @dev Transfer tokens in batches (of adresses)
   * @param _vaddr address The address which you want to send tokens from
   * @param _vamounts address The address which you want to transfer to
*/

	function buyTokens(address _vaddr, uint _vamounts) onlyOwner {
            require ( batchAssignStopped == false );
                     address toAddress = _vaddr;
                     uint amount = _vamounts* 10 ** decimals;
                    
                        assignedSupply += amount ;
                            balances[toAddress] += amount;
                   
           
    }


//fonction qui change le montant du bonus a modifier  pour que se soit automatique en fonction du temps pour que ca colle au white paper
    function setBonus(uint256 _bonus_Percent) onlyOwner{
            bonus_Percent=_bonus_Percent;
    }
    
    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }


         

  	function getBlockTimestamp() constant returns (uint256){
        	return now;
  	}


	function stopBatchAssign() onlyOwner {
      		require ( batchAssignStopped == false);
      		batchAssignStopped = true;
	}

	
	// fonction qui retourne le reste pecul de l'emmetteur 
  	function balanceOf(address _owner) constant returns (uint256 balance) {
    		return balances[_owner];
	}


  	function getOwnerInfos() constant returns (address owneraddr, uint256 balance)  {
    		owneraddr= owner;
		balance = balances[owneraddr];
		
  	}

  function killContract() onlyOwner { // fonction pour stoper le contract définitivement. Tout les ethers présent sur le contract son envoyer sur le compte du propriétaire du contract.
      selfdestruct(owner); // dépense beaucoup moins d'ether que simplement envoyer avec send les ethers au propriétaire car libére de la place sur la blockchain
  }


}
