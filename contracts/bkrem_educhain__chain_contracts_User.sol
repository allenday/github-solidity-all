import "SequenceArray.sol";

contract User {

    bytes32 public id;
    bytes32 public username;
    bytes32 public email;
    bytes32 public name;
    bytes32 public password;

    bytes32 public score; // TODO

    bytes32 public teamname;

    // SequenceArray to track all task addresses associated
    // to this User contract.
    SequenceArray taskAddressList = new SequenceArray();

    // Constructor
    function User(
        bytes32 _id,
        bytes32 _username,
        bytes32 _email,
        bytes32 _name,
        bytes32 _password
        ) {
            id = _id;
            username = _username;
            email = _email;
            name = _name;
            password = _password;

            // initialise the `score` field
            score = '0';
    }

    function associateWithTaskAddress(address _taskAddr) returns (bool isOverwrite) {
        isOverwrite = taskAddressList.insert(bytes32(_taskAddr), _taskAddr);
        return isOverwrite;
    }

    function associateWithTeam(bytes32 _teamname) returns (bool) {
        teamname = _teamname;
        return true;
    }

    function hasTeam() returns (bool) {
        if (teamname != 0x0) {
            return true;
        } else {
            return false;
        }
    }

    function getUserTaskAtIndex(uint _idx) constant returns (address, uint) {
        return taskAddressList.valueAtIndexHasNext(_idx);
    }

}
