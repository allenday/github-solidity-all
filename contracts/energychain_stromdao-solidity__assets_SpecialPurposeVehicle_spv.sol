pragma solidity ^0.4.9;

contract owned {
     address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }



contract StableBalance is owned {
 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Tx(address _to, uint256 _value,string _txt);
    
    mapping (address => uint256) balances;
    
    function transfer(address _to, uint256 _value) returns (bool success) { return false; throw;}
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    function addTx(address _to, uint256 _value,string _txt) onlyOwner {
        balances[_to]+=_value;
        Tx(_to,_value,_txt);
    }
    
}
contract Stromkonto is owned {
 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Tx(address _from,address _to, uint256 _value,string _txt);
    
    mapping (address => uint256) balancesHaben;
    mapping (address => uint256) balancesSoll;
    
    function transfer(address _to, uint256 _value) returns (bool success) { return false; throw;}
    
    function balanceHaben(address _owner) constant returns (uint256 balance) {
        return balancesHaben[_owner];
    }
    
    function balanceSoll(address _owner) constant returns (uint256 balance) {
        return balancesSoll[_owner];
    }
    
    function addTx(address _from,address _to, uint256 _value,string _txt) onlyOwner {
        balancesSoll[_from]+=_value;
        balancesHaben[_to]+=_value;
        Tx(_from,_to,_value,_txt);
    }
    
}

contract BalancerOracles is owned {
    Stromkonto public balancer;
    event Tx(address _from,address _to, uint256 _value,string _txt);
    
    mapping (address => bool) public oracles;
    
    function BalancerOracle() {
        oracles[msg.sender]=true;
    }
    
    function setBalancer(Stromkonto _balancer) onlyOwner {
        balancer=_balancer;
    }
    
    function balanceHaben(address _owner) constant returns (uint256 balance) {
        return balancer.balanceHaben(_owner);
    }
    
    function balanceSoll(address _owner) constant returns (uint256 balance) {
        return balancer.balanceSoll(_owner);
    }
    
    function addTx(address _from,address _to, uint256 _value,string _txt)  {
        if(oracles[msg.sender]==true) {
            balancer.addTx(_from,_to,_value,_txt);
            Tx(_from,_to,_value,_txt);
        } else {
            throw;
        }
    }
    
    function transferOracleOwnership(address _owner) onlyOwner {
        balancer.transferOwnership(_owner);
    }
    
    function addOracle(address _oracle) onlyOwner {
        oracles[_oracle] = true;
    }
    
    function removeOracle(address _oracle) onlyOwner {
        oracles[_oracle] = false;
    }
}

contract StableStore {
    
    mapping (address => string) public store;
    
    function setValue(string _value) {
        store[msg.sender]=_value;
    }
}

contract StableAddressStore {
    mapping (address => mapping(address=>string)) public store;
    
    function setValue(address key,string _value) {
        store[msg.sender][key]=_value;
    }
}

contract StableTxStore {
    mapping (address => mapping(address=>tx)) public store;
    
    struct tx {
        uint256 amount;
        uint256 repeatMinutes;
        uint256 repeatTimes;
    }
    
    function setValue(address key,uint256 amount,uint256 repeatMinutes,uint256 repeatTimes) {
        store[msg.sender][key]=tx(amount,repeatMinutes,repeatTimes);
    }
}


