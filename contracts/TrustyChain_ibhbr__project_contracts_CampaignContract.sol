contract communityContract {
  mapping (address => uint) public communitiesToOwner;
  function getMemberName(uint communityId, address _member) returns(bytes32) {}
}

contract CampaignContract {

  communityContract public community;

  struct Campaign {
    uint uuid;
    uint communityId;
    address owner;
    bytes32 name;
    bytes32 description;
    bytes32 image;
    uint amountNeed;
    uint amountReceive;
    bool done;
  }

  struct Collaborator {
    uint uuid;
    address owner;
    bytes32 name;
    bytes32 description;
    uint amount;
  }

  Campaign[] public campaigns;
  Collaborator[] public collaborators;

  mapping (address => uint[]) public ownerToCampaigns;
  mapping (uint => uint[]) public campaignToCollaborates;

  modifier isOwnerOfCommunity (uint communityId) {
    if ( community.communitiesToOwner(msg.sender) != communityId ) return;
    _
  }

  modifier isOwnerOfCampaign (uint campaignId) {
    uint[] campaignsOfSender = ownerToCampaigns[msg.sender];
    uint count = campaignsOfSender.length;
    bool found = false;
    if( count > 0 ){
      for( uint i = 0; i < count; i++ ){
        if( campaignsOfSender[i] == campaignId ){
          found = true;
          break;
        }
      }
    }
    if(!found) return;
    _
  }
  
  modifier campaignIsNotDone (uint campaign) {
    if ( campaigns[campaign].done ) return;
    _
  }
  
  function CampaignContract(communityContract _community){
    community = _community;
  }
  
  function createCampaign(uint _community, bytes32 _name, bytes32 _description, bytes32 _image) isOwnerOfCommunity (_community) {
    uint uuid = campaigns.length++;
    campaigns[uuid] = Campaign({
      uuid: uuid,
      communityId: _community,
      owner: msg.sender,
      name: _name,
      description: _description,
      image: _image,
      amountNeed: 0,
      amountReceive: 0,
      done: false
    });
    uint[] campaignsOfSender = ownerToCampaigns[msg.sender];
    campaignsOfSender[campaignsOfSender.length++] = uuid;
    ownerToCampaigns[msg.sender] = campaignsOfSender;
  }

  function addCollaborate(uint _campaign, address _collaborator, bytes32 _description, uint _amount) isOwnerOfCampaign(_campaign) campaignIsNotDone(_campaign) {
    uint uuid = collaborators.length++;
    Campaign camp = campaigns[_campaign];
    bytes32 memberName = community.getMemberName(camp.communityId, _collaborator);
    collaborators[uuid] = Collaborator({
      uuid: uuid,
      owner: _collaborator,
      name: memberName,
      description: _description,
      amount: _amount
    });
    camp.amountNeed += _amount;
    campaigns[_campaign] = camp;
    addCollaborateToCampaign(_campaign, uuid);
  }
  
  function addCollaborateToCampaign(uint _campaign, uint _collaborate) internal {
    uint[] campaignToCollaboratesIds = campaignToCollaborates[_campaign];
    campaignToCollaborates[_campaign][campaignToCollaboratesIds.length++] = _collaborate;  
  }

  function countCampaigns(address current) returns(uint){
    uint[] ids = ownerToCampaigns[current];
    return ids.length;
  }

  function donateToCampaign(uint _campaign, uint amount) campaignIsNotDone(_campaign) {
  }

  function concludeCampaign(uint _campaign) isOwnerOfCampaign(_campaign) campaignIsNotDone(_campaign) {

  }

  function () { throw; }
}