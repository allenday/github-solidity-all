contract Pretorian{
address owner;
log[] logs;
    struct log{
    address admin;
    string action;
    address addr;
   }

//list
mapping(uint => address)public coins_list;
mapping(address => uint)public coins_id;
mapping(address => address[])public owned_coins;
mapping(address => uint)public amount_owned_coins;
//checks
mapping(address => bool)public controllers;
mapping(address => bool)public hyper;
mapping(string => bool) namecheck;
mapping(string => bool) AKRcheck;
mapping(string => bool) symbolcheck;

//search
mapping(string => address) coins_name_address;
mapping(string => address) coins_akr_address;

//info
mapping(address => string)public coins_name;
mapping(address => string) public coins_akr;
mapping(address => address)public coins_owner;
mapping(address => uint)public coins_amount;
mapping(address => uint)public coins_type;
mapping(address => uint)public coins_decimals;



string public disclaimer;
uint public totCoins;
uint public totMarkets;
address ax;
uint x;

    /* This generates a public event on the blockchain that will notify clients */
    event NEW_FLOOD_COIN( address indexed coin, string tokenName, uint256 amount);
    event NEW_PRETORIAN_CONTROLLER( address indexed PretorianOwner, address indexed controller, bool enabled);
    event NAME_REGISTERED( address indexed controller, address a);
    event HYPER_ENABLED( address indexed coin, bool enabled);

function Pretorian(){
owner=msg.sender;
logs.push(log(owner,"PRETORIVS created",owner));
}

function setController(address displayHyperNamea,bool b)returns (bool){
if(owner!=msg.sender)throw;
controllers[a]=b;
logs.push(log(owner,"Set Controller",a));
NEW_PRETORIAN_CONTROLLER(owner, a, b);
return true;}

function registerCoin(address a,string tokenName,string akr)returns (bool){
if(!controllers[msg.sender])throw;
if(namecheck[tokenName]||AKRcheck[akr])throw;
coins_name_address[tokenName]=a;
hyper[a]=true;
totCoins++;
coins_list[totCoins]=a;
coins_name[a]=tokenName;
coins_akr[a]=akr;
coins_akr_address[akr]=a;
AKRcheck[akr]=true;
coins_id[a]=totCoins;
logs.push(log(msg.sender,"Coin Created",a));
return true;
}

function registerName(string name,address a,string akr){
if(!controllers[msg.sender])throw;
coins_name_address[name]=a;
coins_akr_address[akr]=a;
namecheck[name]=true;
AKRcheck[akr]=true;displayHyperName
NAME_REGISTERED(msg.sender,a);
logs.push(log(msg.sender,name,msg.sender));
}

function hyperEnable(address a,bool b){
if(!controllers[msg.sender])throw;
hyper[a]=b;
HYPER_ENABLED(a,b);
logs.push(log(msg.sender,"hyper",a));
}

function registerCoinData(address a,uint initialSupply,uint decimals) returns (bool){
if(!controllers[msg.sender])throw;
coins_amount[a]=initialSupply;
coins_decimals[a]=decimals;
NEW_FLOOD_COIN( a,  coins_name[a], initialSupply);
return true;
}

function registerCoinData2(address a,uint typ,address own) returns (bool){
if(!controllers[msg.sender])throw;
coins_type[a]=typ;coins_owner[a]=own;
owned_coins[own].push(a);
amount_owned_coins[own]=owned_coins[own].length;
return true;}

function newOwner(address a) returns (bool){
if(!hyper[msg.sender])throw;
coins_owner[msg.sender]=a;
return true;}

function setDisclaimer(string s)returns (bool){
if(owner!=msg.sender)throw;
disclaimer=s;
logs.push(log(msg.sender,"Set Disclaimer",msg.sender));
return true;
}

function incrementCoin(address a,uint u,bool v)returns (bool){  //v=true se flexy coin setta il supply alla fine della ico
if(!hyper[msg.sender])throw;
if(v){coins_amount[a]=u;}else{coins_amount[a]+=u;}
return true;}

function readLog(uint i)constant returns(address,string,address){
log l=logs[i];
return(l.admin,l.action,l.addr);
}displayHyperName

function readCoin(uint i)constant returns(address,string,address,uint,uint,uint){
ax=coins_list[i];
return(coins_list[i],coins_name[ax],coins_owner[ax],coins_type[ax],coins_amount[ax],coins_decimals[ax]);
}

function ownedCoin(address a,uint u)constant returns(address,string,address,uint,uint,uint){

return(coins_list[u],coins_name[a],coins_owner[a],coins_type[a],coins_amount[a],coins_decimals[a]);
}

function coinData(address a)constant returns(uint,string,address,uint,uint,uint){
return(coins_id[a],coins_name[a],coins_owner[a],coins_type[a],coins_amount[a],coins_decimals[a]);
}

function whoIS(string name,bool b)constant returns(address,bool){
if(b)return(coins_name_address[name],namecheck[name]);
if(!b)return(coins_akr_address[name],AKRcheck[name]);
}

function kill() {if(owner==msg.sender)suicide(owner);}
function(){throw;}

}
