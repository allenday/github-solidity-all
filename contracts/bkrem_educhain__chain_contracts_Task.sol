import "SequenceArray.sol";

contract Task {

    bytes32 public id; // immutable
    bytes32 public title; // mutable
    bytes32 public desc; // mutable
    bytes32 public status; // mutable
    bytes32 public complete; // mutable
    bytes32 public reward; // immutable
    bytes32 public participants; // mutable
    bytes32 public creator; // immutable
    bytes32 public createdAt; // immutable
    bytes32 public token; // immutable

    SequenceArray attachments = new SequenceArray();

    // Constructor
    function Task(
        bytes32 _id,
        bytes32 _title,
        bytes32 _desc,
        bytes32 _status,
        bytes32 _complete,
        bytes32 _reward,
        bytes32 _participants,
        bytes32 _creator,
        bytes32 _createdAt,
        bytes32 _token) {
        id = _id;
        title = _title;
        desc = _desc;
        status = _status;
        complete = _complete;
        reward = _reward;
        participants = _participants;
        creator = _creator;
        createdAt = _createdAt;
        token = _token;
    }

    function associateWithFile(bytes32 fileHash) returns (bool isOverwrite) {
        isOverwrite = attachments.insert(fileHash, this);
        return isOverwrite;
    }

    function markComplete(bytes32 _status) returns (bool success) {
        status = _status;
        success = true;
        return success;
    }
}
