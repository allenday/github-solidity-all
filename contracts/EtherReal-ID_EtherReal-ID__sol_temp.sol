pragma solidity ^0.4.2;

contract Pretorian {
    bool isroot;
    etherRealID root;
    address public rootOwner;
    address public rootAddress;
    address public lastCreated;

    mapping(address => bool) public isSmartID; 
    mapping(address => string) public smartIDnames;
    mapping(address => string) public smartIDid;
    mapping(string => bool)  smartIDidCheck;
    mapping(address => string) public smartIDpassport;
    mapping(string => bool)  smartIDpassportCheck;
    mapping(address => address[]) public smartIDwallets;
    mapping(address => address) public walletSmartID;
    mapping(address => bool) public registeredWallets;
    mapping(address => address) public registeredWalletsOwner;
    mapping(string => bool)  idRequest;
    mapping(string => request)  idRequestsIndex;

    mapping(string => uint)  requestblock;

    struct request{
    string name;
    string id;
    string location;
    address owner;
    }

function Pretorian(){
   
}

function createRoot(string name,string id){
if(isRoot)throw;isRoot=true;
rootAddress=new etherRealID(msg.sender,this,name,id,false);
   isSmartID[rootAddress]=true;
   smartIDnames[rootAddress]=name;
   smartIDid[rootAddress]=id;
   smartIDidCheck[id]=true;
   //smartIDpassport[rootAddress]=passport;
   //smartIDpassportCheck[passport]=true;
   rootOwner=msg.sender;
}
function requestNewEtherRealID(string name,string id,string location,bool entity)returns(bool){
if((entity)&&(!isSmartID[msg.sender]))throw;
if(idRequest[id])throw;
idRequest[id]=true;
requestblock[id]=block.number;

idRequestsIndex[id]=request({name : name,id : id,location : location,owner : msg.sender});
return true;
}

function resetRequest(string id)returns(bool){
if(block.number<requestblock[id]+6000)throw;
idRequest[id]=false;
return true;
}

function checkRequest(string name,string id,string location)private constant returns (bool){
bool temp=true;
//if(!((idRequestsIndex[id].name==name)&&(idRequestsIndex[id].id==name)&&(idRequestsIndex[id].name==location)))temp=false;
return temp;
}

address smartIDaddr;
function registerSmartID(string name,string id,string location,bool entity,bool isEntity) returns (bool){
if(!isSmartID[msg.sender]){throw;}else{if(isEntity)throw;}
if(smartIDidCheck[id])throw;
if(!checkRequest(name,id,location))throw;

   smartIDaddr=new etherRealID(idRequestsIndex[id].owner,msg.sender,name,id,entity);
   isSmartID[smartIDaddr]=true;
   smartIDnames[smartIDaddr]=name;
   smartIDid[smartIDaddr]=id;
   smartIDidCheck[id]=true;
   lastCreated=smartIDaddr;
   walletSmartID[idRequestsIndex[id].owner]=smartIDaddr;
   return true;
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

for(uint i=0;i<smartIDwallets[msg.sender].length;i++){
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

contract smartIDRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }


contract etherRealID {

    //AddressReg popa;
    etherRealID remote;
    address validating;
    address public etherRealIDowner;

    Pretorian pretorian;
    address pa;
    address waitingWallet;

    address[] public validators;
    uint[] public validatorsWhat;
    address[] public validated;
    uint[] public validatedWhat;
    address[] public wallets;
    address[] public family;
    uint public lastImageUpdate;  //block number
    uint public lastCheck;  //block number

    string public standard = 'EtherRe.al 0.1';
    string public name;
    string public id;
    string public passport;
    string public email;
    uint public birthday;
    string public physicaladdress;
    string public location;
    uint public blackflags;
    uint rating; //depends on action

    bool public isEtherrealEntity;
    bool public checkemail;
    bool public checkaddress;
    bool public ispopa;     //consensys proof of physical address
    bool public checkimage;
    uint public checkimageamount;



    event Transfer(address indexed from, address indexed to, uint256 value);

    function etherRealID(address owner,address validator,string name,string id,bool entity){
      etherRealIDowner=owner;
      validators.push(validator);
      pretorian=Pretorian(msg.sender);
      //popa=AddressReg(0xbad661c5a1970342ade69857689738b6c8d9da51);
      pa=msg.sender; //pretorian address
      ispopa=false;
      blackflags=0;
      rating=999999990; //negative number = -10
      isEtherrealEntity=entity;
      birthday=block.number;
    }

    function requestNewEtherRealID(string name,string id,string location)returns(bool){
    if(msg.sender!=etherRealIDowner)throw;
    if(!pretorian.requestNewEtherRealID(name,id,location,true))throw;
    return true;
    }


    function Validate(string name,string id,string location,bool entity){
      if(msg.sender!=etherRealIDowner)throw;
      if(!pretorian.registerSmartID(name,id,location,entity,isEtherrealEntity))throw;
      address temp=pretorian.lastCreated();
      validated.push(temp);
    }


    function addFamily(address a){
      if(msg.sender!=etherRealIDowner)throw;
      family.push(a);
    }

    function removeFamily(address a){
      if(msg.sender!=etherRealIDowner)throw;
      for(uint i=0;i<family.length;i++){
         if(family[i]==a)
         family[i]=family[family.length-1];
         family[family.length-1]=0x0;
      }
    }

    function addWallet(address a){
      if((msg.sender!=etherRealIDowner)||(msg.sender!=waitingWallet)||(wallets.length>50))throw;
      if(msg.sender==etherRealIDowner){
          waitingWallet=a;
      }
      if(msg.sender==waitingWallet){
         if(!pretorian.registerWallet(waitingWallet,etherRealIDowner))throw;
         wallets.push(waitingWallet); 
      }
    }

    function removeWallet(address a){
      if(msg.sender!=etherRealIDowner)throw;
      if(!pretorian.deleteWallet(a,etherRealIDowner))throw;
      for(uint i=0;i<wallets.length;i++){
         if(wallets[i]==a)
         wallets[i]=wallets[wallets.length-1];
         wallets[wallets.length-1]=0x0;
      }
    }
    
    
   

   


    function getValidator(uint v)constant returns(address,uint){
      return (validated[v],wallets.length);
    }

    function getValidated(uint v)constant returns(address,uint){
      return (validated[v],validated.length);
    }

    function getWallet(uint w)constant returns(address,uint){
      return (wallets[w],wallets.length);
    }

  
    function check() constant returns(bool,bool,bool,uint,uint,uint){
      return(checkemail,checkaddress,checkimage,checkimageamount,lastImageUpdate,lastCheck);
    }

}
