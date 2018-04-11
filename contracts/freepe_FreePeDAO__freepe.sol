pragma solidity ^0.4.0;

contract Task {
    struct TaskItem {
        uint id;
        string description;
        string category;
        uint8 state;
        uint creationTime;
        uint256 budget;
        uint due;///in hours
        address sender;
        uint parentId;
        bool isExist;
        uint expertiseWorkId;
    }
            
    uint currentId;
    address work;
    
    mapping(uint=>TaskItem) public tasks;
    uint[] public taskIds;
    
    function Task(address _work)  public {
        work = _work;
        currentId = 0;
    } 
    
    function isExist(uint id) returns(bool){
        return tasks[id].isExist;
    }
    
    function getExpertiseId(uint id) returns(uint) {
        require(tasks[id].isExist);
        
        return tasks[id].expertiseWorkId;
    }
    
    function newTask(string desc, string cat, uint256 budget, uint due)  public returns(uint){
        currentId += 1;
        
        TaskItem memory newItem;
        newItem.sender = msg.sender;
        newItem.description = desc;
        newItem.category = cat;
        newItem.budget = budget;
        newItem.due = due;
        newItem.creationTime = now;
        newItem.state = 0;
        newItem.isExist = true;

        newItem.id = currentId;
        tasks[currentId] = newItem;
        
        taskIds.push(currentId);
        
        return newItem.id;
    }
    
    function count() constant returns(uint) {
        return taskIds.length;
    }
    
    function newExpertise(uint workId, uint parentTaskId) {
        require(tasks[parentTaskId].isExist);
        
        TaskItem parentTask = tasks[parentTaskId];
        uint taskId = newTask(parentTask.description, "expertise",0,0);
        tasks[taskId].parentId = parentTaskId;
        tasks[taskId].expertiseWorkId = workId;
    }
}

contract Work {
    struct WorkItem {
        uint id;
        uint256 budget;
        uint taskId;
        uint creationTime;
        address owner;
        uint due;///in hours
        uint parentId;
        bool isExist;
    }
    
    uint currentId;
    Task public task;
    mapping(uint=>WorkItem) public works;
    mapping(address=>uint[]) public addressWorks;
    
    function Work() public {
        task = new Task(this);
        currentId = 0;
    } 
    
    function newWork(uint taskId, uint256 budget, uint due, address sender)  public {
        require(task.isExist(taskId));
        
        currentId += 1;
        
        WorkItem memory newItem;
        newItem.id = currentId;
        newItem.budget = budget;
        newItem.taskId = taskId;
        newItem.creationTime = now;
        newItem.due = due;
     newItem.isExist = true;
        newItem.owner = msg.sender;
        
        newItem.parentId = task.getExpertiseId(taskId);
        works[currentId] = newItem;
        addressWorks[msg.sender].push(currentId);
    }
    
    function getTaskId(uint id) returns (uint) {
        require(works[id].isExist);
        
        return works[id].taskId;
    }
    
    function getWorkCount() constant returns(uint) {
        return addressWorks[msg.sender].length;
    }
    
    function deleteWork(uint id)  public {
        require(works[id].isExist);
        require (works[id].owner == msg.sender);
        
        delete works[id];
        uint[]  userWorks = addressWorks[msg.sender];
        
        uint i = 0;
        for (; i<userWorks.length && userWorks[i]!=id;i++) {}
        if (i >= userWorks.length) return;

        for (; i<userWorks.length-1; i++){
            userWorks[i] = userWorks[i+1];
        }
        delete userWorks[userWorks.length-1];
        userWorks.length--;
    }
    
    function commitWork (uint id)  public {
        require(works[id].isExist);
        
        uint expertiseId = task.getExpertiseId(works[id].taskId);
        
        if (expertiseId == 0) {
            task.newExpertise(id, works[id].taskId);
            return;
        }
        pushWork(id);
    }
    
    function pushWork (uint id)  public {
        
    }
}