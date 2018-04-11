pragma solidity ^0.4.6;
contract KycDetails {

struct Kyc{
    string name;
    string email;
    uint phoneNo;
    uint aadharNo;
    string panNo;
    string aadhar_file;
    string pan_file;
    string fingerprint;
    uint credit_score;
}

address k;
mapping(address => Kyc) kycs;

  function createKycData(address _account,string _name, string _email, uint _phoneNo, uint _aadharNo, string _panNo, string _aadhar_file,
  string _pan_file, string _fingerprint, uint _credit_score) {

    var _kyc = Kyc({
      name: _name,
      email: _email,
      phoneNo:_phoneNo,
      aadharNo:_aadharNo,
      panNo:_panNo,
      aadhar_file:_aadhar_file,
      pan_file:_pan_file,
      fingerprint:_fingerprint,
      credit_score:_credit_score
    });

    kycs[_account] =_kyc;
}

}
