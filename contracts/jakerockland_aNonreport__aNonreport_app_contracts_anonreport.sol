contract AnonReport {
  uint public storedData;
  Upload[] public uploads;
  event UploadAdded(uint256 uploadID, bytes32 Hash, string Location, uint16 Date, bytes32 FileLocation);
  struct Upload {
    bytes32 Hash;
    string Location;
    uint16 Date;
    bytes32 FileLocation;
  }

  function AnonReport(uint initialValue) {
    storedData = initialValue;
  }

  function set(uint x) {
    storedData = x;
  }
  function get() constant returns (uint retVal) {
    return storedData;
  }
  Upload up;
  function getHash(uint256 index) constant returns(bytes32 a) {
    up=uploads[index];
    a = up.Hash;
  }
  function getLocation(uint256 index) constant returns(string b) {
    up=uploads[index];
    b = up.Location;
  }
  function getDate(uint256 index) constant returns(uint16 c) {
    up=uploads[index];
    c = up.Date;
  }
  function getFileLoc(uint256 index) constant returns(bytes32 d) {
    up=uploads[index];
    d = up.FileLocation;
  }
  function getUpCount() constant returns(uint256 num) {
    return uploads.length;
  }

  function newUpload(bytes32 _Hash, string _Location, uint16 _Date, bytes32 _FileLocation) returns(uint256 uploadID){
    uploadID = uploads.length;
    Upload u = uploads[uploadID];
    u.Hash=_Hash;
    u.Location=_Location;
    u.Date=_Date;
    u.FileLocation=_FileLocation;
    UploadAdded(uploadID,_Hash,_Location,_Date,_FileLocation);
  }
}
