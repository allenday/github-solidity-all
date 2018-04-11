contract owned {

	function owned() {
		owner = msg.sender;
	}

	modifier onlyowner() {
		if(msg.sender==owner) _
	}

	address owner;
}

contract mortal is owned {
	function kill() {
		if (msg.sender == owner) suicide(owner); 
	}
}


// use this for debugging
contract Logger {
	event Log0(string msg);
	event Log1(string msg, uint256 a);
	event Log2(string msg, uint256 a, uint256 b);
}

// disable for release
contract NoLogger {
	function Log0(string msg) {}
	function Log1(string msg, uint256 a) {}
	function Log2(string msg, uint256 a, uint256 b) {}
}

contract Roboth is mortal, NoLogger {
	// TODO: consider fees when sending rewards
	// TODO: break it into more contracts when useful
	// TODO: what if word already exists?
	//		or for deleting words
	//		may use a cache on server to keep track of what can be overwritten
	
	uint256 public GAS_TX = 21000;
	uint256 public GAS_PRICE = 60000000000;
	uint256 public FEE_PAYOUT = GAS_TX * GAS_PRICE;


	struct DictJob {
		bytes32 word;
		uint reward;
		uint bl_payout;
		//address owner;

		// TODO: how to list solutions to this job?
		//   IDEA: keep this (redundant data) in the webserver? 
		//		* illustrates the point about saving storage
		//		* even if data on server lost, can be regenerated from blockchain
		//		? would be tricky to sync different versions (easier if data is append-only)
	}

	struct Solution {
		address author;

		// TODO: support longer data, possibly using byte array?
		bytes32 desc;

		int32 votes;

        // so the solution is in an array in userdata together with
        // the jobs from that user. This is index in that array.
        uint32 job_id;
	}

	struct UserData {
        // the jobs current user has created
		mapping (uint32 => DictJob) jobs;

        // the solutions to jobs of this user (all jobs together)
		mapping (uint32 => Solution) solutions;

		// pack them together
		uint32 next_jobid;
		uint32 next_solutionid;
	}

	mapping (address => UserData) public m_userdata;
	mapping (uint32 => address) public m_userdata_idx;
	uint32 public m_next_userid = 0;

	// voter -> sol_user -> sol_id -> delta
	// delta is +1 or -1 or 0 states up, down or no vote
	// voter is the sender of transaction
	// sol_user + sol_id is the id of solution
	mapping (address => mapping(address => mapping(uint32 => int8))) public m_votes;


	/// adds a word to translate
	function createJob(bytes32 word, uint256 bl_duration) {
		if (msg.value < 1 ether) return;   // must provide some reward

		_ensureNewUser();
		UserData usrdat = m_userdata[msg.sender];

		uint32 jobid = usrdat.next_jobid;
		usrdat.jobs[jobid].word = word;
		usrdat.jobs[jobid].reward = msg.value;
		usrdat.jobs[jobid].bl_payout = block.number + bl_duration;
		usrdat.next_jobid += 1;


		// TODO: cant return, only send event
	}

	function addSolution(bytes32 my_desc, address job_user, uint32 job_id) {
		UserData usrdat = m_userdata[job_user];
        if (usrdat.next_jobid <= job_id) {
            // the job does not exist, maybe the whole 'usrdat' doesn't exist
            return;
        }

		uint32 solid = usrdat.next_solutionid;
		usrdat.solutions[solid].desc = my_desc;
		usrdat.solutions[solid].author = msg.sender;
		usrdat.solutions[solid].job_id = job_id;
		usrdat.solutions[solid].votes = 0;
		usrdat.next_solutionid += 1;
	}

	function solUpDownVote(bool up, uint32 sol_id, address job_user) {
		int8 delta = 1;
		if (up == false) delta = -1;

        // anti-ghost measures, each voting account must have at least 100 ether
        if (msg.sender.balance < 100 ether) return;

		if (m_votes[msg.sender][job_user][sol_id] == delta) return;

		m_userdata[job_user].solutions[sol_id].votes += delta;
		m_votes[msg.sender][job_user][sol_id] += delta;
	}

	// TODO: before payout, I can check the balance of all upvoters and downvoters that it's nontrivial and thus they are not zombie accounts
	function checkPayout(address job_user, uint32 sol_id) returns (bool) {
		UserData usrdata = m_userdata[job_user];
		Solution this_sol = usrdata.solutions[sol_id];
		var this_job_id = this_sol.job_id;
		if (block.number < usrdata.jobs[this_job_id].bl_payout) return false;

		var this_votes = this_sol.votes;
		for (var i = 0; i < usrdata.next_solutionid; i++) {
			// different job of the same user
			if (usrdata.solutions[i].job_id != this_job_id) continue;

			if (usrdata.solutions[i].votes > this_votes) {
				return false;
			}
		}

		// ok, I'm eligible!
		var job = usrdata.jobs[this_job_id];
		if (job.reward > 0) {
			this_sol.author.send(job.reward - FEE_PAYOUT);

			job.reward = 0;
			return true;
		}
		return false;
	}

	// ======= Accessors
	function getDictJob(address user, uint32 id) public constant returns (bytes32 word, uint reward, uint256 bl_payout) {
		DictJob j = m_userdata[user].jobs[id];

		word = j.word;
		reward = j.reward;
		bl_payout = j.bl_payout;
	}

	function getSolution(address user, uint32 id) public constant returns (address author, uint32 job_id, bytes32 desc, int32 votes) {
		Solution s = m_userdata[user].solutions[id];

		author = s.author;
		job_id = s.job_id;
		desc = s.desc;
		votes = s.votes;
	}

	function getVote(address voter, address sol_user, uint32 sol_id) returns (int8){
		return m_votes[voter][sol_user][sol_id];
	}

	// ======= Internal State Management

	function _isNewUser() private returns (bool) {
		UserData usrdat = m_userdata[msg.sender];
        // NEVER: (usrdat.next_solutionid > 0 && (usrdat.next_jobid == 0)

		// is new user when next_jobid or next_solutionid is nonzero
		// because any write to that struct would increase these numbers
		if (usrdat.next_jobid > 0) {
			return false;
		} else {
			return true;
		}
	}

	function _ensureNewUser() private returns (bool) {
		bool isnew = _isNewUser();

		if (isnew) {
			m_userdata_idx[m_next_userid] = msg.sender;
			m_next_userid += 1;

		} else {
			return isnew;
		}
	}

	// ============= Internal administration
	function _setGasPrice(uint256 val) onlyowner {
		GAS_PRICE = val;
	}
}
