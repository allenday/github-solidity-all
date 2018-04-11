/*
# Copyright for Sergey Ponomarev (Jack Bekket)
*/

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract registrator { function register (address _contract,string contractname,address _owner){} }

contract Sample is owned {

string public standard = 'Sample 0.1';

registrator public c_center;

string public createdBy;

string public contractName;

function Sample (

  registrator RegistryCenter,
  string author,
  string NameOfContract

  ) {

    c_center=registrator(RegistryCenter);
    createdBy=author;
    contractName=NameOfContract;
    c_center.register(this,contractName,owner);
  }











}
