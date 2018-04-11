// Advertising Machine
//
// The advertising machine allows the sponsor to make several settings related
// to how the viewer will consume the advertising such a list of urls to
// distribute to the viewer. Additionally, such things as a list of questions
// to ask the viewer after consuming the advertising, what types of information
// to ask of the user, etc.
contract advert_machine
{
	// While the contract is deployed by the 'host' of the group,
	// the machine is assigned to a curator, who would normally be
	// the sponsor. The sponse makes all settings related to how
	// the contract operates.
	//
	// state variables:
	string urls[];
	uint nURLs;
	struct View {
		string viewer_email;
		string url_consumed;
		uint when_consumed;
	};
	View views[];
	bool email__req;

	modifier isAdmin() {
		if (msg.sender != admin)
			throw;
		_
	}

	function advert_machine()
	{
	}

	function pickURL() return string {
		return urls[block.timestamp%nURLs]
	}

	function addURL(string url) isAdmin() {
		urls[nUrls++]=url;
	}

	function removeURL(string url, uint n) isAdmin() {
		if (urls[n] == url)
			urls[n]="";
		cleaupURLs();
	}

	function cleanupURLs() internal {
		uint cnt=0;
		for (i=0;i<nURLs;i++) {
			if (urls[i]!="")
				urls[cnt++] = urls[i];
		}
		nUrls=cnt;
	}

	function require_email(bool req) {
		email_req = req;
	}

	function watchedURL(string url, string email) returns hash {
		if (!findURL(url))
			throw;
		if (email_req && email.isempty())
			throw;
		return sha256(url+email+timestamp);
	}
}
