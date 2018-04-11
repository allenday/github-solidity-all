pragma solidity ^0.4.2;

/**
 * Stromkonto der StromDAO (https://stromdao.de/stromkonto 
 * Author: thorsten.zoerner@stromdao.de
 * Deployment: 
        0xc3ef562cc403c8f9edf7c3826655fbf50f4ddde8 (StableBalancer) 
		0x3EC225d0Cd929148A1473C546C06dd1Ee9f558b1 (BalancerOracles)
 *
 * Beim StableBalancer werden für jede Ethereum Adresse zwei Summen geführt (Soll und Haben)
 * Jedes Oracle, welches beim BalancerOracles eingetragen ist, darf die Funktion "addTx" beim StableBalancer aufrufen.
 * Es ist nicht vorgesehen, dass die Ethereum Accounts direkt eine Transaktion ausführen können, sondern alle Transaktionen
 * durch die Oracle geschleift werden. 
 */

/* define 'owned' */
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

/*
 * StableBalance wird aktuell nicht mehr verwendet und ist rein zur Dokumentation weiter vorhanden
 */
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

/* StableBalancer
 * Eigentliches Stromkonto, welches durch die freigegebenen Oracles mit Transaktionen gefüllt werden können.
 * In der Transaktion https://etherscan.io/tx/0x3901af53ef25dc2e37e19df9258612644850eaf80bd36fa7fb83190c1a3d9f7a wurde 
 * die Ownership an 0x3EC225d0Cd929148A1473C546C06dd1Ee9f558b1 (BalancerOracles) übertragen. 
 */
contract StableBalancer is owned {
 
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

/* BalancerOracles
  Im Wirkbetrieb der StromDAO dürfen nur hier berechtigte Accounts eine Transaktion auf den Stromkonten (0xc3ef562cc403c8f9edf7c3826655fbf50f4ddde8) ausführen. Das Hinzufügen und Entfernen von Orakeln obliegt der StromDAO 
  als Owner (0xd87064f2ca9bb2ec333d4a0b02011afdf39c4fb0).
 */
contract BalancerOracles is owned {
    StableBalancer public balancer;
    event Tx(address _from,address _to, uint256 _value,string _txt);
    
    mapping (address => bool) public oracles;
    
    function BalancerOracle() {
        oracles[msg.sender]=true;
    }
	
    /* setBalancer(StableBalancer _balancer) onlyOwner
	 Setzen des zu verwendeten SmartContracts für die Führung der Stromkonten.      	 
	*/
	
    function setBalancer(StableBalancer _balancer) onlyOwner {
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

