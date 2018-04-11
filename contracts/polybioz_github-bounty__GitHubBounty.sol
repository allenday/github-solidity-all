import "mortal.sol";
import "oraclizeAPI.sol";

contract GitHubBounty is usingOraclize, mortal {
    
    enum QueryType { IssueState, IssueAssignee, UserAddress }
    
    struct Bounty {
        string issueUrl;
        uint prize;
        uint balance;
        uint queriesDelay;
        string closedAt;
        string assigneeLogin;
        address assigneeAddress;
    }
 
    mapping (bytes32 => bytes32) queriesKey;
    mapping (bytes32 => QueryType) queriesType;
    mapping (bytes32 => Bounty) public bounties;
    bytes32[] public bountiesKey;
    mapping (address => bool) public sponsors;
    
    uint contractBalance;
    
    event SponsorAdded(address sponsorAddr);
    event BountyAdded(bytes32 bountyKey, string issueUrl);
    event IssueStateLoaded(bytes32 bountyKey, string closedAt);
    event IssueAssigneeLoaded(bytes32 bountyKey, string login);
    event UserAddressLoaded(bytes32 bountyKey, string assigneeAddress);
    event SendingBounty(bytes32 bountyKey, uint prize, address assigneeAddress);
    event BountySent(bytes32 bountyKey);
    
    uint oraclizeGasLimit = 1000000;

    function GitHubBounty() {
    }
    
    function addSponsor(address sponsorAddr)
    {
        require(msg.sender == owner);
        sponsors[sponsorAddr] = true;
        SponsorAdded(sponsorAddr);
    }
    
    // issueUrl: full API url of github issue, e.g. https://api.github.com/repos/polybioz/hello-world/issues/6
    // queriesDelay: oraclize queries delay in minutes, e.g. 60*24 for one day, min 1 minute
    function addIssueBounty(string issueUrl, uint queriesDelay) payable {
        require(sponsors[msg.sender]);
        require(bytes(issueUrl).length > 0);
        require(msg.value > 0);
        require(queriesDelay > 0);
        
        queriesDelay = queriesDelay * 60; // convert minutes to seconds
        
        bytes32 bountyKey = sha3(issueUrl);
        
        bounties[bountyKey].issueUrl = issueUrl;
        bounties[bountyKey].prize = msg.value;
        bounties[bountyKey].balance = msg.value;
        bounties[bountyKey].queriesDelay = queriesDelay;
        
        bountiesKey.push(bountyKey);
        
        BountyAdded(bountyKey, issueUrl);
 
        getIssueState(queriesDelay, bountyKey);
    }
     
    function getIssueState(uint delay, bytes32 bountyKey) internal {
        contractBalance = this.balance;
        
        string issueUrl = bounties[bountyKey].issueUrl;
        bytes32 myid = oraclize_query(delay, "URL", strConcat("json(",issueUrl,").closed_at"), oraclizeGasLimit);
        queriesKey[myid] = bountyKey;
        queriesType[myid] = QueryType.IssueState;
        
        bounties[bountyKey].balance -= contractBalance - this.balance;
    }
    
    function getIssueAssignee(uint delay, bytes32 bountyKey) internal {
        contractBalance = this.balance;
        
        string issueUrl = bounties[bountyKey].issueUrl;
        bytes32 myid = oraclize_query(delay, "URL", strConcat("json(",issueUrl,").assignee.login"), oraclizeGasLimit);
        queriesKey[myid] = bountyKey;
        queriesType[myid] = QueryType.IssueAssignee;
        
        bounties[bountyKey].balance -= contractBalance - this.balance;
    }
    
    function getUserAddress(uint delay, bytes32 bountyKey) internal {
        contractBalance = this.balance;
        
        string login = bounties[bountyKey].assigneeLogin;
        string memory url = strConcat("https://api.github.com/users/", login);
        bytes32 myid = oraclize_query(delay, "URL", strConcat("json(",url,").location"), oraclizeGasLimit);
        queriesKey[myid] = bountyKey;
        queriesType[myid] = QueryType.UserAddress;
        
        bounties[bountyKey].balance -= contractBalance - this.balance;
    }
    
    function sendBounty(bytes32 bountyKey) internal {
        string issueUrl = bounties[bountyKey].issueUrl;
        
        SendingBounty(bountyKey, bounties[bountyKey].balance, bounties[bountyKey].assigneeAddress);

        uint transValue = bounties[bountyKey].balance;
        if(transValue > 0) {
            bounties[bountyKey].balance = 0;
            if (!(bounties[bountyKey].assigneeAddress.send(transValue))) {
                throw;                
            }
            BountySent(bountyKey);
        }
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
 
        bytes32 bountyKey = queriesKey[myid];
        QueryType queryType = queriesType[myid];
        uint queriesDelay = bounties[bountyKey].queriesDelay;
        
        if(queryType == QueryType.IssueState) {
            IssueStateLoaded(bountyKey, result);
            if(bytes(result).length <= 4) { // oraclize returns "null"
                getIssueState(queriesDelay, bountyKey);
            }
            else{
                bounties[bountyKey].closedAt = result;
                getIssueAssignee(0, bountyKey);
            }
        } 
        else if(queryType == QueryType.IssueAssignee) {
            IssueAssigneeLoaded(bountyKey, result);
            if(bytes(result).length <= 4) { // oraclize returns "null"
                getIssueAssignee(queriesDelay, bountyKey);
            }
            else {
                bounties[bountyKey].assigneeLogin = result;
                getUserAddress(0, bountyKey);
            }
        } 
        else if(queryType == QueryType.UserAddress) {
            UserAddressLoaded(bountyKey, result);
            if(bytes(result).length <= 4) { // oraclize returns "null"
                getUserAddress(queriesDelay, bountyKey);
            }
            else {
                bounties[bountyKey].assigneeAddress = parseAddr(result);
                sendBounty(bountyKey);
            }
        } 
        
        delete queriesType[myid];
        delete queriesKey[myid];
    }
}