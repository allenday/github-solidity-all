pragma solidity ^0.4.10;

contract AutonomousSoftwareOrg {

    struct SoftwareVersionRecord {
	address   submitter    ; 
	bytes32   url          ;
	bytes32   version      ; 
	uint256   sourcehash   ;       
    }
    
    struct SoftwareExecRecord {
	address   submitter       ; 
	bytes32   softwareversion ; 
	bytes32   url             ;
	uint256   inputhash       ;       
	uint256   outputhash      ;
    }
    
    struct MemberInfo {
	bytes32   url                     ;
	address memberaddr                ;
	uint    votecount                 ;
	mapping(address => bool)   voted  ;
    }

    struct Proposal {
	bytes32   title                   ;
	bytes32   url                     ;
	uint256   prophash                ;
	address   proposer                ;
	uint      requestedfund           ;
	uint      deadline                ;
	uint      votecount               ;
	bool      withdrawn               ;
	mapping(address => bool)   voted  ;
    }

    struct Donation {
	address donor   ;
	uint    amnt    ;
	uint    blkno   ;
    }

    bytes32 public softwarename ;

    uint public balance ;
    uint public nummembers ;

    uint8  public M ;
    uint8  public N ;

    mapping(address => uint)  public  members ;
    mapping(address => bool)  public  membersTryOut ;

    SoftwareVersionRecord[] versions ;
    SoftwareExecRecord[]  execrecords ;

    MemberInfo[]  membersinfo ;
    Proposal[]    proposals ;
    Donation[]    donations ;
    bytes32[]     citations ;
    address[]     usedbysoftware ;

    event LogSoftwareExecRecord(address submitter,bytes32 softwareversion,bytes32 url,uint256 inputhash,uint256 outputhash);
    event LogSoftwareVersionRecord(address submitter,bytes32 url,bytes32 version,uint256 sourcehash); 
    event LogPropose(uint propNo,bytes32 title,bytes32 ipfsHash,uint requestedFund,uint deadline); 
    event LogProposalVote(uint votecount,uint blocknum,address voter);
    event LogDonation(address donor,uint amount,uint blknum);
    event LogWithdrawProposalFund(uint propno,uint requestedfund,uint blocknum,address proposalOwner);
    event LogVoteMemberCandidate(uint memberno,address voter,uint votecount);	

    modifier enough_fund_balance(uint propno) {
	require(balance >= proposals[propno].requestedfund ) ;
	_ ;
    }

    modifier valid_proposal_no(uint propno) {
	require(propno < proposals.length ) ;
	_ ;
    }

    modifier valid_member_no(uint memberno) { 
	require( (memberno!=0) && (memberno <= membersinfo.length) ) ;
	_ ;
    }

    modifier member(address addr) {
	require( members[addr] != 0  ) ;
	_ ;
    }

    modifier not_member(address addr) {
	require( members[addr] == 0  ) ;
	_ ;
    }

    modifier valid_deadline(uint deadline) {
	require(deadline >= block.number ) ;
	_ ;
    }

    modifier within_deadline(uint propno) {
	require( proposals[propno].deadline > block.number ) ;
	_ ;
    }

    modifier not_voted_for_proposal(uint propno) {
	require(! proposals[propno].voted[msg.sender] ) ;
	_ ;
    }

    modifier not_voted_for_member(uint memberno) {
	require(! membersinfo[memberno-1].voted[msg.sender] ) ;
	_ ;
    }

    modifier voted_for_member(uint memberno) {
	require(membersinfo[memberno-1].voted[msg.sender] ) ;
	_ ;
    }

    modifier  proposal_owner(uint propno) {
	require(proposals[propno].proposer == msg.sender ) ;
	_ ;
    }


    modifier proposal_majority(uint propno) {
	require( (proposals[propno].votecount*N) >= (nummembers*M) ) ;
	_ ;
    }

    modifier membership_majority(uint memberno) {
	require( (membersinfo[memberno].votecount*N) >= (nummembers*M) ) ;
	_ ;
    }

    modifier nonzero_payment_made() {
	require(msg.value > 0) ;
	_ ;
    }

    function AutonomousSoftwareOrg(bytes32 name,uint8 m,uint8 n, bytes32 url) {

	if(m>n) 
	    throw;

	softwarename = name ;
	membersinfo.push(MemberInfo(url,msg.sender,0)) ;
	members[msg.sender] = membersinfo.length ;
	balance = 0 ;
	nummembers = 1 ;
	M = m ;
	N = n ;

    }
    
    function () {
	throw ;
    }

    function ProposeProposal(bytes32 title,bytes32 url,uint256 prophash,uint requestedfund, uint deadline) public
	member(msg.sender) valid_deadline(deadline){
	    
	proposals.push(Proposal(title,url,prophash,msg.sender,requestedfund,deadline,0,false)) ;
	LogPropose( proposals.length, title, url, requestedfund, deadline );

    }

    function VoteForProposal(uint propno) public
	valid_proposal_no(propno) within_deadline(propno) 
	member(msg.sender) not_voted_for_proposal(propno) {

	proposals[propno].voted[msg.sender] = true ;
	proposals[propno].votecount++ ;
	LogProposalVote(proposals[propno].votecount,block.number,msg.sender);

    }

    function WithdrawProposalFund(uint propno)  public
	valid_proposal_no(propno) within_deadline(propno)
	member(msg.sender) enough_fund_balance(propno) proposal_owner(propno)
	proposal_majority(propno) {
	    
	balance -=  proposals[propno].requestedfund  ;
	if (proposals[propno].withdrawn == true || ! msg.sender.send(proposals[propno].requestedfund)) {
	    throw ;
	}
	proposals[propno].withdrawn = true; 
	LogWithdrawProposalFund(propno,proposals[propno].requestedfund,block.number,msg.sender);

    }

    function BecomeMemberCandidate(bytes32 url) public
	not_member(msg.sender) { 

	if(membersTryOut[msg.sender] == true)
	    throw;

	membersinfo.push(MemberInfo(url,msg.sender,0)) ;
	membersTryOut[msg.sender] = true;	    	    

    } 


    function VoteMemberCandidate(uint memberno) public valid_member_no(memberno) 
	member(msg.sender) not_voted_for_member(memberno){

	membersinfo[memberno-1].voted[msg.sender] = true ;
	membersinfo[memberno-1].votecount++ ;

	if ( (membersinfo[memberno-1].votecount)*N >= (nummembers*M)) {
	    if (members[membersinfo[memberno-1].memberaddr] == 0) {
		members[membersinfo[memberno-1].memberaddr] = memberno ;
		nummembers++ ;
	    }
	}
	LogVoteMemberCandidate(memberno-1,msg.sender,membersinfo[memberno-1].votecount);

    }

    function DelVoteMemberCandidate(uint memberno) public
	valid_member_no(memberno) member(msg.sender) voted_for_member(memberno) {

	membersinfo[memberno-1].voted[msg.sender] = false ;
	membersinfo[memberno-1].votecount-- ;

	if ( (membersinfo[memberno-1].votecount * N) < (nummembers*M)) {
	    if (members[membersinfo[memberno-1].memberaddr] != 0) {
		delete(members[membersinfo[memberno-1].memberaddr]) ;
		nummembers-- ;
	    }
	}

    }

    function Donate() payable public
	nonzero_payment_made  {

	balance += msg.value ;
	donations.push(Donation(msg.sender,msg.value,block.number) ) ;
	LogDonation(msg.sender, msg.value, block.number);

    }

    function Cite(bytes32 doinumber) public  {

	citations.push(doinumber) ;
    }

    function UseBySoftware(address addr) public {

	usedbysoftware.push(addr) ; 
    }

    function addSoftwareExecRecord(bytes32 softwareversion,bytes32 url,uint256 inputhash,uint256 outputhash) 
    	member(msg.sender) {

	execrecords.push(SoftwareExecRecord(msg.sender,softwareversion,url,inputhash,outputhash));
	LogSoftwareExecRecord(msg.sender,softwareversion,url,inputhash,outputhash);
    }

    function addSoftwareVersionRecord(bytes32 url,bytes32 version,uint256 sourcehash) {

	versions.push(SoftwareVersionRecord(msg.sender,url,version,sourcehash));
	LogSoftwareVersionRecord(msg.sender,url,version,sourcehash);
    }

    function getSoftwareExecRecord(uint32 id) 
	constant returns(address,bytes32,bytes32,uint256,uint256) {

	return(execrecords[id].submitter,
	       execrecords[id].softwareversion,
	       execrecords[id].url,
	       execrecords[id].inputhash,
	       execrecords[id].outputhash);
    }

    function getSoftwareExecRecordLength() 
	constant returns (uint){

	return(execrecords.length) ;
    }

    function getSoftwareVersionRecords(uint32 id) 
	constant returns(address,bytes32,bytes32,uint256){

	return(versions[id].submitter,
	       versions[id].url,
	       versions[id].version,
	       versions[id].sourcehash);
    }

    function geSoftwareVersionRecordsLength() 
	constant returns (uint){
	    
	return(versions.length) ;
    }

    function getAutonomousSoftwareOrgInfo() 
	constant returns (bytes32,uint,uint,uint,uint){

	return (softwarename,
		balance,
		nummembers,
		M,
		N );
    }

    function getMemberInfoLength() 
	constant returns (uint){

	return(membersinfo.length) ;
    }

    function getMemberInfo(uint memberno)
	member(membersinfo[memberno-1].memberaddr)
	constant returns (bytes32,address,uint  ){

	return (membersinfo[memberno-1].url,
		membersinfo[memberno-1].memberaddr,
		membersinfo[memberno-1].votecount) ;
    }

    function getCandidateMemberInfo(uint memberno) 
	not_member(membersinfo[memberno-1].memberaddr)
	constant returns (bytes32,address,uint  ){ 
	    
	return (membersinfo[memberno-1].url,
		membersinfo[memberno-1].memberaddr, 
		membersinfo[memberno-1].votecount) ;
    }

    function getProposalsLength() 
	constant returns (uint){

	return(proposals.length) ;
    }

    function getProposal(uint propno)
	constant returns (bytes32,bytes32,uint256,uint,uint,bool,uint){

	return (proposals[propno].title,
		proposals[propno].url,
		proposals[propno].prophash,
		proposals[propno].requestedfund,
		proposals[propno].deadline,
		proposals[propno].withdrawn,  
		proposals[propno].votecount) ;
    }

    function getDonationLength()
	constant returns (uint){

	return (donations.length) ;
    }

    function getDonationInfo(uint donationno)
	constant returns (address,uint,uint){

	return (donations[donationno].donor,
		donations[donationno].amnt,
		donations[donationno].blkno) ;
    }

    function getCitationLength()
	constant returns (uint){

	return (citations.length) ;
    }

    function getCitation(uint citeno)
	constant returns (bytes32){

	return (citations[citeno]) ;
    }

    function getUsedBySoftwareLength() 
	constant returns (uint){

	return (usedbysoftware.length) ;
    }

    function getUsedBySoftware(uint usedbysoftwareno) 
	constant returns (address){

	return (usedbysoftware[usedbysoftwareno]) ;
    }

}
