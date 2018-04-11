pragma solidity 0.4.10;

contract BISOL_5 {

  int price;

  struct Entity {
      address addr;
      string name;
      int credit;
      int cons;
      int gen;
      //int avlb;
      int surplus;
      int deficit;
  }

  Entity[] public entities;
  Entity an_entity;

//############ events #################

  event Start(string _start);
  event Received(address indexed _from, string _result);
  event Aggregate(int _totSurplus, int _totDeficit);
  event Trade(int indexed _price, string _output);
  event AddEntity(uint indexed _index, address indexed _address, string _name );

//############ functions #################

  function addEntity(string _name) {
        //UPCcoin upc = UPCcoin(_UPCcoinAddress);
        Entity newEntity = an_entity;
        newEntity.name = _name;
        newEntity.credit = 1000;
        newEntity.addr = msg.sender;
        newEntity.cons = 0;
        newEntity.gen = 0;
        newEntity.surplus = 0;
        newEntity.deficit = 0;

        //upc.transferFrom(/*add proper address*/, msg.sender, 100);
        //newEntity.credit = upc.getBalance(msg.sender);

        entities[entities.length++] = newEntity;
        AddEntity(entities.length, msg.sender, _name);
    }

    function triggerInput(){
      Start("GO");
    }

    function getEntitiesCount() public constant returns(uint) {
        return entities.length;
    }

    function getEntity(uint index) public constant returns(address, string, int, int, int, int, int) {
        return (entities[index].addr, entities[index].name, entities[index].credit, entities[index].cons, entities[index].gen, entities[index].surplus, entities[index].deficit);
    }

    function sendInput(int _currentCons, int _currentGen) {
      int _prodDiff = _currentGen - _currentCons;

      for (uint i = 0; i < entities.length; ++i) {
        if(entities[i].addr == msg.sender){
          if(_prodDiff >= 0){
              entities[i].cons = _currentCons;
              entities[i].gen = _currentGen;
              entities[i].surplus = _prodDiff;
          }else{
            entities[i].cons = _currentCons;
            entities[i].gen = _currentGen;
            entities[i].deficit -= _prodDiff;
          }
        }
      }
      Received(msg.sender, "Inputs received");
    }

    function aggregate() public returns(int _totSurplus, int _totDeficit){
        for (uint i = 0; i < entities.length; ++i) {
            if(entities[i].surplus != 0){
              _totSurplus += entities[i].surplus;

            }if(entities[i].deficit != 0){
              _totDeficit += entities[i].deficit;
            }
        }
      Aggregate( _totSurplus, _totDeficit);
    }

    function trade(int _totGen, int _totCons){
        for (uint i = 0; i < entities.length; ++i) {
          if(entities[i].addr == msg.sender){
              balancing(_totGen, _totCons, i);
          }
        }
      Trade(price, "Traded successfully");
    }

    function balancing(int _totGen, int _totCons, uint i) private {
      price = (_totCons*1000/_totGen);
      if(entities[i].surplus != 0){
        entities[i].credit +=  entities[i].surplus * price;
      }if(entities[i].deficit != 0){
        entities[i].credit -=  entities[i].deficit * price;
      }
      entities[i].surplus = 0;
      entities[i].deficit = 0;

    }
}
