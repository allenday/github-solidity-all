pragma solidity ^0.4.0;

contract D3AssetRequest {
    struct dataAssetRequest{
      bool generalInfo;
      bool allergies;
      bool medications;
      bool conditions;
      bool familyHistory;
      bool observations;
      bool reports;
      bool immunizations;
      bool deviceData;
      bool carePlans;
      uint formatOfData;
      uint validator;
      uint credibility;
      uint valueOfAsset;
      uint expirationDateTime;
      uint timeliness;
      uint completeness;
      uint consistency;
      bool accuracyGuaranteed;
      bool validityGuaranteed;
      uint patientConsentHash;
      address requestor;
    }

    dataAssetRequest storedData;

    function setGeneralInfo(bool x) {
        storedData.generalInfo = x;
    }
    function getGeneralInfo() constant returns (bool) {
        return storedData.generalInfo;
    }

    //allergies
    function setAllergies(bool x) {
        storedData.allergies = x;
    }
    function getAllergies() constant returns (bool) {
        return storedData.allergies;
    }

    //medications
    function setMedications(bool x) {
        storedData.medications = x;
    }
    function getMedications() constant returns (bool) {
        return storedData.medications;
    }


}
