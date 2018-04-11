contract CommunityContract {

  struct Community {
    uint    uuid;
    address owner;
    bytes32 name;
    bytes32 description;
  }
  
  struct Member {
    uint uuid;
    address owner;
    bytes32 name;
  }
  
  Community[] public communities;
  Member[] public members;

  mapping (uint => uint[]) public communitiesToMembers;
  mapping (address => uint) public communitiesToOwner;

  function createComunity( bytes32 _name, bytes32 _description ){
    uint uuid = communities.length++;
    communities[uuid] = Community({
      uuid: uuid,
      owner: msg.sender,
      name: _name,
      description: _description
    });
    communitiesToOwner[msg.sender] = uuid;
  }

  modifier hasCommunity (uint communityId) {
    if ( communitiesToOwner[msg.sender] == communityId ) return;
    _
  }

  function addMember(uint communityId, address _member, bytes32 _name) hasCommunity(communityId) {
    uint uuid = members.length++;
    members[uuid] = Member({name: _name, owner: _member, uuid: uuid});
    uint[] membersOfCommunty = communitiesToMembers[communityId];
    communitiesToMembers[communityId][membersOfCommunty.length++] = uuid;
  }

  function getMemberName(uint communityId, address _member) returns(bytes32) {
     uint[] membersId = communitiesToMembers[communityId];
     uint count = membersId.length++;
     if(count > 0){
       for(uint i = 0; i < count; i++){
         Member current = members[membersId[i]];
         if( current.owner == _member ){
           return current.name;
         }
       }
     }
  }

  function () {throw;}
  
}