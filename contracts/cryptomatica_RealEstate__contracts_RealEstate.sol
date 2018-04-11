// An Ethereum Dapp that:
// i. Allows a real estate agent to register a new person
// ii. Allows a real estate agent to register a property sale against a registered person

//Note this app is used to help the author develop their skills in Solidity and is not meant to be used in any
//production environment

pragma solidity ^0.4.11;


//Define the RealEstate contract
contract RealEstate {

  //Define the owner of the contract
  address public owner;

  //Create a variable to count the number of persons
  uint personCount;
  //Create a variable to count the number of property
  uint PropertyCount;

  //A modifier to restrict usage of functions to owner
  modifier restricted() {
    if (msg.sender == owner) _;
  }

  //Create an event which registers the latest number of property listings
  event PropertyCounter(uint ActivePropertyCounter);

  //Create an event which registers the latest number of persons registered
  event PersonsCounter(uint CurrentPersonsCounter);

  //Define RealEstate function
  function RealEstate(uint initial) {

    //Entering a person count parameter for initializing testing purposes in Truffle
    personCount = initial;
    //Define the owner as the one deploying the contract
    owner = msg.sender;
  }

// returns the personCount
function getpersonCount() constant returns (uint){
  return personCount;
  }

// returns the PropertyCount
function getPropertyCount() constant returns (uint){
  return PropertyCount;
  }

//=================Persons Map, Struct and Arrays START=================//

//Create a mapping table to store persons
mapping (bytes32 => Persons) public PersonMap;

//Create a struct to store the details of a person
struct Persons{
  bytes32 FirstName; //First name of person
  bytes32 LastName; //Last name of person
  bytes32 Gender; //Gender of person
  uint DateOfBirth; //Date of birth of person
  bytes32 ImageLink; //File name to retreive person photo from the Sia storage network
  address PersonAddress; //Register the Ethereum
}

//Create an array to store the person keys
bytes32[] PersonsArray;

// Add person
function addPerson(bytes32 NationalID, bytes32 FirstName, bytes32 LastName, bytes32 Gender, uint DateOfBirth, bytes32 ImageLink, address PersonAddress) {

  var NewPerson = Persons(FirstName, LastName, Gender, DateOfBirth, ImageLink, PersonAddress);
  PersonMap[NationalID] = NewPerson;
  personCount++;
  PersonsCounter(personCount);
  PersonsArray.push(NationalID);
}

//Delete person
function removePerson(bytes32 NationalID) restricted {
    delete PersonMap[NationalID];
    personCount--;
}

//Return the details of a given person
  function getPerson(bytes32 NationalID) constant returns (bytes32 FirstName, bytes32 LastName, bytes32 Gender, uint DateOfBirth, bytes32 ImageLink, address PersonAddress) {
    return (PersonMap[NationalID].FirstName, PersonMap[NationalID].LastName, PersonMap[NationalID].Gender, PersonMap[NationalID].DateOfBirth, PersonMap[NationalID].ImageLink, PersonMap[NationalID].PersonAddress);
}

//List all registered persons
  function listPersons() constant returns (
    bytes32[] NationalID, bytes32[] FirstName, bytes32[] LastName, bytes32[] Gender, uint[] DateOfBirth, bytes32[] ImageLink, address[] Addresses
    )  {

      //Create arrays to store each of the individual details of a person
      bytes32[] memory NationalIDArray= new bytes32[](personCount);
      bytes32[] memory FirstNameArray= new bytes32[](personCount);
      bytes32[] memory LastNameArray= new bytes32[](personCount);
      bytes32[] memory GenderArray= new bytes32[](personCount);
      uint256[] memory DateOfBirthArray= new uint256[](personCount);
      bytes32[] memory ImageLinkArray= new bytes32[](personCount);
      address[] memory AddressArray= new address[](personCount);

    //Store the persons details into the arrays
    for(uint i = 0; i<personCount; i++){
    NationalIDArray[i] = PersonsArray[i];
    FirstNameArray[i] = PersonMap[PersonsArray[i]].FirstName;
    LastNameArray[i] = PersonMap[PersonsArray[i]].LastName;
    GenderArray[i] = PersonMap[PersonsArray[i]].Gender;
    DateOfBirthArray[i] = PersonMap[PersonsArray[i]].DateOfBirth;
    ImageLinkArray[i] = PersonMap[PersonsArray[i]].ImageLink;
    AddressArray[i] = PersonMap[PersonsArray[i]].PersonAddress;
  }
//Return the arrays containing person information
return ( NationalIDArray,FirstNameArray,LastNameArray,GenderArray,DateOfBirthArray,ImageLinkArray,AddressArray
  );
}
//=================Persons Map, Struct and Arrays END=================//


//=================Properties Map, Struct and Arrays START=================//
//Create a mapping table to store property
mapping (bytes32 => Property) public PropertyMap;

//Create a struct to store the details of a property
struct Property{
  bytes32 PropertyType;
  bytes32 Address;
  bytes32 City;
  uint ZipCode;
  bytes32 Country;
  bytes32 ImageLink;
  bytes32 NationalID;
  uint SaleValue;
}

//Create an array to store the property keys
bytes32[] PropertyArray;

// Add property
function addProperty(bytes32 NationalID, bytes32 PropertyID, bytes32 PropertyType, bytes32 Address, bytes32 City, uint ZipCode, bytes32 Country, bytes32 ImageLink, uint SaleValue) {

  var NewProperty = Property(PropertyType, Address, City, ZipCode, Country, ImageLink, NationalID, SaleValue);
  PropertyMap[PropertyID] = NewProperty;
  PropertyCount++;
  PropertyCounter(PropertyCount);//Add the number properties to the event
  PropertyArray.push(PropertyID);
}

//Delete property
function removeProperty(bytes32 PropertyID) restricted {
    delete PropertyMap[PropertyID];
    PropertyCount--;
}

//Return the details of a given property
  function getProperty(bytes32 PropertyID) constant returns (bytes32 PropertyType, bytes32 Address, bytes32 City, uint ZipCode, uint SaleValue) {
    return (PropertyMap[PropertyID].PropertyType, PropertyMap[PropertyID].Address, PropertyMap[PropertyID].City, PropertyMap[PropertyID].ZipCode, PropertyMap[PropertyID].SaleValue);
}

//List all properties
  function listProperty() constant returns (
     bytes32[] PropertyID, bytes32[] NationalID, bytes32[] PropertyType, bytes32[] Address, bytes32[] City, uint[] ZipCode, uint[] SaleValue
    )  {

      //Create arrays to store each of the individual details of a property
      bytes32[] memory PropertyIDArray= new bytes32[](PropertyCount);
      bytes32[] memory NationalIDArray= new bytes32[](PropertyCount);
      bytes32[] memory PropertyTypeArray= new bytes32[](PropertyCount);
      bytes32[] memory AddressArray= new bytes32[](PropertyCount);
      bytes32[] memory CityArray= new bytes32[](PropertyCount);
      uint256[] memory ZipCodeArray= new uint256[](PropertyCount);
      uint256[] memory SaleValueArray= new uint256[](PropertyCount);

    //Store the properties details into the arrays
    for(uint i = 0; i<PropertyCount; i++){
    PropertyIDArray[i] = PropertyArray[i];
    NationalIDArray[i] = PropertyMap[PropertyArray[i]].NationalID;
    PropertyTypeArray[i] = PropertyMap[PropertyArray[i]].PropertyType;
    AddressArray[i] = PropertyMap[PropertyArray[i]].Address;
    CityArray[i] = PropertyMap[PropertyArray[i]].City;
    ZipCodeArray[i] = PropertyMap[PropertyArray[i]].ZipCode;
    SaleValueArray[i] = PropertyMap[PropertyArray[i]].SaleValue;
}
//Return property details arrays
return ( PropertyIDArray,NationalIDArray,PropertyTypeArray,AddressArray,CityArray,ZipCodeArray,SaleValueArray
  );
}
//=================Properties Map, Struct and Arrays END=================//
}
