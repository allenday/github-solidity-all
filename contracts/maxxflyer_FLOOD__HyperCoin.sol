contract Flood_Standard_Ethereum_Coin {
    /* Public variables of the token */
    address public owner;
    address public admin1;
    address public admin2;
    address self;
    address[] public partnerAddress;

    Pretorian Pretorivs;
    Flood_Standard_Ethereum_Coin swapWith;
    ControllerManager controllerManager;

    string public standard;
    string public name;
    string public symbol;

    uint public decimals;
    uint public totalSupply;
    uint public block_reward;
    uint public created;
    uint public cost;
    uint public bonus;
    uint public endbonus;
    uint public endblock;
    uint public enabled;

    uint public ICOtot;

    uint public volume;
    uint public ETHvolume;
    //uint public totPartners;
    uint public totPartnerships;
    uint public totOwners;



    mapping(address => uint) public last_reward;
    mapping(address => bool) partnership;
    mapping (address => mapping (address => uint256)) public allowance;

    swappable[] public market;
   
    struct swappable{
    address owner;
    uint amount;
    uint price;
    bool fix;
    uint prev;
    uint next;
    }

    struct order{
    uint amount;
    uint amount2;
    uint blockn;
    }

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => uint256) public ethBalanceOf;
    mapping (address => uint256) public lockedOf;
    mapping (address => swappable[]) public markets;
    mapping (address => order[]) public orders;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Flood_Standard_Ethereum_Coin(uint initialSupply,string tokenName,string tokenSymbol,uint rew) {
        owner=msg.sender;
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = 18;                            // Amount of decimals for display purposes
        block_reward = rew;
        enabled=0;
        ICOtot=0;
        totPartnerships=0;
        cost=10000000000;
        totOwners=1;
        endbonus=1000;
        bonus=10;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if ((balanceOf[msg.sender]-lockedOf[msg.sender]) < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                 // Subtract from the sender            
        balanceOf[_to] += _value;  
        last_reward[_to]=block.number;                          // Add the same to the recipient
        volume+= _value;               
        Transfer(msg.sender, _to, _value);       // Notify anyone listening that this transfer took place
    }

        /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* Approve and then comunicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }        

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if ((balanceOf[_from]-lockedOf[msg.sender]) < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;   // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        if(balanceOf[_from]==0)totOwners--; 
        if(balanceOf[_to]==0)totOwners++; 
        volume+=_value;
        balanceOf[_to] += _value;                            // Add the same to the recipient
        last_reward[_to]=block.number; 
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
 
    function setSelfPretorian(address s,address p,address o)returns(bool){
    if(enabled==0){
    Pretorivs=Pretorian(p);
    self=s;
    partnership[s]=true;
    markets[s].push(swappable({owner : owner,amount : 0,price : 1,fix : true,prev : 0,next : 1}));
    markets[s].push(swappable({owner : owner,amount : 0,price : 1000000000,fix : true,prev : 0,next : 0}));
    balanceOf[o]=balanceOf[owner];
    owner=o;
    balanceOf[msg.sender]=0;
    enabled=1;
    }
    return true;
    }





 /* Change Owner */
    function manager(uint code,address a,string s,uint256 u,bool b)returns(bool){
    if((code!=50)&&(msg.sender!=owner))throw;
    if(code==46){   if(enabled==1){cost=u;if(cost<10000000000)throw;enabled=2;}}
    if(code==47){   if(enabled==2){bonus=u;enabled=3;}}
    if(code==48){   if(enabled==3){endbonus=u;enabled=4;}}
    if(code==49){   if(enabled==4){endblock=block.number+u;endbonus+=block.number;
enabled=5;created=block.number;}}             //start startsale
    if(code==50){   if((block.number>endblock)&&(enabled==5)){                      //stop startsale
                              enabled=6;
                              totalSupply-=balanceOf[owner];                        //in caso di standard ICO
                              Pretorivs.incrementCoin(this,totalSupply,true);       //aggiorna supply presso pretorivs
                              balanceOf[owner]=0;                                   //brucia i coin rimasti
                              ICOtot=ethBalanceOf[owner];
                              //       volume+= tot;                                     //registra totale ico
                    }
    }
    if(code==77){ //change owner
       uint uu=balanceOf[owner];
       balanceOf[owner]=0;
       totOwners--; 
       if(balanceOf[a]==0)totOwners++; 
       balanceOf[a]+=uu;
       Pretorivs.newOwner(a);
       owner=a;
    }
    if(code==78){if(msg.sender!=owner)throw;if(u==1)admin1=a;if(u==2)admin2=a;}
    if(code==111){if((msg.sender!=owner)&&(msg.sender!=admin1)&&(msg.sender!=admin2))throw;
     if(enabled>0){ //da correggere da 0 a 4
      if(b&&(!Pretorivs.hyper(a)))throw;    
       if(totPartnerships<=25){
          if(b){
               if(partnership[a]==false){totPartnerships++;partnerAddress.push(a);partnership[a]=true;
//Pretorivs.totMarkets++;
}
                  if(markets[a].length==0){
                     markets[a].push(swappable({owner : owner,amount : 0,price : 1,fix : true,prev : 0,next : 1}));
                     markets[a].push(swappable({owner : owner,amount : 0,price : 1000000000,fix : true,prev : 0,next : 0}));
                  }
               }else{
               if(totPartnerships<4)throw;
                 if(partnership[a]==true){
                 for(var i=0; i<totPartnerships; i++){
                 if(partnerAddress[i]==a){partnerAddress[i]=partnerAddress[totPartnerships-1];partnerAddress[totPartnerships-1]=0x0;totPartnerships--;partnership[a]=false;
//Pretorivs.totMarkets--;
}
                 }
                 
                 }
               }
       }
      
     }else{throw;}
    }
    if(code==333){
    address ad=controllerManager.getController(u);
    if(ad!=0x0)partnership[ad]=true;
    }
    return true;
    }

  

    /* Simple_Claimable_Temporized_Stake */
    function Simple_Claimable_Temporized_Stake()returns (bool){
    uint t=((balanceOf[msg.sender]/totalSupply)*block_reward*(block.number-last_reward[msg.sender]));
    balanceOf[msg.sender]+=t;
    totalSupply+=t;
    Pretorivs.incrementCoin(this,t,false);
    last_reward[msg.sender]=block.number;
    return true;
    }




    /* CREATE OFFER */
    function createOffer(address coinx,uint amountx,uint coeff,bool fixe,uint index)returns (bool){
    if((balanceOf[msg.sender]-lockedOf[msg.sender]<amountx)||(coeff==0)||(index<1)||(enabled==7)||(amountx==0))throw;
    swappable order=markets[coinx][index];  
    swappable prev=markets[coinx][order.prev];   
    if((order.price<coeff)||(prev.price>coeff))throw;
    markets[coinx].push(swappable({owner : msg.sender,amount : amountx,price : coeff,fix : fixe,prev : order.prev,next : index}));
    order.prev=markets[coinx].length;
    prev.next=markets[coinx].length;
    lockedOf[msg.sender]+=amountx;
    balanceOf[msg.sender]-=amountx;
    return true;
    }



    function getOffer(address coinx,uint u)constant returns(address,uint,uint,bool,uint){
    
    swappable order=markets[coinx][u];
    return(order.owner,order.amount,order.price,order.fix,market.length);
    
    }

    function getOrder(address coinx,uint u)constant returns(uint,uint,uint,uint){
    
    order ord=orders[coinx][u];
    return(orders[coinx].length,ord.amount,ord.amount2,ord.blockn);
    
    }

    function getPartner(uint u)constant returns(address,uint){
    
    address a=partnerAddress[u];
    return(a,totPartnerships);
    
    }

    function lockBalance(uint u,bool b){
    if(b){
    balanceOf[msg.sender]-=u;
    lockedOf[msg.sender]+=u;
    }else{
    balanceOf[msg.sender]+=u;
    lockedOf[msg.sender]-=u;
    }
    }

    function calculator(address coinx,uint pay,uint offer)constant returns(uint,uint){
    swappable order=markets[coinx][offer];
    return(((pay/order.price)*1000000000),order.amount/1000000000*order.price);
    }



    /* ICO money */
    function withdraw(address a)returns (bool){
    if(enabled<6)throw;
    if(ethBalanceOf[msg.sender]==0)throw;
    uint u=ethBalanceOf[msg.sender];
    ethBalanceOf[msg.sender]=0;
    if(!a.send(u))throw;
    ETHvolume+=u;
    return true;
    }


    //ICO fixed cost
    function ico() payable{
       if((enabled!=5)||(msg.value<100000000000000000))throw;
       uint256 tot=msg.value/cost*1000000000000000000;
       if(block.number<endbonus)tot+=tot/100*bonus;
       if(balanceOf[owner]<tot)throw;
       balanceOf[owner] -= tot;
       balanceOf[msg.sender] += tot;                      
       ethBalanceOf[owner]+=msg.value;
       }
    

}
