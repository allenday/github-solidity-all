pragma solidity ^0.4.10;

//Copyright 2017 Loopius Software UG (haftungsbeschraenkt)
//Author: Dr. Christopher De Nicolo


contract Mediation  {
   
    mapping (address => Mediator) public mediators;
    mapping(uint8 => address) mediatorByIndex;
    mapping (address => Client) public clients;
    mapping(uint8 => address) clientByIndex;
    
    address owner;
    address nominated_mediator;
    address administrator;
    uint fee; 
    
     
    uint8 totalNumberOfMediators;
    uint8 totalNumberOfClients;
    
    
     modifier onlyOwner() {
        if (msg.sender != owner) revert();
        _;
    }
    modifier onlyClients() {
        if (clients[msg.sender].added == false) revert();
        _;
    }
    modifier onlyMediators() {
        if (mediators[msg.sender].nominated == false) revert();
        _;
    }
    
    modifier onlyNominatedMediator() {
        if  (msg.sender != nominated_mediator) revert();
        _;
    }
    
     modifier onlyAdmin() {
        if  (msg.sender != administrator) revert();
        _;
    }
    
    modifier mediationAccepted() {
        if (!mediation_accepted) revert();
        _;
    }
    
    
    address agreed_mediator; 
    bool mediation_accepted; 
   
    struct Mediator {
        bool elected; // mediator is elected
        bool nominated; //mediator is nominated
        bool candidate; 
    }
    
    struct Client {
        //bool paid; // mediator is elected
        bool added;
        uint paid;
        //bool voted;
        mapping(address => bool) client_nominations;
        //address[] nominations;
    }
    

    function Mediation (address admin) {
        
        
        if (admin == 0) {
             administrator = msg.sender;
        }
        else {
            
            administrator = admin;
        }
      
        
        owner = msg.sender;
        
        
    }
    
   
    
    function addMediator(address mediator) onlyClients returns (uint8) {
             if (clients[msg.sender].client_nominations[mediator] == true) {
                 
                 return 1;}
             else {
                
                if (mediators[mediator].nominated) {
                    clients[msg.sender].client_nominations[mediator] = true;
                    
                    return 2;
                    
                }
                else {
                    mediators[mediator].nominated = true;
                    clients[msg.sender].client_nominations[mediator] = true; 
                    mediatorByIndex[totalNumberOfMediators] = mediator;
                    
                    totalNumberOfMediators++;
                    return 3;
                    
                }
                    
    
                 
             }
    }
    
    function addClient  (address client) onlyAdmin {
        
             if (clients[client].added) {
                 revert();}
             else {
                clients[client].added = true;
                clientByIndex[totalNumberOfClients] = client;
                totalNumberOfClients++;}
    }
    
    function removeClient (address client) onlyAdmin {
        
              clients[client].added = false;
             
              for (uint8 i = 0; i < totalNumberOfClients; i++) {
                  
                  address cl = clientByIndex[i];
                  if (client == cl) {
                      
                      delete clientByIndex[i];
                      totalNumberOfClients--;
                      
                  }
                  
              }
              
            
        
    }
    
    
    
    function getAllMediators()  constant  returns(address[]) {
        address[] memory allMediators = new address[](totalNumberOfMediators);
        uint8 j = 0;
        for (uint8 i = 0; i < totalNumberOfMediators; i++) {
            address mediator = mediatorByIndex[i];
            if (mediators[mediator].nominated == true) {
                allMediators[j] = mediator;
                j++;
            } 
        }
        return allMediators;
    }
    
    function getAllClients()  constant  returns(address[]) {
        address[] memory allClients = new address[](totalNumberOfClients);
        uint8 j = 0;
        for (uint8 i = 0; i < totalNumberOfClients; i++) {
            address client = clientByIndex[i];
            if (clients[client].added == true) {
                allClients[j] = client;
                j++;
            } 
        }
        return allClients;
    }
    
 
    
    function getAgreedMediators() constant public returns(address) {
        
        
        if (totalNumberOfMediators < 1) {
            
            return 0;
            
        }
        address[] memory allCandidateMediators = new address[](totalNumberOfMediators) ;
        
        address[] memory allMediators = getAllMediators(); 
        
        uint8 totalNumberOfCandidateMediators;
        
        
        
        
        for (uint8 i = 0; i < allMediators.length; i++) {
            
            address mediator = allMediators[i];
            
            uint8  concurrent_mediators;
            for (uint8 it = 0; it < totalNumberOfClients; it++) {
                
                address cl = clientByIndex[it];
                
                
                if (clients[cl].client_nominations[mediator]) {
                    concurrent_mediators++;
                    
                    
                }
                
            }
           
            if (concurrent_mediators == totalNumberOfClients) {
                     
                    
                    mediators[mediator].candidate=true;
                }
            concurrent_mediators = 0;
      
            
            
        }
        
        address[] memory allMediators2 = getAllMediators(); 
        for (uint8 i3 = 0; i3 < allMediators2.length; i3++) {
            
            address mediator2 = allMediators2[i3];
            if (mediators[mediator2].candidate) {
                
                
                allCandidateMediators[totalNumberOfCandidateMediators] = mediator2;
                totalNumberOfCandidateMediators++;
                
                
            }
            
        
        }
        
       
        
        if (totalNumberOfCandidateMediators > 1) { 
                 uint random_mediator =  randomGen(totalNumberOfCandidateMediators);
                 return allCandidateMediators[random_mediator];
        }
        else {
            
            
                 return allCandidateMediators[0];
        }
        
    
        
        
        
    }
    
    
    function randomGen(uint range) constant returns (uint randomNumber) {
        uint seed;
        for (uint8 i = 0; i < totalNumberOfMediators; i++) {
            address mediator = mediatorByIndex[i];
            seed += uint(mediator);
            } 
        
        return(uint(sha3(block.blockhash(block.number-1), seed ))%range);
    }
    
    
   
    
    function setElectedMediator () {
        
        
        address electedMediator = getAgreedMediators();
        if (electedMediator != 0) {
            nominated_mediator = electedMediator;
        }
        else {
             revert();
        }
        
    }
    
    function getNominatedMediator() constant  returns (address mediator) {
        
        return nominated_mediator;
    } 
    
    function getBalance() public constant  returns  (uint bal) {
        
        bal = this.balance;
        return bal;
    }
    
    
    function deposit()  payable onlyClients  {
        
        clients[msg.sender].paid += msg.value;
        

    }
    
   function refund() public onlyClients  {
       
       if (mediation_accepted) {
           
           revert();
           
       } 
       
       msg.sender.transfer(clients[msg.sender].paid);
       
   }
   
   function withdraw() public onlyNominatedMediator mediationAccepted {
       
       
       if (this.balance >= fee) { 
       msg.sender.transfer(fee);
       }
       else {
           
           revert();
       }
       
   }
   
    
   function acceptMediation(uint fee_to_be_paid) public onlyNominatedMediator {
       
        if (mediation_accepted) {
           
           revert();
           
       } 
       
       fee =  fee_to_be_paid * 1000000000000000000;
       mediation_accepted = true; 
       
   }
    

