/*
Blocktube farming consists of a mix of proof of work and proof of stake.

Farmers commit themselves to render a clip in a certain quality and put BTCoins on that.
When they have rendered the clip and uploaded the quality variant to IPFS, they sumbit
the IPFS hash to this contract.
The clip owner gets notified via the 'workSubmitted' event.
When the owner approves the work - the farmer gets his POS BTcoins back, and the reward
BTCoins are minted and sent to the farmer address.

Farmers watch this contract to get notified of new raw clips coming into the system
via the event 'newclipAdded'.

FLOW
- clip contract calls submitNewClip() 
- farmer picks up this event
- farmer chooses a quality to render and claims a slot via 
	-> getWork(address clipaddress, uint quality)
- farmer submits his work via
	-> submitWork(address clipaddress,uint quality,string ipfshash)
- clip owner watches events on his clipcontract(s)
- clip owner confirms the work
  -> acceptWork


TODO:
- introduce time limits between claiming a clip and submitting ( e.g. a function to 
transfer the POS BTCoins to the clip contract so it can be paid out as eyeballs after 
a certain time treshold ?)
- introduce time limits for approving the work - so that the POS of the farmer is not
stuck forever in the clip contract.
- Currently the price/reward mapping is set on contract creation, we should add the
possibility to change the price/rewards afterwards.
- reject work by clip owner
- OR: accept work via likes on the clip

*/

contract blocktubeFarming {

address owner;

struct PriceReward {
    // how many BTcoins to commit to POS for farming this clip
    uint price;
    uint reward;
}


mapping (uint => PriceReward) public pricerewards;

function blocktubeFarming(){
    
    owner = msg.sender;
    // POS for quality 144px is 1 BTCoin - reward for farming is 2 BTCoin
    pricerewards[144] = PriceReward(1,2);
    pricerewards[240] = PriceReward(2,4);
    pricerewards[360] = PriceReward(3,6);
    pricerewards[480] = PriceReward(4,8);
    pricerewards[720] = PriceReward(5,10);
}

struct FarmingEntry {
    // the clip address
	address farmer;
	// timestamp when this entry was claimed
	uint timeclaimed;
	// timestamp when the result was submitted
	uint timesubmitted;
	// owner of the clip should accept the clip
	uint acceptstatus;
	// timestamp when the result was accepted
	uint timeaccepted;
	string ipfshash;
}

FarmingEntry[] bla;
mapping(address => mapping(uint => FarmingEntry)) farmingqueue;

event newclipAdded(address clipaddress); 

function submitNewClip(){
		// TODO : check if this is actually a blocktube clipcontract ?
    newclipAdded(msg.sender);
}

// claim a work entry
function getWork(address clipaddress, uint quality){

    // check if the requested quality exists
    if (pricerewards[quality].price == 0x0) throw;
    
    // check if this clip/quality has already been claimed    
    if (farmingqueue[clipaddress][quality].farmer != address(0x0)) throw;    

    farmingqueue[clipaddress][quality] = FarmingEntry(
      msg.sender,
      now,0,0,0,''
    );
}

event workSubmitted(address clipaddress,uint quality,string ipfshash);

function submitWork(address clipaddress,uint quality,string ipfshash){
    // you can only submit your own claimed clips
    if (farmingqueue[clipaddress][quality].farmer != msg.sender) throw; 
    // you can only submit once
    if (farmingqueue[clipaddress][quality].timesubmitted != 0x0) throw; 

    // submit work
    farmingqueue[clipaddress][quality].timesubmitted = now;
    farmingqueue[clipaddress][quality].ipfshash = ipfshash;
    
    // TODO : approve and call BTcoins for this clip aka POS
    // so that the farmer can only claim as much clips as he can commit BTcoins

    workSubmitted(clipaddress,quality,ipfshash);
    
}

// the clipcontract should call this function to approve the work
function acceptWork(uint quality){
    // no clip at this address or not submitted yet
    if (farmingqueue[msg.sender][quality].timesubmitted == 0x0) throw;

    // quality does exist ?
    if (pricerewards[quality].reward == 0x0) throw;

    // TODO : 
    // - mint new tokens
    uint reward = pricerewards[quality].reward;

    // TODO
    // return the approve and called POS
    
}

function kill() { if (msg.sender == owner) suicide(owner); }

	
}