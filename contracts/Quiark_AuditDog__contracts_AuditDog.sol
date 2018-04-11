contract AuditDog {
	/*
	bytes HASH_SHA3 = "sha3";
	bytes HASH_GIT_COMMIT = "gitcommit";
	bytes HASH_SHA256 = "sha256";

	// when I'm the owner of the previous claim
	bytes CLAIM_DELETE_REF = "delete ref";

	// when I disagree with another claim
	bytes CLAIM_DISPUTE_REF = "dispute ref";

	// when I want to +1 another claim
	bytes CLAIM_CONFIRM_REF = "confirm ref";

	// when I want to modify or comment on my previous claim
	bytes CLAIM_AMEND_REF = "amend ref";
	*/


	// A claim someone has made about the security of a particular software
	// package.
	struct Claim {
		// address of the person who created this claim
		address author;

		// identifier of the software package the claim is about
		uint32 sw_ix;

		// It can be one of predefined CLAIM_ constants
		// or an URL
		// or just plain text
		string claim;
		
		// the rawbytes hash of the contents of the claim_url
		bytes32 claim_hash;

		// how to interpret the claim_hash, see one of HASH_ values
		bytes32 claim_hash_type;

		// it's possible to reference another claim, for example to say
		// that it's invalid. The claim may be present in a previous version
		// of the AuditDog contract.
		address claim_ref_adog;

		// just the index of the referenced claim
		uint32 claim_ref_ix;

		// the block number when this claim was created, for use in other contracts
		uint bl_created;
	}

	// A unique identifier of a software package and its version present
	// somewhere on the internet.
	struct Software {
		// a human readable value
		string name;

		// url
		string git_repo;

		// the git commit hash in raw bytes (exactly the same hexnumber as seen in git log)
		bytes32 git_commit;

		// an optional additional HMAC or something
		bytes32 extra_auth;

		// see one of HASH_ predefined values
		bytes32 extra_auth_type;
	}

	event OnNewSoftware(uint indexed id);
	event OnNewClaimForSw(uint indexed claim_id, uint indexed sw_id);

	// TODO: add events, when new claim added, or new claim for a software is added

	Software[] public m_software;
	Claim[] public m_claims;

	function GetSoftwareCount() public returns (uint) {
		return m_software.length;
	}

	function GetClaimCount() public returns (uint) {
		return m_claims.length;
	}

	function AddSoftware(string name, string git_repo, bytes32 git_commit, bytes32 extra_auth, bytes32 extra_auth_type) returns (uint32) {
		uint32 sw_ix = uint32(m_software.length);
		m_software.length += 1;
		Software item = m_software[sw_ix];

		item.name = name;
		item.git_repo = git_repo;
		item.git_commit = git_commit;
		item.extra_auth = extra_auth;
		item.extra_auth_type = extra_auth_type;

		OnNewSoftware(sw_ix);
		return sw_ix;
	}

	function AddClaim(uint32 sw_ix, string claim, bytes32 claim_hash, bytes32 claim_hash_type, address claim_ref_adog, uint32 claim_ref_ix) returns (uint32) {
		if (sw_ix >= m_software.length) return;

		uint32 cl_ix = uint32(m_claims.length);
		m_claims.length += 1;
		Claim item = m_claims[cl_ix];
		item.author = msg.sender;
		item.sw_ix = sw_ix;
		item.claim = claim;
		item.claim_hash = claim_hash;
		item.claim_hash_type = claim_hash_type;
		item.claim_ref_adog = claim_ref_adog;
		item.claim_ref_ix = claim_ref_ix;
		item.bl_created = block.number;

		OnNewClaimForSw(cl_ix, item.sw_ix);
		return cl_ix;
	}

	function AddSWAndClaim(string name, string git_repo, bytes32 git_commit, bytes32 extra_auth, bytes32 extra_auth_type,
						   string claim, bytes32 claim_hash, bytes32 claim_hash_type, address claim_ref_adog, uint32 claim_ref_ix)
						   returns (uint32) {
		uint32 sw_ix = AddSoftware(name, git_repo, git_commit, extra_auth, extra_auth_type);
		uint32 cl_ix = AddClaim(sw_ix, claim, claim_hash, claim_hash_type, claim_ref_adog, claim_ref_ix);
		return cl_ix;
    }

	// TODO: search by other stuff
	// TODO: search by author, somehow
		/*
	function SearchByGit(bytes git_repo) returns (uint) {
		for (uint i = 0; i < m_software.length; i++) {
			if (m_software[i].git_repo == git_repo) return i;
		}
		return 0;
	}
		*/
}

/*
contract AuditDogAbi {
	function m_software(uint ix) constant public returns (bytes, bytes, bytes32, bytes32, bytes32);
}

contract Tester {
	// TODO: test that all data is available from other contracts

	function run(address addr) returns (bytes) {
		AuditDogAbi dog = AuditDogAbi(addr);
		//var s = dog.m_software(0);
		var r = complex();
	}

	function complex() constant returns (int32 r, int32 i, bytes z) {
		i = 4;
		r = 89;
		z = "bcd";
	}
}
*/
