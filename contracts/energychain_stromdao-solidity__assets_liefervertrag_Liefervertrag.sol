pragma solidity ^0.4.2;


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

/**
 * Vertragsabschlus via Blockchain
 * ========================================================
 * Author: thorsten.zoener(a)stromdao.de
 * 
 * Ein verhandelnder Vertrag ( [negotiated_contract] ) soll zwischen zwei Parteien ([partyA] und [partyB]) abgeschlossenen werden.
 * 
 * Ablauf:
 * 1. [partyA] legt die Verhandlung [Negotiation] an.
 * 2. [partyB] hat bis zum Ablauf der angegebenen Zeit [timeout], um das Angebot anzunehmen
 * 3. [partyA] Bestätigt, den Auftrag innerhalb der Zeit [timeout].
 * 
 * Verwendung:
 * NegotiationFactory.startNegotiation(partyB,negotiated_contract,timeout) returns Negotiation
 */
 
contract Negotiation {
    
    address public partyA;
    address public partyB;
    address public negotiated_contract;
    bool public partyA_sign=false;
    bool public partyB_sign=false;
    uint256 timeout=now;
    
    function Negotiation(address _partyA,address _partyB,address _negotiated_contract,uint256 _timeout_seconds) {
        negotiated_contract=_negotiated_contract;
        partyA=_partyA;
        timeout+=_timeout_seconds;
    }
    
    function becomePartyB() {
        if(address(0)==partyB) {
            partyB=msg.sender;
        } else throw;
    }
    
    function confirmAsPartyA(uint256 _timeout) {
        if(msg.sender!=partyA) throw;
        if(timeout<now) throw;
        if(!partyB_sign) {
            timeout+=_timeout;
        }
        partyA_sign=true;
    }
    
    function confirmAsPartyB(uint256 _timeout) {
        if(msg.sender!=partyB) throw;
        if(address(0)==partyB) throw;
        if(timeout<now) throw;
        if(!partyA_sign) {
            timeout+=_timeout;
        }
        partyB_sign=true;
    }
}

contract NegotiationFactory {
    
    function startNegotiation(address _partyB,address _negotiated_contract,uint256 _timeout_seconds) returns (Negotiation) {
        Negotiation negotiation = new Negotiation(msg.sender,_partyB,_negotiated_contract,_timeout_seconds);
        return negotiation;
    }
}

/**
 * Angebot Stromlieferung
 */
contract PowerDeliveryProposal {
    address public ersteller;                 //Anbieter Adresse
    uint256 public arbeitspreis;              //Arbeitspreis in 1/100 Cent je KWh
    uint256 public jahrespreis;               //Jahrespreis in Cent je Laufzeitjahr
    uint256 public ablauf;                    //Bindefrist des Angebotes
    string public plz;                        //Gütligkeit in Lieferort (Postleitzahl)
    string public ipfs;                       //IPFS Hash weitere Vertragsbedinungen
    
    function PowerDeliveryProposal(address _ersteller,uint256 _arbeitspreis,uint256 _jahrespreis,string _plz,uint256 _ablauf,string _ipfs) {
        arbeitspreis=_arbeitspreis;
        jahrespreis=_jahrespreis;
        plz=_plz;
        ablauf=now+_ablauf;
        ersteller=_ersteller;
        ipfs=_ipfs;
    }
}

contract PowerDeliveryProposalFactory {
    function deployPowerDeliveryProposal(uint256 _arbeitspreis,uint256 _jahrespreis,string _plz,uint256 _ablauf,string _ipfs) returns (PowerDeliveryProposal) {
        PowerDeliveryProposal proposal = new PowerDeliveryProposal(msg.sender,_arbeitspreis,_jahrespreis,_plz,_ablauf,_ipfs);
        return proposal;
    }
}

