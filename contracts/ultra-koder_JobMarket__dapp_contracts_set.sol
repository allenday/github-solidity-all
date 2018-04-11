import "std.sol";

contract SetUtil is abstract {
    
    // This is very cool collection function set 
    // one more edit

    struct Set_ui32 {
        uint32[] arr;
    }
    
    struct Set_addr {
        address[] arr;
    }
    
    function setAdd(Set_ui32 storage self, uint32 elem) internal {
        for (uint i = 0; i < self.arr.length; i++) {
            if (self.arr[i] == 0) {
                self.arr[i] = elem;
                return;
            }
        }
        self.arr.length += 1;
        self.arr[self.arr.length - 1] = elem;
    }
    
    function setAddUnique(Set_ui32 storage self, uint32 elem) internal {
        if (!setHas(self, elem)) {
            setAdd(self, elem);
        }
    }
    
    function setRemove(Set_ui32 storage self, uint32 val) internal {
        for(uint32 i = 0; i < self.arr.length; i++) {
            if (self.arr[i] == val) {
                self.arr[i] = 0;
                break;
            }
        }
        while(self.arr.length > 0 && self.arr[self.arr.length - 1] == 0) {
            self.arr.length -= 1;
        }
        setCompact(self);
    }
    
    function setHas(Set_ui32 storage self, uint32 val) internal returns (bool) {
        for(uint32 i = 0; i < self.arr.length; i++) {
            if (self.arr[i] == val) {
                return true;
            }
        }
        return false;
    }
    
    function setIsEmpty(Set_ui32 storage self) internal returns (bool) {
        return self.arr.length == 0;
    }
    
    function setCompact(Set_ui32 storage self) internal returns (uint size) {
        if (self.arr.length == 0) return 0;
        uint start = 0;
        uint end = self.arr.length - 1;
        
        while(true) {
            while (end > 0 && self.arr[end] == 0) end--;
            while (start < self.arr.length && self.arr[start] != 0) start++;
            if (start < end) {
                self.arr[start] = self.arr[end];
                self.arr[end] = 0;
            } else {
                break;
            }
        }
        self.arr.length = end + 1;
        return self.arr.length;
    }
    
    function setAdd(Set_addr storage self, address elem) internal {
        for (uint i = 0; i < self.arr.length; i++) {
            if (self.arr[i] == 0) {
                self.arr[i] = elem;
                return;
            }
        }
        self.arr.length += 1;
        self.arr[self.arr.length - 1] = elem;
    }
    
    function setAddUnique(Set_addr storage self, address elem) internal {
        if (!setHas(self, elem)) {
            setAdd(self, elem);
        }
    }
    
    function setRemove(Set_addr storage self, address val) internal {
        for(uint32 i = 0; i < self.arr.length; i++) {
            if (self.arr[i] == val) {
                self.arr[i] = 0;
                break;
            }
        }
        while(self.arr.length > 0 && self.arr[self.arr.length - 1] == 0) {
            self.arr.length -= 1;
        }
        setCompact(self);
    }
    
    function setHas(Set_addr storage self, address val) internal returns (bool) {
        for(uint32 i = 0; i < self.arr.length; i++) {
            if (self.arr[i] == val) {
                return true;
            }
        }
        return false;
    }
    
    function setIsEmpty(Set_addr storage self) internal returns (bool) {
        return self.arr.length == 0;
    }

    function setCompact(Set_addr storage self) internal returns (uint size) {
        if (self.arr.length == 0) return 0;
        uint start = 0;
        uint end = self.arr.length - 1;
        
        while(true) {
            while (end > 0 && self.arr[end] == 0) end--;
            while (start < self.arr.length && self.arr[start] != 0) start++;
            if (start < end) {
                self.arr[start] = self.arr[end];
                self.arr[end] = 0;
            } else {
                break;
            }
        }
        self.arr.length = end + 1;
        return self.arr.length;
    }
}