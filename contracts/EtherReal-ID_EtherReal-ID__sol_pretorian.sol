 
// Early draft.  
// This is not a deployment contract
// strictly alfa!!!

pragma solidity ^0.4.6;

contract Pretorian {

    etherReal_smart_ID                      root;
    address                         public rootOwner;
    address                         public rootAddress;
    address                         public lastCreated;

    mapping(address => bool)        public isSmartID; 
    mapping(address => string)      public smartIDnames;
    mapping(address => string)      public smartIDid;
    mapping(string => bool)         public smartIDidCheck;
    mapping(address => string)      public smartIDpassport;
    mapping(string => bool)         public smartIDpassportCheck;
    mapping(address => address[])   public smartIDwallets;
    mapping(address => address)     public walletSmartID;
    mapping(address => bool)        public registeredWallets;
    mapping(address => address)     public registeredWalletsOwner;
    mapping(string => bool)         public idRequest;
    mapping(string => request)      public idRequestsIndex;


    struct request{
    string name;
    string id;
    string location;
    string owner;
    }

function Pretorian(string name,string id,string passport){
    rootAddress=new etherReal_smart_ID(msg.sender,name,id,passport);
    isSmartID[rootAddress]=true;
    smartIDnames[rootAddress]=name;
    smartIDid[rootAddress]=id;
    smartIDidCheck[id]=true;
    smartIDpassport[rootAddress]=passport;
    smartIDpassportCheck[passport]=true;
    rootOwner=msg.sender;
}

function requestNewEtherRealIÐ(string name,string id,string location,bool entity)returns(bool){
    if((entity)&&(!isSmartID[msg.sender]))throw;
    if(idRequest[id])throw;
    idRequest[id]=true;
    requestblock[id]=block.number;
    request req=new request({name : name,id : id,location : location,owner : msg.sender});
    idRequestsIndex[id]=req;
    return true;
}

function resetRequest(string id)returns(bool){
    if(block.number<requestblock[id]6000)throw;
    idRequest[id]=false;
    return true;
}

function checkRequest(string name,string id,stirng location)private constant returns (bool){
    bool temp=true;
    if(!((idRequestsIndex[id].name==name)&&(idRequestsIndex[id].id==name)&&(idRequestsIndex[id].name==location)))temp=false;
    return temp;
}


function registerEtherRealIÐ(string name,string id,string location) returns (bool){
    if(!isSmartID[msg.sender])throw;
    if(smartIDidCheck[id])throw;
    if(!checkRequest(name,id,location))throw;

    address smartIDaddr=new etherReal_smart_ID(idRequestsIndex[id].owner,msg.sender,name,id,passport);
    isSmartID[smartIDaddr]=true;
    smartIDnames[smartIDaddr]=name;
    smartIDnames[smartIDaddr]=id;
    smartIDidCheck[id]=true;
    lastCreated=smartIDaddr;
    walletSmartID[idRequestsIndex[id].owner]=smartIDaddr;

}

function registerWallet(address a,address owner)returns(bool){
    if(!isSmartID[msg.sender])throw;
    if(registeredWallets[a])throw;
    smartIDwallets[msg.sender].push(a);
    registeredWallets[a]=true;
    registeredWalletsOwner[a]=owner;
}

function deleteWallet(address a,address owner)returns(bool){
    if(!isSmartID[msg.sender])throw;
    if(!registeredWallets[a])throw;
    if(registeredWalletsOwner[a]!=owner)throw;

    for(uint i=0;i<smartIDwallets[msg.sender].length;i){
        if(smartIDwallets[msg.sender][i]==a)
            smartIDwallets[msg.sender][i]=smartIDwallets[msg.sender][smartIDwallets[msg.sender].length-1];
        smartIDwallets[msg.sender][smartIDwallets[msg.sender].length-1]=0x0;
        registeredWallets[a]=false;
        }
}

function WHOIS(address a)constant returns(bool,string,string,string){
    return(isSmartID[a],smartIDnames[a],smartIDid[a],smartIDpassport[a]);
}


}
