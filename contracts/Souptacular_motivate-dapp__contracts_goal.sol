import "libraries/tasks.sol";
contract Goal{
    address public user;
    bytes public ipfs; //ipfs hash
    Tasks.taskList public current_tasks; //Sorted in order of due date
    //TODO: Implement repeated tasks efficiently. Idea: Implement repeated tsks as single tasks that re-add themselves (low storage, but high computation cost if not updated regularly)
    uint funding;
    bool public funded;
    //Token token; 
    
    function Goal(){ //Constructor
        
    }
    
    function addTask(bytes ipfs, uint start, uint end, address validator, uint penalty, uint reward, uint freq) public returns (uint ID){
       if(msg.sender != user) throw;
        ID = uint(sha3(msg.sender,validator,start));
        Tasks.Task task;
        task.user = user;
        task.taskID = ID;
        task.ipfsData = ipfs;
        task.startTime = start;
        task.duration = end-start;
        task.validator = validator;
        task.penalty= penalty;
        task.reward = reward;
        task.frequency = freq;
        Tasks.add(current_tasks,task);
    }
    
    
    //function completeTask(uint index) public {
    //    Tasks.complete(current_tasks.tasks[index]);
       // remove(index);
    //}
    

    
    
   // function checkFunding() returns (bool){ //Goal only begins once contract is funded
   //     return token.balanceOf(this) >= funding;
  //  }
    
    //Task getter functions
    
    function getIpfs(uint ID) public returns(bytes){
        return current_tasks.tasks[Tasks.find(current_tasks,ID)].ipfsData;
    }
    
    function getStart(uint ID) public returns (uint){
        return current_tasks.tasks[Tasks.find(current_tasks,ID)].startTime;
    }
    
     function getEnd(uint ID) public returns (uint) {
        return current_tasks.tasks[Tasks.find(current_tasks,ID)].startTime + current_tasks.tasks[Tasks.find(current_tasks,ID)].duration;
    }
    
    function getReward(uint ID) public returns (uint,uint){ //Returns [reward,penalty]
        return (current_tasks.tasks[Tasks.find(current_tasks,ID)].reward, current_tasks.tasks[Tasks.find(current_tasks,ID)].penalty);
    }
    
    function getFrequency(uint ID) public returns (uint) {
        return current_tasks.tasks[Tasks.find(current_tasks,ID)].frequency;
    }
}