/** Special Purpose Vehicle - Contract der StromDAO (https://stromdao.de/)
 * Author: thorsten.zoerner(at)stromdao.de
 * Deployment: 
 *
 * Ein Special Purpose Vehicle ist eine Zweckgesellschaft, die lediglich festschreibt, wie Einnahmen unter den Anteilseignern aufgeteilt werden.
 *
 * Bei der Umsetzung der StromDAO wird das Stromkonto zur Verbuchung der Gutschriften verwendet. 
 * Eigentümer (owner) ist das Orakel, welches die Einnahmen erkennt und !eine! Transaktion auslöst
 * Der SPV-Contract verteilt diesen dann auf die einzelnen Stromkonten
 * 
 * Benötigt eine Freigabe des SPV-Vertrages im Balancer! ( 0xc3ef562cc403c8f9edf7c3826655fbf50f4ddde8:BalancerOracles.addOracle() )
 * 
 * Setup:
  => Eigentümer der Anlage legt neuen SPV() Vertrag an
  => Eigentümer verwendet SPV.transfer() um Eigentumsanteile zu verteilen
  => Eigentümer setzt Orakel als Einnahmenquelle
  => Eigentümer setzt Stromkonto (Smart Contract) für Verrechnung
 
 * Wirkbetrieb:
  => Orakel ruft SPV.addTx() auf mit dem Betrag, der verteilt werden soll
  => SPV.addTX() ermittelt die Gutschrift der einzelnen Besitzer
  => SPV.addTX() verteilt entsprechend und verbucht direkt im Stromkonto

 * Bedingungen:
   => SPV muss beim Stromkonto hinterlegt sein als zulässiges Oracle (erlaubt Stromkonto.addTX aufzurufen)

 * Implementiert einen ERC-20 Token
 */

contract SPV {
     /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name='SPV';
    string public symbol='/';
    uint8 public decimals=2;
    uint256 public totalSupply;
    address public oracle;
    uint8 private min_muxamount=100;
    uint256 public num_shareholders=0;
    
    Stromkonto public stromkonto;
    address public supervisor;
    

    address[] public shareholders;
    
    /* This creates a map with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => uint256) public bufferOf; //buffered Amount before demux
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event TXin(uint256 amount);
    event TXout(uint256 amount,address to);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    
    function SPV(
        uint256 initialSupply,
        Stromkonto _stromkonto 
        ) {
       
       balanceOf[msg.sender] = initialSupply;   // Give the creator all initial tokens

        totalSupply = initialSupply;             // Update total supply
        stromkonto=_stromkonto;
        supervisor=msg.sender;
        addShareholder(supervisor);
    }

    /* Send coins */
    
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        /* Check if we already know this shareholder from past - if not add this one */
        
        address sh = shareholders[shareholders.length++];
        sh=_to;
        
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
        
    }
    

    function setOracle(address _oracle)  {
        if(msg.sender!=supervisor) throw;
        oracle=_oracle;
    }
    
    function transferSupervisor(address _new_supervisor) {
        if(msg.sender!=supervisor) throw;
        supervisor=_new_supervisor;
    }
  
    /* Removed for Test Szenario
    function setBufferAmount(uint256 _value) onlyOwner {
        min_muxamount=_value;
    }

    */
    
    function addTx(uint256 amount) {
        if(msg.sender!=oracle) throw;
        if(amount<totalSupply) throw;
        
        mapping (address => uint256) txMapping;
        TXin(amount);
        for(var i=0;i<shareholders.length;i++) {
            txMapping[shareholders[i]]=balanceOf[shareholders[i]];
        }   
        for(var j=0;j<shareholders.length;j++) {
            var share_amount=amount*(txMapping[shareholders[j]]/totalSupply);
            txMapping[shareholders[j]]=0;
            //=> Transfer the share_amount
            if(share_amount>0) {
                
                bufferOf[shareholders[j]]+=share_amount;
                if(bufferOf[shareholders[j]]>min_muxamount) {
                    //StableBalance kto = (StableBalance) stromkonto;
                    stromkonto.addTx(this,shareholders[j],bufferOf[shareholders[j]],'SPV');
                    TXout(bufferOf[shareholders[j]],shareholders[j]);
                    bufferOf[shareholders[j]]=0;
                }
                
            }
        }
        
    }


    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
    
    function addShareholder(address _shareholder)  {
        if(msg.sender!=supervisor) throw;
        address sh = shareholders[shareholders.length++];
        sh=_shareholder;
        //num_shareholders++;
    }
    
}

