contract Validator{ //Abstract contract defining validator ABI
    function validate(uint taskID, bytes data) returns (bool val);
}
library Tasks {
    
    
    struct taskList {
        uint80 first;
        uint80 last;
        uint80 count;
        Task[] tasks;
    }
    uint80 constant None = uint80(0);
    struct Task { //TODO: Define tasks
        address user;
        uint taskID;
        bytes ipfsData; //note: ipfs uses arbitrary-length addresses
        uint startTime;
        uint duration;
        address validator;
        uint penalty; //penalty for not completing, denominated in whatever token the Goal uses
        uint reward;
        uint frequency; // 0 if single task, repeat period if > 0
        uint80 prev;  //linked list structure 
        uint80 next;
    }
    
    //Checks that task is within valid time range and calls validator contract
    function validate(Task storage self, bytes validationData) returns (bool){
        if(block.timestamp > self.startTime && block.timestamp < self.startTime + self.duration){
            return  Validator(self.validator).validate(self.taskID, validationData);
        }
        return false;
    }
    
    function complete(taskList storage self, uint ID, bytes validationData) returns (uint reward){ //validate, re-add, and return reward amount
        uint penalty = clean(self);
        uint80 index = find(self,ID);
        if(validate(self.tasks[index], validationData)){
            reward += self.tasks[index].reward;
            remove(self, index);
        } 
                //TODO: Implement self-adding tasks
        
    }

    
    function append(taskList storage self, Task storage newTask) {
        var index = uint80(self.tasks.push(newTask));
        if (self.last == None)
        {
            if (self.first != None || self.count != 0) throw;
            self.first = self.last = index;
            self.count = 1;
        }
        else
        {
            self.tasks[self.last - 1].next = index;
            self.last = index;
            self.count ++;
        }
    }
    
    function add(taskList storage self, Task storage newTask){
        uint80 index; 
        for(uint80 j; j < self.tasks.length; j++){ //Insert task into array
            if(self.tasks[j].taskID == 0){
                self.tasks[j] = newTask;
                index = j;
            }
            else if(i==self.tasks.length-1){
                self.tasks.push(newTask);
            }
        }
        uint80 i = self.last;
        while(self.tasks[i].startTime+self.tasks[i].duration > newTask.startTime + newTask.duration){
            i=self.tasks[i].prev;
        }
        self.tasks[self.tasks[i].next].prev = index;
        self.tasks[i].next = index;
        self.count++;
        
    }
    
    /// Removes the element identified by the iterator
    /// `_index` from the list `self`.
    function remove(taskList storage self, uint80 _index) {
        Task item = self.tasks[_index - 1];
        if (item.prev == None)
            self.first = item.next;
        if (item.next == None)
            self.last = item.prev;
        if (item.prev != None)
            self.tasks[item.prev - 1].next = item.next;
        if (item.next != None)
            self.tasks[item.next - 1].prev = item.prev;
        delete self.tasks[_index - 1];
        self.count--;
    }
    /// @return an iterator pointing to the first element whose ID
    /// is `ID` or an invalid iterator otherwise.
    function find(taskList storage self, uint ID) returns (uint80) {
        var it = iterate_start(self);
        while (iterate_valid(self, it)) {
            if (iterate_getID(self, it) == ID)
                return it;
            it = iterate_next(self, it);
        }
        return it;
    }
    
    function clean(taskList storage self) returns (uint){ //cleans list and tallies penalties
        uint penalty;
        uint80 i = self.first;
        while (self.tasks[i].startTime+self.tasks[i].duration< block.timestamp){
            penalty+=self.tasks[i].penalty;
            remove(self, i);
        }
        return penalty;
    }
    
    function iterate_start(taskList storage self) returns (uint80) { return self.first; }
    function iterate_valid(taskList storage self, uint80 _index) returns (bool) { return _index - 1 < self.tasks.length; }
    function iterate_prev(taskList storage self, uint80 _index) returns (uint80) { return self.tasks[_index - 1].prev; }
    function iterate_next(taskList storage self, uint80 _index) returns (uint80) { return self.tasks[_index - 1].next; }
    function iterate_getID(taskList storage self, uint80 _index) returns (uint) { return self.tasks[_index - 1].taskID; }
    
    
}