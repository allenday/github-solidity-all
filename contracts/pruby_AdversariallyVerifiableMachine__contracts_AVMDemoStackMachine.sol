import 'AVMStepValidator.sol';
import 'AVMMemoryContext32.sol';

contract AVMDemoStackMachine is AVMStepValidator {
    event trace(string);
    event traceNum(uint);
    event MissingRead(uint);
    event BadWriteAddress(uint, uint);
    event BadWriteValue(uint, uint, uint);
    using AVMMemoryContext32 for AVMMemoryContext32.Context;
    
    uint constant addrStatusRegister = 0;
    uint constant mask32 = 4294967295;
    uint constant offsetInstructionPointer = 26959946667150639794667015087019630673637144422540572481103610249216;
    uint constant offsetStackPointer = 6277101735386680763835789423207666416102355444464034512896;
    uint constant memorySize = 262144;
    
    function validateStep(uint256[] readAccesses, uint256[] writeAccesses) external returns (bool) {
        AVMMemoryContext32.Context memory ctx = AVMMemoryContext32.initContext(0, memorySize, readAccesses, writeAccesses);
        uint256 statusRegister = ctx.read256(addrStatusRegister);
        uint ip = (statusRegister / offsetInstructionPointer) & mask32;
        uint sp = (statusRegister / offsetStackPointer) & mask32;
        uint8 op = ctx.readByte(ip++);
        
        uint v; uint w;
        if (op == 0x0) {
            // NOP
        } else if (op == 0x1) { // PUSH
            // Read word from opcodes, big endian
            v = ctx.readByte(ip++);
            v = (v * 256) + ctx.readByte(ip++);
            v = (v * 256) + ctx.readByte(ip++);
            v = (v * 256) + ctx.readByte(ip++);
            trace("Value read from opcodes: ");
            traceNum(v);
            sp -= 4;
            ctx.write32(sp, v);
        } else if (op == 0x2) { // POP
            sp += 4;
        } else if (op == 0x3) { // LOAD
            v = ctx.read32(sp);
            v = ctx.read32(v);
            ctx.write32(sp, v);
        } else if (op == 0x4) { // STORE
            v = ctx.read32(sp);
            w = ctx.read32(sp + 4);
            sp += 8;
            ctx.write32(v, w);
        } else if (op == 0x5) { // ADD
            v = ctx.read32(sp);
            w = ctx.read32(sp + 4);
            sp += 4;
            ctx.write32(sp, v + w);
        } else if (op == 0x6) { // SUB
            v = ctx.read32(sp);
            w = ctx.read32(sp + 4);
            sp += 4;
            ctx.write32(sp, v - w);
        } else if (op == 0x7) { // AND
            v = ctx.read32(sp);
            w = ctx.read32(sp + 4);
            sp += 4;
            ctx.write32(sp, v & w);
        } else if (op == 0x8) { // OR
            v = ctx.read32(sp);
            w = ctx.read32(sp + 4);
            sp += 4;
            ctx.write32(sp, v | w);
        } else if (op == 0x9) { // NOT
            v = ctx.read32(sp);
            ctx.write32(sp, ~v);
        } else if (op == 0xa) { // JZ
            v = ctx.read32(sp);
            w = ctx.read32(sp + 4);
            sp += 8;
            if (v == 0) {
                ip = (uint32) (w);
            }
        } else {
            // Unknown operation
            // Do not write anything, freeze here.
            return ctx.isValid();
        }
        
        statusRegister = (ip * offsetInstructionPointer) | (sp * offsetStackPointer);
        
        ctx.write256(addrStatusRegister, statusRegister);
        return ctx.isValid();
    }
    
    function getMemoryWordsLog2() returns (uint) {
        return 13; // 16 bit addressing for 32 bit words
    }
    
    function getMaximumReadsPerStep() returns (uint) {
        return 4;
    }
    
    function getMaximumWritesPerStep() returns (uint) {
        return 3;
    }
}


