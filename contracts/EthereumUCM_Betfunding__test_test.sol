contract Betfunding {
    uint256 numProjects;
	uint256 numNiceBets;
	uint256 numBadBets;
	
    function Betfunding() {
        numProjects = 0;
		numNiceBets = 0;
		numBadBets = 0;
    }
    
    function createProject(string32 projectName, string32 projectDesciption, uint256 expirationDate, string32 verificationMethod, address judge){
						   
        numProjects += 1;
    }
	
	function createProject2(){
						   
        numProjects += 1;
    }
        
    function bid(uint256 projectID ,bool isNiceBet){
        if(isNiceBet){
            numNiceBets += 1;
        }
        else{
            numBadBets += 1;
        }
    }
        
    function getNiceBets(uint256 projectID) returns (uint256 amount){
        
        return projectID*10;
    }
    
    function getBadBets(uint256 projectID) returns (uint256 amount){
        
		return projectID*20;
    }
	
	function getNumProjects() constant returns (uint256 r){
        
		return numProjects;
    }
	
	function getProjectName(uint256 projectID) returns (string32 name){
        string32 test = "Nombre de ejemplo";
		
		return test;
    }
	
	function getProjectEndDate(uint256 projectID) returns (uint256 date){
        
		return 1430081578694;
    }
	
	function getNumNiceBets(uint256 projectID) returns (uint256 num){
        
		return numNiceBets;
    }
	
	function getNumBadBets(uint256 projectID) returns (uint256 num){
        
		return numBadBets;
    }
	
	function getProjectVerification(uint256 projectID) returns (string32 verificacion){
        string32 test = "Verificacion de ejemplo";
		
		return test;
    }
	
	function getProjectJudge(uint256 projectID) returns (address add){
        address test = 0x41190e39a7d33c33407361e30b34db50112301f8;
		
		return test;
    }
	
	function getProjectDescription(uint256 projectID) returns (string32 description){
        string32 test = "Descripcion de ejemplo";
		
		return test;
    }
	
	function getProjectCreator(uint256 projectID) returns (address add){
        address test = 0x41190e39a7d33c33407361e30b34db50112301f8;
		
		return test;
    }
}