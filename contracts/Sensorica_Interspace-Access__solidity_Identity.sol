
contract Identity {

    bytes32 public id;
    bytes32 public name;
    
    function Identity(bytes32 _id, bytes32 _name) {
        id = _id;
        name = _name;
    }
}