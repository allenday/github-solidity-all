import 'AVMDisputeProcess.sol';

contract CountdownStepFunction is AVMStepValidator {
    event StepCall(uint256[] readAccesses, uint256[] writeAccesses);
    event cdtrace(string);
    function validateStep(uint256[] readAccesses, uint256[] writeAccesses) external returns (bool) {
        StepCall(readAccesses, writeAccesses);
        if (readAccesses.length == 2 && readAccesses[0] == 1) {
            // Read OK
            cdtrace("read ok");
            if (writeAccesses.length == 2 && writeAccesses[0] == 1) {
                // Write address ok
                cdtrace("write address ok");
                if (readAccesses[1] > 0 && writeAccesses[2] == readAccesses[1] - 1) {
                    // Correctly applied
                    cdtrace("write value ok");
                    return true;
                }
            } else if (readAccesses[1] == 0 && writeAccesses.length == 0) {
                // No write if we hit zero
                cdtrace("no write because zero");
                return true;
            }
        }
        cdtrace("did not match sequence");
        return false;
    }
    
    function getMemoryWordsLog2() returns (uint) {
        return (20);
    }
    
    function getMaximumReadsPerStep() returns (uint) {
        return 2;
    }
    function getMaximumWritesPerStep() returns (uint) {
        return 1;
    }
}

