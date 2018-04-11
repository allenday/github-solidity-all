
import "owned.sol";

contract blocktubeTag is owned  {

	 string public name;

	function blocktubeTag(string _name) onlyOwner {
		name = _name;
	}


}
