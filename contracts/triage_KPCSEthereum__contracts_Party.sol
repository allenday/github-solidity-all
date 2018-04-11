import {User} from "./User.sol";
import {UserType} from "./UserType.sol";

contract Party is User("name", 0x0) {
	string public contactDetails;

	function Party(string _name, address _administrator, string _contactDetails) {
		name = _name;
		contactDetails = _contactDetails;
		state = State.Applied;
		administrator = _administrator;
	}

	function getType() returns (int) {
		return UserType.Party();
	}
}
