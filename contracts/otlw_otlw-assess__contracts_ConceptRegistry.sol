pragma solidity ^0.4.11;

import "./Concept.sol";

//@purpose: To create and store the concept ontology
contract ConceptRegistry {
    mapping (address => bool) public conceptExists;
    address public fathomToken;
    bool initialized = false;
    address public mewAddress; //a manually created contract with no parents
    address public distributorAddress; //a manually created contract with no parents

    event ConceptCreation (address _concept);

    //@purpose: give this contract the address of a UserRegistry and mew Concept
    function init(address _token, address _distributor) public {
        if (initialized == false) {
            fathomToken = _token;
            distributorAddress = _distributor;
            Concept mew = new Concept(new address[] (0), new uint[] (0), uint(2**255), "", address(0x0));
            mewAddress = address(mew);
            conceptExists[mewAddress] = true;
            initialized = true;
        }
    }

    /*
      @purpose: To make a concept
      @param: address[] parentList = an array of addresses containing the addresses of the concepts parents
    */
    function makeConcept(address[] parentList, uint[] _propagationRates, uint _lifetime, bytes _data, address _owner) public returns (address){
        require(parentList.length > 0);
        Concept newConcept = new Concept(parentList, _propagationRates, _lifetime, _data, _owner);

        conceptExists[address(newConcept)] = true;
        ConceptCreation(address(newConcept));
        return address(newConcept);
    }
}