contract AVMTestSuite {
    AVMDisputeProcess public process;
    bytes32[20] zeroStore;
    
    // Duplicate event signatures to enable debugging in browser solidity
    // (it fails to determine which contract created an event)
    event trace(string);
    event DisputeProgress(uint disputeId, AVMDisputeProcess.DisputeState state);
    event StepCall(uint256[] readAccesses, uint256[] writeAccesses);
    event cdtrace(string);
    
    function AVMTestSuite() {
        process = new AVMDisputeProcess();
        
        zeroStore[0] = sha3((uint) (0));
        zeroStore[1] = sha3(zeroStore[0], zeroStore[0]);
        zeroStore[2] = sha3(zeroStore[1], zeroStore[1]);
        zeroStore[3] = sha3(zeroStore[2], zeroStore[2]);
        zeroStore[4] = sha3(zeroStore[3], zeroStore[3]);
        zeroStore[5] = sha3(zeroStore[4], zeroStore[4]);
        zeroStore[6] = sha3(zeroStore[5], zeroStore[5]);
        zeroStore[7] = sha3(zeroStore[6], zeroStore[6]);
        zeroStore[8] = sha3(zeroStore[7], zeroStore[7]);
        zeroStore[9] = sha3(zeroStore[8], zeroStore[8]);
        zeroStore[10] = sha3(zeroStore[9], zeroStore[9]);
        zeroStore[11] = sha3(zeroStore[10], zeroStore[10]);
        zeroStore[12] = sha3(zeroStore[11], zeroStore[11]);
        zeroStore[13] = sha3(zeroStore[12], zeroStore[12]);
        zeroStore[14] = sha3(zeroStore[13], zeroStore[13]);
        zeroStore[15] = sha3(zeroStore[14], zeroStore[14]);
        zeroStore[16] = sha3(zeroStore[15], zeroStore[15]);
        zeroStore[17] = sha3(zeroStore[16], zeroStore[16]);
        zeroStore[18] = sha3(zeroStore[17], zeroStore[17]);
        zeroStore[19] = sha3(zeroStore[18], zeroStore[18]);
    }
    
    function calculateMemoryState(uint step) internal returns (bytes32) {
        return sha3(sha3(sha3(sha3(sha3(sha3(sha3(sha3(sha3(
            sha3(sha3(sha3(sha3(sha3(sha3(sha3(sha3(sha3(sha3(
            sha3(
                sha3((bytes32) (0xdeadbeef)),
                sha3((uint) (1000000 - step))
            )
            , zeroStore[1])
            , zeroStore[2])
            , zeroStore[3])
            , zeroStore[4])
            , zeroStore[5])
            , zeroStore[6])
            , zeroStore[7])
            , zeroStore[8])
            , zeroStore[9])
            , zeroStore[10])
            , zeroStore[11])
            , zeroStore[12])
            , zeroStore[13])
            , zeroStore[14])
            , zeroStore[15])
            , zeroStore[16])
            , zeroStore[17])
            , zeroStore[18])
            , zeroStore[19]
        );
    }
    
    function prepareDisputeValid() returns (uint) {
        uint id = process.openDispute(
            new CountdownStepFunction(),
            this,
            this,
            calculateMemoryState(0),
            calculateMemoryState(1000000),
            1000000,
            300,
            15
        );
        
        bytes32[] memory states = new bytes32[](15);
        uint step = 62500;
        uint number = 62500;
        for (uint i = 0; i < 15; i++) {
            states[i] = calculateMemoryState(number);
            number += step;
        }
        
        process.doProvideStateRoots(id, process.getNextAntiReplayTag(id), states);

        process.doSelectDisputedStateRoot(id, process.getNextAntiReplayTag(id), 5);

        number = 316406;
        step = 320312 - number;
        for (i = 0; i < 15; i++) {
            states[i] = calculateMemoryState(number);
            number += step;
        }
        
        process.doProvideStateRoots(id, process.getNextAntiReplayTag(id), states);

        process.doSelectDisputedStateRoot(id, process.getNextAntiReplayTag(id), 15);

        number = 371334;
        step = 371578 - number;
        for (i = 0; i < 15; i++) {
            states[i] = calculateMemoryState(number);
            number += step;
        }
        
        process.doProvideStateRoots(id, process.getNextAntiReplayTag(id), states);

        process.doSelectDisputedStateRoot(id, process.getNextAntiReplayTag(id), 0);

        number = 371105;
        step = 371120 - number;
        for (i = 0; i < 15; i++) {
            states[i] = calculateMemoryState(number);
            number += step;
        }
        
        process.doProvideStateRoots(id, process.getNextAntiReplayTag(id), states);

        process.doSelectDisputedStateRoot(id, process.getNextAntiReplayTag(id), 0);

        number = 371091;
        step = 1;
        states = new bytes32[](14);
        for (i = 0; i < 14; i++) {
            states[i] = calculateMemoryState(number);
            number += step;
        }
        
        process.doProvideStateRoots(id, process.getNextAntiReplayTag(id), states);

        process.doSelectDisputedStateRoot(id, process.getNextAntiReplayTag(id), 6);

        return id;
    }
    
    function testDisputedWriteValid() returns (bool) {
        uint id = prepareDisputeValid();
        
        uint[] memory reads = new uint[](2);
        uint[] memory writes = new uint[](4);
        
        reads[0] = 1;
        reads[1] = 1000000 - 371096;
        
        writes[0] = 1;
        writes[1] = 1000000 - 371096;
        writes[2] = 1000000 - 371097;
        writes[3] = (uint) (calculateMemoryState(371097));
        
        process.doProvideMemoryAccesses(id, process.getNextAntiReplayTag(id), reads, writes);

        process.doDisputeMemoryWrite(id, process.getNextAntiReplayTag(id), 0);
        
        bytes32[] memory proof = new bytes32[](20);
        proof[0] = sha3((bytes32) (0xdeadbeef));
        proof[1] = zeroStore[1];
        proof[2] = zeroStore[2];
        proof[3] = zeroStore[3];
        proof[4] = zeroStore[4];
        proof[5] = zeroStore[5];
        proof[6] = zeroStore[6];
        proof[7] = zeroStore[7];
        proof[8] = zeroStore[8];
        proof[9] = zeroStore[9];
        proof[10] = zeroStore[10];
        proof[11] = zeroStore[11];
        proof[12] = zeroStore[12];
        proof[13] = zeroStore[13];
        proof[14] = zeroStore[14];
        proof[15] = zeroStore[15];
        proof[16] = zeroStore[16];
        proof[17] = zeroStore[17];
        proof[18] = zeroStore[18];
        proof[19] = zeroStore[19];

        process.doProveMemoryWrite(id, process.getNextAntiReplayTag(id), proof);
        
        return process.isResolvedForDefendant(id);
    }
    
    function testDisputedWriteDifferentValueInState() returns (bool) {
        uint id = prepareDisputeValid();
        
        uint[] memory reads = new uint[](2);
        uint[] memory writes = new uint[](4);
        
        reads[0] = 1;
        reads[1] = 1000000 - 371096;
        
        writes[0] = 1;
        writes[1] = 1000000 - 371096;
        writes[2] = 1000000 - 371094;
        writes[3] = (uint) (calculateMemoryState(371097));
        
        process.doProvideMemoryAccesses(id, process.getNextAntiReplayTag(id), reads, writes);

        process.doDisputeMemoryWrite(id, process.getNextAntiReplayTag(id), 0);

        bytes32[] memory proof = new bytes32[](20);
        proof[0] = sha3((bytes32) (0xdeadbeef));
        proof[1] = zeroStore[1];
        proof[2] = zeroStore[2];
        proof[3] = zeroStore[3];
        proof[4] = zeroStore[4];
        proof[5] = zeroStore[5];
        proof[6] = zeroStore[6];
        proof[7] = zeroStore[7];
        proof[8] = zeroStore[8];
        proof[9] = zeroStore[9];
        proof[10] = zeroStore[10];
        proof[11] = zeroStore[11];
        proof[12] = zeroStore[12];
        proof[13] = zeroStore[13];
        proof[14] = zeroStore[14];
        proof[15] = zeroStore[15];
        proof[16] = zeroStore[16];
        proof[17] = zeroStore[17];
        proof[18] = zeroStore[18];
        proof[19] = zeroStore[19];
        
        process.doProveMemoryWrite(id, process.getNextAntiReplayTag(id), proof);

        return process.isResolvedForComplainant(id);
    }
    
    function testDisputedReadValid() returns (bool) {
        uint id = prepareDisputeValid();
        
        uint[] memory reads = new uint[](2);
        uint[] memory writes = new uint[](4);
        
        reads[0] = 1;
        reads[1] = 1000000 - 371096;
        
        writes[0] = 1;
        writes[1] = 1000000 - 371096;
        writes[2] = 1000000 - 371097;
        writes[3] = (uint) (calculateMemoryState(371097));
        
        process.doProvideMemoryAccesses(id, process.getNextAntiReplayTag(id), reads, writes);

        process.doDisputeMemoryRead(id, process.getNextAntiReplayTag(id), 0);

        bytes32[] memory proof = new bytes32[](20);
        proof[0] = sha3((bytes32) (0xdeadbeef));
        proof[1] = zeroStore[1];
        proof[2] = zeroStore[2];
        proof[3] = zeroStore[3];
        proof[4] = zeroStore[4];
        proof[5] = zeroStore[5];
        proof[6] = zeroStore[6];
        proof[7] = zeroStore[7];
        proof[8] = zeroStore[8];
        proof[9] = zeroStore[9];
        proof[10] = zeroStore[10];
        proof[11] = zeroStore[11];
        proof[12] = zeroStore[12];
        proof[13] = zeroStore[13];
        proof[14] = zeroStore[14];
        proof[15] = zeroStore[15];
        proof[16] = zeroStore[16];
        proof[17] = zeroStore[17];
        proof[18] = zeroStore[18];
        proof[19] = zeroStore[19];

        process.doProveMemoryRead(id, process.getNextAntiReplayTag(id), proof);

        return process.isResolvedForDefendant(id);
    }
    
    function testDisputedValidMemoryAccessSequence() returns (bool) {
        uint id = prepareDisputeValid();
        
        uint[] memory reads = new uint[](2);
        uint[] memory writes = new uint[](4);
        
        reads[0] = 1;
        reads[1] = 1000000 - 371096;
        
        writes[0] = 1;
        writes[1] = 1000000 - 371096;
        writes[2] = 1000000 - 371097;
        writes[3] = (uint) (calculateMemoryState(371097));
        
        process.doProvideMemoryAccesses(id, process.getNextAntiReplayTag(id), reads, writes);

        process.doDisputeMemoryAccessSequence(id, process.getNextAntiReplayTag(id));

        return process.isResolvedForDefendant(id);
    }
    
    function testDisputedInvalidSequenceWrongWriteValue() returns (bool) {
        uint id = prepareDisputeValid();
        
        uint[] memory reads = new uint[](2);
        uint[] memory writes = new uint[](4);
        
        reads[0] = 1;
        reads[1] = 1000000 - 371096;
        
        writes[0] = 1;
        writes[1] = 1000000 - 371096;
        writes[2] = 1000000 - 371095;
        writes[3] = (uint) (calculateMemoryState(371097));
        
        process.doProvideMemoryAccesses(id, process.getNextAntiReplayTag(id), reads, writes);

        process.doDisputeMemoryAccessSequence(id, process.getNextAntiReplayTag(id));

        return process.isResolvedForComplainant(id);
    }
    
    function testDisputedInvalidSequenceWrongReadAddress() returns (bool) {
        uint id = prepareDisputeValid();

        uint[] memory reads = new uint[](2);
        uint[] memory writes = new uint[](4);
        
        reads[0] = 3;
        reads[1] = 1000000 - 371096;
        
        writes[0] = 1;
        writes[1] = 1000000 - 371096;
        writes[2] = 1000000 - 371097;
        writes[3] = (uint) (calculateMemoryState(371097));
        
        process.doProvideMemoryAccesses(id, process.getNextAntiReplayTag(id), reads, writes);

        process.doDisputeMemoryAccessSequence(id, process.getNextAntiReplayTag(id));

        return process.isResolvedForComplainant(id);
    }
    
    function testDisputedInvalidSequenceWrongWriteAddress() returns (bool) {
        uint id = prepareDisputeValid();

        uint[] memory reads = new uint[](2);
        uint[] memory writes = new uint[](4);
        
        reads[0] = 1;
        reads[1] = 1000000 - 371096;
        
        writes[0] = 3;
        writes[1] = 1000000 - 371096;
        writes[2] = 1000000 - 371097;
        writes[3] = (uint) (calculateMemoryState(371097));
        
        process.doProvideMemoryAccesses(id, process.getNextAntiReplayTag(id), reads, writes);

        process.doDisputeMemoryAccessSequence(id, process.getNextAntiReplayTag(id));

        return process.isResolvedForComplainant(id);
    }
}
