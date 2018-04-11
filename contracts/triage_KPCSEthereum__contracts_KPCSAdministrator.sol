import {Administrator} from "./Administrator.sol";

contract KPCSAdministrator is Administrator("name", 0x0) {
	function KPCSAdministrator(string _name) {
		name = _name;
		state = State.Accepted;
	}
}
