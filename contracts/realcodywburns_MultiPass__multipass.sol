pragma solidity ^0.4.2;

// NOT PRODUCTION READY! DO NOT USE THIS FOR REAL WORLD YET!
// This contract is a general purpose multipass. It has all the basic parts and should function to provide a generally secure identity
// It needs an owner, should be able to register with a category contract, and handle comments, and allow for some data to be hidden unless paid for(in the future)


contract owned{
  function owned () {owner = msg.sender;}
  address owner;
  modifier onlyOwner {
          if (msg.sender != owner)
              throw;
          _;
      }
}
contract multipass is owned {
 // Parameters of all multipasses.
 // metadata
    string public author;             //Name of Owner
    string public title;              //Owners Title
    string public description;        //short Bio of the item
    string public extUrl;             //a link to website or something
    string public avatar;             // external link to image of owner
    uint public creationTime = now;   //when the contract was origionally created


//Accounts section
    uint cCount;
    struct cmnt{
      string aSite;     // The website the account is held on
      string aUsrname;  // The Owners Username on the site
      string aUrl;      // Url to the account
      //uint cost;         cost to retrieve the data, default should be zero, however, a user may add a cost to get their email or something (maybe later)
      }

    string public verifier;

//show comments as they arrive
    event newComment(string site, string username, string url);
    event verification(string verification);
// store comments
    mapping(uint => cmnt) cmnts;

function startMultipass(string _author, string _title, string _description, string _extUrl, string _avatar, uint _regGas, address _regAddress) onlyOwner{
// assign multipass metadata. Register to a multipass list if one exists
  author = _author;
  title = _title;
  description = _description;
  extUrl = _extUrl;
  avatar = _avatar;
  //register with a cat contract. MUST HAVE ENOUGH WEI TO PAY FOR A SEAT. add payable and variables in function if this is what really will happen.
      uint value = msg.value - _regGas;
      bool register = _regAddress.call.gas(_regGas).value(value)();
    }

// change the public verification message. could be useful to prove ownership
function veriPass(string _msg) onlyOwner {
  verifier = _msg;
  verification(verifier);
}


function modPass(uint _action, uint _index, string _aSite, string _aUsrname, string _aUrl) onlyOwner{
  //allows owner to add and remove social sites from their account
  // allow the owner to 1 add, 2 del, or 3 mod the comment

     if (_action == 1){
        uint id = cCount++;
        cmnt c = cmnts[id];                              //add new comment to multipass
        c.aSite = _aSite;                               //site where account is located. Should be in font awesome format or something
        c.aUsrname = _aUsrname;                         //The Owners handle on the site
        c.aUrl = _aUrl;                                 //the link to the profile
        cCount = cCount ++;                             //add to the total contract count
        newComment(c.aSite, c.aUsrname, c.aUrl );       //push a new event
        }
      if (_action == 2){                                //kill a social media account entry. only requires a index
        cCount = cCount-1;
        c = cmnts[_index];
        delete c.aSite;
        delete c.aUsrname;
        delete c.aUrl;
        }
      if (_action == 3){      //push a site quietly or change one already in place
      c = cmnts[_index];
      c.aSite = _aSite;        //site where account is located. Should be in font awesome format or something
      c.aUsrname = _aUsrname;     //The Owners handle on the site
      c.aUrl = _aUrl;             //the link to the profile
        }
    }

//figure out a way to do this better

//returns a site at index address
function getSite(uint _index) constant returns (string){
  return cmnts[_index].aSite;
  }

//returns an username at index address
function userName(uint _index) constant returns (string){
  return cmnts[_index].aUsrname;
  }

//returns a verification site at index address
function GetProfile(uint _index) constant returns (string){
  return cmnts[_index].aUrl;
  }


//a count of how many commits
function Count() constant returns (uint){
  return cCount;
  }


//returns an site at index address
function aSites(uint _index) constant returns (string){
  return cmnts[_index].aSite;
  }

//safety switch
  function kill() {
      if (msg.sender == owner) selfdestruct(owner);
    }
  function bailout() {
    if (!msg.sender.send(this.balance)){
          throw;
      }
    }
  }
