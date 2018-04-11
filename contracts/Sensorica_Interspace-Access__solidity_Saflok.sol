contract Saflok {

    bytes32 public id;
    bytes32 public expiryDate;
    bytes32 public expiryTime;
    bytes32 public room;


    function Saflok(bytes32 _id, bytes32 _expiryDate, bytes32 _expiryTime, bytes32 _room) {
        id = _id;
        expiryDate = _expiryDate;
        expiryTime = _expiryTime;
        room = _room;
    }
}