pragma solidity ^0.4.16;

import "utils/IToken.sol";


contract IMiniMeTokenController {
  function onTransfer(address _from, address _to, uint256 _value) public constant returns (bool);
  function onApprove(address _from, address _spender, uint256 _value) public constant returns (bool);
  function proxyPayment(address _sender) payable public returns (bool);
}

contract ITokenFactory {
  function createCloneToken(address, uint256, string, uint8, string, bool) public returns (address);
}

contract MiniMeToken is IToken {
  modifier canApprove(address _spender, uint256 _value) {
    if (isContract(controller)) {
      require(controller.onApprove(msg.sender, _spender, _value));
    }
    if (_value != 0) _;
  }

  modifier onlyController() {
    require(msg.sender == address(controller)); _;
  }

  function MiniMeToken(
      address _tokenFactory,
      address _parent,
      uint256 _snapShotBlock,
      string _tokenName,
      uint8 _decimalUnits,
      string _tokenSymbol,
      bool _transfersEnabled) public {
    tokenFactory = ITokenFactory(_tokenFactory);
    parent = MiniMeToken(_parent);
    controller = IMiniMeTokenController(msg.sender);
    snapShotBlock = _snapShotBlock;
    transfersEnabled = _transfersEnabled;

    name = _tokenName;                                   // Set the name for display purposes
    decimals = _decimalUnits;                            // Amount of decimals for display purposes
    symbol = _tokenSymbol;                               // Set the symbol for display purposes
  }

  function () public payable {
    require(isContract(controller) && controller.proxyPayment.value(msg.value)(msg.sender));
  }

  function changeController(address _newController) public onlyController {
    controller = IMiniMeTokenController(_newController);
  }

  function generateTokens(address _to, uint256 _value) public onlyController returns (bool success) {
    recordToTransfer(address(this), _value, 0);
    recordToTransfer(_to, _value, 0);
    return true;
  }

  function destroyTokens(address _owner, uint _amount) onlyController returns (bool) {
    recordTransfer(_owner, address(0), _amount, balanceOf(_owner));
    return true;
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    uint fromBalance = balanceOf(msg.sender);

    if (fromBalance >= _value && _value > 0) {
      recordTransfer(msg.sender, _to, _value, fromBalance);
      return true;
    } else { return false; }
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    uint fromBalance = balanceOf(_from);

    if (fromBalance >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      recordTransfer(_from, _to, _value, fromBalance);
      allowed[_from][msg.sender] -= _value;
      return true;
    } else { return false; }
  }

  function recordTransfer(address _from, address _to, uint256 _value, uint256 _fromBalance) internal {
    if (isContract(controller)) {
      require(controller.onTransfer(_from, _to, _value));
    }
    require(_to != address(this) && transfersEnabled && _fromBalance >= _value);

    recordToTransfer(_from, 0, _value);
    recordToTransfer(_to, _value, 0);
    Transfer(_from, _to, _value);
  }

  function recordToTransfer(address _owner, uint256 _valuePositive, uint256 _valueNegative) internal {
    uint currentBalance = balanceOf(_owner);
    balanceAtData[_owner][0][block.number] = currentBalance + _valuePositive - _valueNegative;
    balanceAtRecords[_owner].push(block.number);
    balanceAtData[_owner][1][block.timestamp] = currentBalance + _valuePositive - _valueNegative;
    balanceAtRecords[_owner].push(block.timestamp);
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balanceOfAt(_owner, block.number);
  }

  function approve(address _spender, uint256 _value) public canApprove(_spender, _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public payable returns (bool success) {
    approve(_spender, _value);
    require(_spender.call.value(msg.value)(bytes4(sha3("receiveApproval(address,uint256,address,bytes)")), msg.sender, _value, this, _extraData));
    return true;
  }

  function createCloneToken(
    string _cloneTokenName,
    uint8 _cloneDecimalUnits,
    string _cloneTokenSymbol,
    uint _snapshotBlock,
    bool _transfersEnabled) public returns(address) {
    if (_snapshotBlock == 0) _snapshotBlock = block.number;
    address cloneToken = tokenFactory.createCloneToken(
        this,
        _snapshotBlock,
        _cloneTokenName,
        _cloneDecimalUnits,
        _cloneTokenSymbol,
        _transfersEnabled);
    NewCloneToken(cloneToken, _snapshotBlock);
    return cloneToken;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  function closest(uint256 _targetValue, uint256 _recordType, address _sender) internal constant returns (uint256) {
    uint256[] storage targetArray = balanceAtRecords[_sender];
    if (targetArray.length == 0) { return 0; }

    uint256 current = targetArray[0];

    for (uint256 i = _recordType; i < targetArray.length; i += 2)
      if ((_targetValue - targetArray[i]) < (_targetValue - current)) current = targetArray[i];

    return current;
  }

  function hasTransfers(address _owner) internal constant returns (bool) {
    return (balanceAtRecords[_owner].length > 0);
  }

  function genesisTransfer(address _owner, uint256 _recordType) internal constant returns (uint256) {
    return balanceAtData[_owner][_recordType][balanceAtRecords[_owner][_recordType]];
  }

  function balanceOfAtType(address _owner, uint256 _blockNumber, uint256 _recordType) public constant returns (uint256) {
    if (address(parent) != address(0) && (!hasTransfers(_owner) || genesisTransfer(_owner, _recordType) > _blockNumber))
      return parent.balanceOfAtType(_owner, snapShotBlock, _recordType);

    return balanceAtData[_owner][_recordType][closest(_blockNumber, _recordType, _owner)];
  }

  function balanceOfAt(address _owner, uint256 _blockNumber) public constant returns (uint256) {
    return balanceOfAtType(_owner, _blockNumber, 0);
  }

  function balanceOfAtTime(address _owner, uint256 _time) public constant returns (uint256) {
    return balanceOfAtType(_owner, _time, 1);
  }

  function totalSupply() public constant returns (uint256) {
    return totalSupplyAt(block.number);
  }

  function totalSupplyAt(uint256 _blockNumber) public constant returns (uint256) {
    return balanceOfAt(address(this), _blockNumber) - balanceOfAt(address(0), _blockNumber);
  }

  function totalSupplyAtTime(uint256 _time) public constant returns (uint256) {
    return balanceOfAtTime(address(this), _time) - balanceOfAtTime(address(0), _time);
  }

  function isContract(address _addr) constant internal returns(bool ret) {
    if (_addr == address(0)) return false;
    assembly { ret := gt(extcodesize(_addr), 0) }
  }

  function enableTransfers(bool _transfersEnabled) public onlyController {
    transfersEnabled = _transfersEnabled;
  }

  event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);

  string public name;                   // fancy name: eg Simon Bucks
  uint8 public decimals;                // How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
  string public symbol;                 // An identifier: eg SBX
  string public version = 'H0.1';       // human 0.1 standard. Just an arbitrary versioning scheme

  ITokenFactory public tokenFactory;
  MiniMeToken public parent;
  IMiniMeTokenController public controller;

  bool transfersEnabled;
  uint256 public snapShotBlock;
  uint256 public initialAmount;

  mapping (address => mapping (address => uint256)) allowed;
  mapping (address => mapping(uint256 => mapping(uint256 => uint256))) balanceAtData;
  mapping (address => uint256[]) balanceAtRecords;
}
