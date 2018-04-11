contract linkedList {

	struct link {
		uint prev;
		uint next;
		bytes32 value;
		uint time;
		address editor;
		uint status;
	}

	struct linkedlist {
		uint head;
		uint tail;
		mapping (uint => link) links;
		uint len;
	}

	function linkExist(linkedlist storage list, uint linkID) internal returns (bool){
		link thisLink = list.links[linkID];
		if (thisLink.status == 0){
			return false;
		} else {
			return true;
		}
	}

	function pushlink(linkedlist storage list, int pos, uint linkID, bytes32 data) internal{

		int curLen = int(list.len);
		if (pos == 0 || (pos <= -curLen)) {
			//Add link to begining of list

			list.links[linkID].next = list.tail;
			list.links[linkID].time = block.timestamp;
			list.links[linkID].value = data;
			list.links[linkID].editor = msg.sender;
			list.links[linkID].status = 1;

			if (list.tail != 0) list.links[list.tail].prev = linkID;
			list.tail = linkID;

			if (list.head == 0) list.head = linkID;

			list.len = list.len + 1;

		} else if (pos >= curLen-1 || pos == -1) {
			//Add link to end of list

			list.links[linkID].prev = list.head;
			list.links[linkID].time = block.timestamp;
			list.links[linkID].value = data;
			list.links[linkID].editor = msg.sender;
			list.links[linkID].status = 1;

			list.links[list.head].next = linkID;
			list.head = linkID;

			if (list.tail == 0) list.tail = linkID;

			list.len = list.len + 1;

		} else {
			//Add link to the middle
			uint prev = findSlot(list, pos);
			uint next = list.links[prev].next;

			list.links[linkID].prev = prev;
			list.links[linkID].next = next;
			list.links[linkID].time = block.timestamp;
			list.links[linkID].value = data;
			list.links[linkID].editor = msg.sender;
			list.links[linkID].status = 1;

			list.links[prev].next = linkID;
			list.links[next].prev = linkID;

			list.len = list.len + 1;
		}
		return;
	}

	function findSlot(linkedlist storage list, int pos) private returns (uint prev){
		//THIS FUNCTION WILL BREAK IF pos = 0
		int middle = int(list.len)/2;
		int posp = 0;

		//Somewhere in the middle
		if (pos > 0  && pos <= middle){
			//start from start
//			return 33;
			prev = findSlotFwd(list, pos);
		} else if (pos > 0 && pos > middle) {
			//start from end
			posp = int(list.len) - pos;
//			return 42;//uint(posp);
			prev = findSlotRev(list, posp);
		} else if (pos < 0 && -pos <= middle) {
			//start from end
			posp = -pos;
//			return 56;//uint(posp);
			prev = findSlotRev(list, posp);
		} else {
			//start from start
			posp = int(list.len) + pos;
			prev = findSlotFwd(list, posp);
		}
		return;
	}

	function findSlotFwd(linkedlist storage list, int pos) private returns (uint pre){
		uint thisl = list.tail;
		for (int i = 1; i < pos; i++){
			thisl = list.links[thisl].next;
		}
		return thisl;
	}

	function findSlotRev(linkedlist storage list, int pos) private returns (uint pre){
		uint thisl = list.head;
		for (int i = 0; i < pos; i++){
			thisl = list.links[thisl].prev;
		}
		return thisl;
	}

	function poplinkat(linkedlist storage list, int pos) internal{
		//Remove link from list at position pos
		int curLen = int(list.len);
		if (pos == 0 || pos <= curLen) {
			//remove tail
			return poplink(list, list.tail);

		} else if (pos >= curLen || pos == -1) {
			//remove head
			return poplink(list, list.head);

		} else {
			//Add link to the middle
			uint prev = findSlot(list, pos);
			uint linkID = list.links[prev].next;

			poplink(list, linkID);
			return;
		}
	}

	function poplink(linkedlist storage list, uint linkID) internal{
		//remove link identified by linkID from list

		if(list.links[linkID].status != 1) return;

		//Remove from list
		uint prev = list.links[linkID].prev;
		uint next = list.links[linkID].next;

		if (prev != 0) list.links[prev].next = next;
		if (next != 0) list.links[next].prev = prev;

		if (linkID == list.head) list.head = prev;
		if (linkID == list.tail) list.tail = next;

		list.len = list.len - 1;

		list.links[linkID].prev = 0;
		list.links[linkID].next = 0;
		list.links[linkID].value = 0;
		list.links[linkID].status = 0;

		return;

	}

	function getlink(linkedlist storage list, uint linkID) internal returns (link){
		//get link
		return list.links[linkID];
	}

	function getlinkdataat(linkedlist storage list, int pos) internal returns (bytes32){
//		return bytes32(list.len);
		int curLen = int(list.len);
		if (pos == 0 || pos <= -curLen) {
			//get tail
			// return bytes32(1);
			return list.links[list.tail].value;

		} else if (pos >= curLen-1 || pos == -1) {
			//get head
			// return bytes32(2);
			return list.links[list.head].value;

		} else {
			//get link in the middle
			// return bytes32(3);
			uint prev = findSlot(list, pos);
			uint linkID = list.links[prev].next;

			return list.links[linkID].value;
		}
	}

	function getlinkat(linkedlist storage list, int pos) internal returns (link){

		int curLen = int(list.len);
		if (pos == 0 || pos <= -curLen) {
			//get tail
			return getlink(list, list.tail);

		} else if (pos >= curLen || pos == -1) {
			//get head
			return getlink(list, list.head);

		} else {
			//get link in the middle
			uint prev = findSlot(list, pos);
			uint linkID = list.links[prev].next;

			return getlink(list, linkID);
		}
	}
}