library AVMMemoryContext32 {
    struct Context {
        uint256[] readAccesses;
        uint256[] writeAccesses;
        uint writeIdx;
        uint cachedRead;
        uint cachedReadValue;
        uint windowOffset;
        uint windowLength;
        bool valid;
        bool fault;
    }
    
    event trace(string);
    event traceNum(uint);
    event MissingRead(uint);
    event BadWriteAddress(uint, uint);
    event BadWriteValue(uint, uint, uint);
    function initContext(uint offset, uint window, uint256[] memory readAccesses, uint256[] memory writeAccesses) internal returns (Context memory) {
        Context memory ctx;
        ctx.readAccesses = readAccesses;
        ctx.writeAccesses = writeAccesses;
        ctx.writeIdx = 0;
        ctx.windowOffset = offset;
        ctx.windowLength = window;
        ctx.cachedRead = (uint) (-1);
        ctx.cachedReadValue = 0;
        ctx.valid = true;
        ctx.fault = false;
        return ctx;
    }
    
    function read256(Context ctx, uint addr) internal returns (uint) {
        if (!ctx.valid) return 0;
        
        uint v;
        if (addr / 32 >= ctx.windowLength / 32) {
            ctx.fault = true;
            return 0;
        } else {
            addr = addr + ctx.windowOffset;
        }
        
        for (uint i = 0; i < ctx.readAccesses.length; i += 2) {
            if (ctx.readAccesses[i] == (addr / 32)) {
                return ctx.readAccesses[i+1];
            }
        }
        
        ctx.valid = false;
        MissingRead(addr / 32);
        return 0;
    }
    
    function read32(Context ctx, uint addr) internal returns (uint32) {
        uint v = read256(ctx, addr);
        
        // Shift down to chosen word
        for (uint j = ((addr / 4) % 8); j < 7; j++) {
            v = v / 4294967296;
        }
        
        return (uint32) (v);
    }
    
    function readByte(Context ctx, uint addr) internal returns (uint8) {
        uint32 v = read32(ctx, addr);
        
        for (uint j = (addr % 4); j < 3; j++) {
            v = v / 256;
        }
        
        return (uint8) (v);
    }
    
    function write256(Context ctx, uint addr, uint value) internal {
        if (!ctx.valid) return;
        if (addr / 32 >= ctx.windowLength / 32) {
            ctx.fault = true;
            return;
        } else {
            addr = addr + ctx.windowOffset;
        }
        
        trace("Write");
        if (ctx.writeAccesses.length < (ctx.writeIdx + 2)) {
            // Insufficient writes
            trace("Insufficient Writes");
            ctx.valid = false;
            return;
        }
        
        trace("Reading write address");
        if (ctx.writeAccesses[ctx.writeIdx++] != (addr / 32)) {
            // Wrong write address
            BadWriteAddress(addr / 32, ctx.writeAccesses[ctx.writeIdx-1]);
            ctx.valid = false;
            return;
        }
        
        // Whole overwrite - ignore prior value
        ctx.writeIdx++;
        
        trace("Reading write value");
        if (ctx.writeAccesses[ctx.writeIdx++] != value) {
            // Wrong write value
            BadWriteValue(addr / 32, value, ctx.writeAccesses[ctx.writeIdx - 1]);
            ctx.valid = false;
            return;
        }
        
        trace("Updating read values for write");
        for (uint i = 0; i < ctx.readAccesses.length; i += 2) {
            if (ctx.readAccesses[i] == addr / 32) {
                ctx.readAccesses[i+1] = value;
            }
        }
    }
    
    function write32(Context ctx, uint addr, uint value) internal {
        if (!ctx.valid) return;
        if (addr / 32 >= ctx.windowLength / 32) {
            ctx.fault = true;
            return;
        } else {
            addr = addr + ctx.windowOffset;
        }
        
        trace("Write");
        if (ctx.writeAccesses.length < (ctx.writeIdx + 2)) {
            // Insufficient writes
            trace("Insufficient Writes");
            ctx.valid = false;
            return;
        }
        
        trace("Reading write address");
        if (ctx.writeAccesses[ctx.writeIdx++] != (addr / 32)) {
            // Wrong write address
            BadWriteAddress(addr / 32, ctx.writeAccesses[ctx.writeIdx-1]);
            ctx.valid = false;
            return;
        }
        
        trace("Reading write prior value");
        uint result = ctx.writeAccesses[ctx.writeIdx++];
        uint mask = 4294967295;
        value = value & mask;
        
        // Shift up to chosen word
        for (uint j = ((addr / 4) % 8); j < 7; j++) {
            mask = mask * 4294967296;
            value = value * 4294967296;
        }
        
        result = (result & (~mask)) | value;
        
        trace("Reading write value");
        if (ctx.writeAccesses[ctx.writeIdx++] != result) {
            // Wrong write value
            BadWriteValue(addr / 32, result, ctx.writeAccesses[ctx.writeIdx - 1]);
            ctx.valid = false;
            return;
        }
        
        trace("Updating future read values from write");
        for (uint i = 0; i < ctx.readAccesses.length; i += 2) {
            if (ctx.readAccesses[i] == addr / 32) {
                ctx.readAccesses[i+1] = value;
            }
        }
    }
    
    function isValid(Context memory ctx) internal returns (bool) {
        if (ctx.writeAccesses.length != ctx.writeIdx) {
            // Excess reads
            ctx.valid = false;
        }
        return ctx.valid;
    }
}

