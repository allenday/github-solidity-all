contract ADV{
address public controller;
mapping(address => adv[])public advs;
mapping(address => string[])public censored;
mapping(address => uint)public start;
mapping(address => address)public ownerships;

struct ADV{
uint end;
string addr;
}

function ADV(){}

function addAdv(address a,string s) returns (bool){
adv Tadv=advs[a][0];
if(block.number>Tadv.end){
uint i=start[a];
for(uint x=start[a];x<i+1;x++){
Tadv=advs[a][x];
if(block.number>Tadv.end){i++;start[a]++;}
}
}
advs.push({0,0,s});
return true;
}

function getAdv(address a)constant returns (string){
adv Tadv=advs[a][start];
string Ts;
uint i=start[a];
if(block.number>Tadv.end){
for(uint x=start[a];x<i+1;x++){
Tadv=advs[a][x];
if(block.number>Tadv.end)i++;
}
}

return Tadv.addr;
}

function verifyOwnership(address a){
//effettua chiamata esterna
//individua owner di a
//se non è owner throw
if(msg.sender!=o)throw;
ownerships[a]=msg.sender;
}

function removeAdv(address a){
if(!ownerships[a])throw;
if(msg.sender!=ownerships[a])throw;
adv Tadv=advs[a][start[a]];
if(block.number>Tadv.end)
start[a]++;
}

function censorAndCover(address a,uint u,string default)returns (bool){
if((!ownerships[a])&&(msg.sender!=controller))throw;
adv Tadv=advs[a][u];
censored[a].push(Tadv.addr);
advs[address][u]=default;
}

function getCensored(address a,uint u)constant returns (string){
return(censored[a][u]);
}

}
