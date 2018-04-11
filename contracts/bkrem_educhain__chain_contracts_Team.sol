import "SequenceArray.sol";

contract Team {

    bytes32 public name;
    bytes32 public score;
    bytes32 public founderUsername;
    address public founderAddress;
    bytes32 public createdAt;

    // SequenceArray to manage the members of this team.
    SequenceArray members = new SequenceArray();

    // SequenceArray to track all task addresses associated
    // with this Team contract.
    SequenceArray taskAddressList = new SequenceArray();

    // Constructor
    function Team(
        bytes32 _name,
        bytes32 _founderUsername,
        address _founderAddress,
        bytes32 _createdAt)
        {
        name = _name;
        founderUsername = _founderUsername;
        founderAddress = _founderAddress;
        createdAt = _createdAt;

        // initialise score to `0`
        score = '0';

        // team members are tracked in a SequenceArray
        members.insert(_founderUsername, _founderAddress);
    }

    // ###############
    // MEMBER METHODS
    // ###############
    function addMember(bytes32 _username, address _userAddr) returns (bool) {
        return members.insert(_username, _userAddr);
    }

    function removeMember(bytes32 _username) returns (bool) {
        // Set the value at key `_username` to null address,
        // regardless of whether it was set to start with
        return members.insert(_username, 0x0);
    }

    function getMemberAtIndex(uint _idx) constant returns (address, uint) {
        return members.valueAtIndexHasNext(_idx);
    }


    // ###############
    // TASKLIST METHODS
    // ###############

}
