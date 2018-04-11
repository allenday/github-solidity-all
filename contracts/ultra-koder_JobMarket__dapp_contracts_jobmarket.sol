import "std.sol";
import "set.sol";

contract JobMarket is owned, named("JobMarket"), SetUtil {

    uint32 public totalJobs;
    mapping (uint => Job) jobs;
    Set_ui32 jobList;
    
	event NewJob(uint id, bytes32 name, bytes32 description);
	event NewEmployer(bytes32 name, address addr);
	event NewSkill(bytes32 name);
        
    enum JobStatus {
        New, 
        InProgress, 
        Completed,
        Done
    }

    Set_addr employerList;
    Set_addr workerList;
    mapping (address => Employer) employers;
    mapping (address => Worker) workers;

    Set_addr skillList;
    mapping (uint => Skill) skills;
    
    struct Employer {
        bytes32 name;
        address account;
        uint rank;
        uint jobsCompleted;
        Set_ui32  jobIds;
    }
    
    struct Worker {
        bytes32 name;
        address account;
        uint rank;
        uint jobsCompleted;
        Set_ui32  jobIds;
        Set_ui32  skillIds;
    }
    
    struct Job {
        Employer owner;
        bytes32 name;
        bytes32 description;
        Set_ui32  requiredSkills;
        JobStatus status;
        uint value;
        Worker worker;
    }
    
    struct Skill {
        bytes32 name;
        uint rank;
    }
    
    function JobMarket() {
        totalJobs= 0;
    }
    
    function newEmployer(bytes32 _name) public returns(uint employerId)  {
        Employer newEmployer= employers[msg.sender];
        newEmployer.name = _name;
        newEmployer.account= msg.sender;
        setAddUnique(employerList, msg.sender);
        
        NewEmployer(newEmployer.name, newEmployer.account);
        return(employerList.arr.length);
    }

    function newJob(bytes32 _name, bytes32 _description) public returns( uint32 jobId)  {
        Job newJob= jobs[totalJobs];
        newJob.owner= employers[msg.sender];
        newJob.name= _name;
        newJob.description= _description;
        newJob.status= JobStatus.New;
        newJob.value= msg.value;
        setAddUnique(employerList, msg.sender);
        
        totalJobs++;
        setAddUnique(jobList, totalJobs);
        
        NewJob(totalJobs, _name, _description);
        return(totalJobs);
    }

    function getJobs() constant returns( uint32 [] jList)  {
        return(jobList.arr);
    }

    function getJobName(uint id) constant returns(bytes32 jn)  {
        return(jobs[id - 1].name);
    }
    
    function getJobDescription(uint id) constant returns(bytes32 jd)  {
        return(jobs[id - 1].description);
    }
    
    function getJobStatus(uint id) constant returns(uint status)  {
        return(uint256(jobs[id - 1].status));
    }
    
    function getJobValue(uint id) constant returns(uint value)  {
        return(jobs[id - 1].value);
    }
    
    function getJobEmployerName(uint id) constant returns(bytes32 jn)  {
        return(jobs[id - 1].owner.name);
    }

    function getJobWorkerName(uint id) constant returns(bytes32 jn)  {
        return(jobs[id - 1].worker.name);
    }

    function getJobTotalSkills(uint id) constant returns(uint32 totalSkills)  {
        setCompact(jobs[id - 1].requiredSkills);
        return(uint32(jobs[id - 1].requiredSkills.arr.length));
    }
    
    function getSkillName(uint id) constant returns(bytes32 skillName)  {
        return(skills[id].name);
    }
    
    function getJobSkills(uint id) constant returns(uint32 [] list)  {
        setCompact(jobs[id - 1].requiredSkills);
        return(jobs[id - 1].requiredSkills.arr);
    }
 
    function addJobSkill(uint32 jobID, bytes32 name) {
        log1("addJobSkill: ", name);        
        Job job= jobs[jobID - 1];
        uint32 skillIndex= addSkill(name);
        setAddUnique(job.requiredSkills, skillIndex); 
    }
   
    function addSkill(bytes32 name) returns (uint32 index){
        var found= false;
    
        for (uint32 i = 0; i  < uint32(skillList.arr.length); i++) {
            Skill storage s = skills[i];
            if (s.name == name) {
                index= i;
                found = true;
                break;
            }
        }
    
        if(!found)  {
        log1("addSkill: ", name);        
            index= uint32(skillList.arr.length);
            Skill newSkill= skills[index];
            newSkill.name= name;
            setAddUnique(skillList, index);
            NewSkill(name);
        }
        return(index);
    }
}