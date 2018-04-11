
contract Credentials {

    bytes32 public id;
    bool public hasCredentials;
    
    function Credentials(bytes32 _id, bool _hasCredentials) {
        id = _id;
        hasCredentials = _hasCredentials;
    }
}