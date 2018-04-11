/*
 * Author: Brett Harvey
 * Title: Dario
 * Date: October 15th, 2017
 */

pragma solidity ^0.4.15;

contract DarioAdministrator {
  address public dario;

  function DarioAdministrator() {
    dario = msg.sender;
  }

  modifier DarioOnly() {
    require(msg.sender == dario);
    _;
  }
}

contract Dario is DarioAdministrator {
  mapping (address => uint256) public DarioToken;
  mapping (address => bool) public Estate;
  mapping (address => bool) ViewMyEstate;
  mapping (string => mapping (address => string)) PrivateKey;

  string public standard = "Dario v1.1";
  uint public EstateCreationFee;

  event EstateAction(address _userAddress, string _eventDetails);
  event DarioToken(address _user, string _event, uint256 amount);

  function Dario(uint256 MintTokenToContract, uint256 SetFee) {
    dario = msg.sender;
    DarioToken[this] = MintTokenToContract;
    DarioToken(this, "Minted Token", MintTokenToContract);
    EstateCreationFee = SetFee;
  }

  function MintDarioToken(address _mintToAddress, uint256 _amount) DarioOnly() {
    DarioToken[_mintToAddress] += _amount;
    DarioToken[this] += _amount;
    DarioToken(_mintToAddress, "Minted New Tokens", _amount);
  }

  modifier EstateOwner() {
    require(Estate[msg.sender] == true);
    _;
  }

  function CreateEstate(address _owner) payable {
    if (DarioToken[msg.sender] >= EstateCreationFee) {
      Estate[_owner] = true;
      ViewMyEstate[_owner] = true;
      EstateAction(_owner, "New Estate Created");
    }
  }
// mapping (string => mapping (address => string)) PrivateKey;
  function AddPrivateKey(string _myPrivateKey, string _MySecretPhrase) {
    PrivateKey[_MySecretPhrase] [msg.sender] = _myPrivateKey;
    EstateAction(msg.sender, "Private key added");
  }

  function ViewMyPrivateKeys(string _MySecretPhrase) EstateOwner()
    returns (string) {
      return PrivateKey[_MySecretPhrase][msg.sender];
      EstateAction(msg.sender, "Viewing Private Keys");
  }
/*
  function AllowSomeoneToViewMyKeys(address _newAddress,
    string secretPhrase) EstateOwner() {
    ViewMyEstate[_newAddress] = true;
    EstateAction(_newAddress, "New Address Added to Viewable");
  }

  function RevokeViewingPrivelege(address _viewingAddress) {
    ViewMyEstate[_viewingAddress] = false;
    EstateAction(_viewingAddress, "Address revoked from viewing");
  }
  */
}
