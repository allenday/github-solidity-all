import "User.sol";
import "Task.sol";

contract Linker {

    // TODO extend with eventObject if possible; `bytes32[]`?
    event ActionEvent(address indexed userAddr, bytes32 actionType);
    function registerActionEvent(bytes32 actionType) {
      ActionEvent(msg.sender, actionType);
    }


    function linkTaskToUser(address taskAddr, address userAddr) returns (bool) {
        registerActionEvent('LINK TASK TO USER');
        return User(userAddr).associateWithTaskAddress(taskAddr);
    }

    function linkTeamToUser(address userAddress, bytes32 teamname) returns (bool) {
        registerActionEvent('LINK TEAM TO USER');
        return User(userAddress).associateWithTeam(teamname);
    }

    function linkFileToTask(address taskAddr, bytes32 fileHash) returns (bool) {
        registerActionEvent('LINK FILE TO TASK');
        return Task(taskAddr).associateWithFile(fileHash);
    }

}
