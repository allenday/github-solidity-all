contract hyperInterface{
Flood_Standard_Ethereum_Coin coin;
function hyperInterface(){}
 
function getPartners(address a,uint u)constant returns(uint,address,address,address,address,address){
coin = new Flood_Standard_Ethereum_Coin(a);
return(coin.totPartnerships,coinpartnerAddress[u],coinpartnerAddress[u+1],coinpartnerAddress[u+2],coinpartnerAddress[u+3],coinpartnerAddress[u+4]);
}
 
function getHyper(address h) constant returns(string,string,uint,uint,uint,address){
coin = new Flood_Standard_Ethereum_Coin(h);
return(coin.name(),coin.symbol(),coin.totalSupply(),coin.block_reward(),coin.type(),coin.owner());
}

 
}
