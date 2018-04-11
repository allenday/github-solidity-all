contract Lendr
{
	struct Friend {
		address addr;
		string name;
	}
	
	struct LendRecord {
		int quantity;
		int newQuantity;
		bool[2] confirmed;
	}
	
	bool confirmed;
	Friend[2] friend;
	mapping (string => LendRecord) records;

	function Lendr(string name, string friend2_address)
	{
		friend[1].addr = msg.sender;
		friend[1].name = name;
		confirmed = false;
	}
	
	function confirmFriendship(string name)
	{
		if(msg.sender == friend[2].addr) {
			friend[2].name = name;
			confirmed = true;
		}
	}
	
	function setQuantity(string item, int quantity)
	{
		if(msg.sender == friend[1].addr) {
			records[item].newQuantity = quantity;
			records[item].confirmed[1] = true;
			records[item].confirmed[2] = false;
		}
		else if(msg.sender == friend[2].addr) {
			records[item].newQuantity = quantity;
			records[item].confirmed[2] = true;
			records[item].confirmed[1] = false;
		}
	}
	
	function confirm(string item, int quantity)
	{
		if(records[item].newQuantity == quantity) {
			if(msg.sender == friend[1].addr) {
				records[item].confirmed[1] = true;
			}
			else if(msg.sender == friend[2].addr) {
				records[item].confirmed[2] = true;
			}
			
			if(records[item].confirmed[1] &&
			   records[item].confirmed[2]) {
				records[item].quantity = records[item].newQuantity;
			}
		}
	}
}
