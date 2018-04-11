import 'AVMStepValidator.sol';

contract AVMDisputeProcess {
    uint disputeCount;
    mapping (uint => Dispute) disputes;
    mapping (uint => string) public disputeStateToText;

    // Used for debugging (should not be emitted in production)
    event trace(string);
    
    enum DisputeState {
        AWAIT_STEP_ROOTS,
        AWAIT_DISPUTED_ROOT,
        AWAIT_MEMORY_ACCESSES,
        AWAIT_COMPLAINANT_CHOICE,
        DISPUTED_READ,
        DISPUTED_WRITE,
        RESOLVED_FOR_DEFENDANT,
        RESOLVED_FOR_COMPLAINANT
    }
    
    modifier in_state(uint disputeId, DisputeState state) {
        if (((uint) (disputes[disputeId].step) != 0) && (disputes[disputeId].state == state)) {
            _
        }
    }
    
    event DisputeProgress(uint disputeId, DisputeState state);
    function transition(uint disputeId, DisputeState state) internal {
        disputes[disputeId].state = state;
        disputes[disputeId].lastResponseTime = now;
        DisputeProgress(disputeId, state);
    }
    
    modifier is_complainant(uint disputeId) {
        if (msg.sender == disputes[disputeId].complainant) _
    }
    
    modifier is_defendant(uint disputeId) {
        if (msg.sender == disputes[disputeId].defendant) _
    }
    
    modifier noether {
        if (msg.value > 0) throw;
        _
    }
    
    // This dispute process is extremely sensitive to transaction replay, as
    // otherwise identical messages could be sent multiple times.
    // By sending a tag indicating the last state we saw, we avoid having to wait
    // for enough blocks to pass to be sure the chain won't be reversed.
    // This should be applied after the state and identity check.
    // As only one party can act at once, only one party can couse this to change
    // under normal conditions.
    modifier check_replay_tag(uint disputeId, bytes32 antiReplayTag) {
        if (antiReplayTag == disputes[disputeId].antiReplayTag) {
            disputes[disputeId].antiReplayTag = sha3(disputes[disputeId].antiReplayTag, block.blockhash(0));
            _
        }
    }
    
    function getNextAntiReplayTag(uint disputeId) external noether returns (bytes32) {
        return disputes[disputeId].antiReplayTag;
    }
    
    struct Dispute {
        // Configuration
        AVMStepValidator step;
        address defendant;
        address complainant;
        address querySource;
        uint maxResponseDelay;
        uint maxResponseStates;
        uint memoryStateSize;
        
        // Changeable state
        DisputeState state;
        uint lastResponseTime;
        bytes32 antiReplayTag;
        uint firstAcceptedStep;
        bytes32 firstAcceptedStateRoot;
        uint lastDisputedStep;
        bytes32 lastDisputedStateRoot;
        uint numReads;
        uint numWrites;
        uint selectedAccess;
        bytes32[1048576] buffer;
    }
    
    function AVMDisputeProcess() {
        disputeStateToText[(uint) (DisputeState.AWAIT_STEP_ROOTS)] = "awaiting state roots from defendant";
        disputeStateToText[(uint) (DisputeState.AWAIT_DISPUTED_ROOT)] = "awaiting complainant's selection of disputed root";
        disputeStateToText[(uint) (DisputeState.AWAIT_MEMORY_ACCESSES)] = "awaiting memory accesses from defendant";
        disputeStateToText[(uint) (DisputeState.AWAIT_COMPLAINANT_CHOICE)] = "awaiting aspect of memory trace to dispute from complainant";
        disputeStateToText[(uint) (DisputeState.DISPUTED_READ)] = "complainant disputed a read, waiting for defendant to prove read value";
        disputeStateToText[(uint) (DisputeState.DISPUTED_WRITE)] = "complainant disputed write, waiting for defendant to prove write transition";
        disputeStateToText[(uint) (DisputeState.RESOLVED_FOR_DEFENDANT)] = "resolved (defendant won)";
        disputeStateToText[(uint) (DisputeState.RESOLVED_FOR_COMPLAINANT)] = "resolved (complainant won)";
    }
    
    function getDisputeState(uint disputeId) constant external noether returns (DisputeState) {
        Dispute storage dispute = disputes[disputeId];
        return dispute.state;
    }
    
    function getDisputeStateText(uint disputeId) constant external noether returns (string) {
        Dispute storage dispute = disputes[disputeId];
        return disputeStateToText[(uint) (dispute.state)];
    }
    
    function getDisputeParticipants(uint disputeId) constant external noether returns (address, address, address) {
        Dispute storage dispute = disputes[disputeId];
        return (dispute.defendant, dispute.complainant, dispute.querySource);
    }
    
    function getStepFunction(uint disputeId) constant external noether returns (AVMStepValidator) {
        Dispute storage dispute = disputes[disputeId];
        return (dispute.step);
    }
    
    function getDisputeMemorySize(uint disputeId) constant external noether returns (uint) {
        Dispute storage dispute = disputes[disputeId];
        return dispute.memoryStateSize;
    }
    
    function getDisputeTimeoutState(uint disputeId) constant external noether returns (uint, uint) {
        Dispute storage dispute = disputes[disputeId];
        return (dispute.lastResponseTime, dispute.maxResponseDelay);
    }
    
    function getPeriodInDispute(uint disputeId) constant external noether returns (uint, bytes32, uint, bytes32) {
        Dispute storage dispute = disputes[disputeId];
        return (dispute.firstAcceptedStep, dispute.firstAcceptedStateRoot, dispute.lastDisputedStep, dispute.lastDisputedStateRoot);
    }
    
    function getMaxResponseStates(uint disputeId) constant external noether returns (uint) {
        Dispute storage dispute = disputes[disputeId];
        return (dispute.maxResponseStates);
    }
    
    function getRequiredStateNumbers(uint disputeId) constant external noether returns (uint[] memory) {
        Dispute storage dispute = disputes[disputeId];
        
      uint expectedStateRootCount;
        uint stepsInQuestion = dispute.lastDisputedStep - dispute.firstAcceptedStep - 1;
        uint stride;
        if (stepsInQuestion <= dispute.maxResponseStates) {
            expectedStateRootCount = stepsInQuestion;
            stride = 1;
        } else {
            expectedStateRootCount = dispute.maxResponseStates;
            stride = (stepsInQuestion + 1) / (dispute.maxResponseStates + 1);
        }

        uint[] memory stateNumbers = new uint[](expectedStateRootCount);
        
        for (uint i = 0; i < expectedStateRootCount; i++) {
            uint stepNumber = dispute.firstAcceptedStep + (stride * (i+1));
            stateNumbers[i] = stepNumber;
        }
        return stateNumbers;
    }
    
    function getSubmittedStateRoot(uint disputeId, uint stateId) constant external noether returns (bytes32) {
        Dispute storage dispute = disputes[disputeId];
        return dispute.buffer[stateId];
    }
    
    function getMemoryTraceMeta(uint disputeId) constant external noether returns (uint, uint) {
        Dispute storage dispute = disputes[disputeId];
        return (dispute.numReads, dispute.numWrites);
    }
    
    function getMemoryRead(uint disputeId, uint readId) constant external noether returns (uint, uint) {
        Dispute storage dispute = disputes[disputeId];
        uint readAddress = (uint) (dispute.buffer[readId * 2]);
        uint value = (uint) (dispute.buffer[readId * 2 + 1]);
        return (readAddress, value);
    }
    
    function getMemoryWrite(uint disputeId, uint writeId) constant external noether returns (uint, uint, uint, bytes32) {
        Dispute storage dispute = disputes[disputeId];
        uint offset = dispute.numReads * 2;
        uint writeAddress = (uint) (dispute.buffer[offset + writeId * 4]);
        uint initialValue = (uint) (dispute.buffer[offset + writeId * 4 + 1]);
        uint writtenValue = (uint) (dispute.buffer[offset + writeId * 4 + 2]);
        bytes32 resultStateRoot = dispute.buffer[offset + writeId * 4 + 3];
        return (writeAddress, initialValue, writtenValue, resultStateRoot);
    }
    
    function openDispute (
        AVMStepValidator step,
        address defendant,
        address complainant,
        bytes32 initialStateRoot,
        bytes32 claimedFinalRoot,
        uint stepCount,
        uint maxResponseDelay,
        uint maxResponseStates)  external noether returns (uint) {
        
        uint disputeId = disputeCount++;
        Dispute storage dispute = disputes[disputeId];
        dispute.querySource = msg.sender;
        dispute.step = step;
        dispute.complainant = complainant;
        dispute.defendant = defendant;
        dispute.firstAcceptedStep = 0;
        dispute.firstAcceptedStateRoot = initialStateRoot;
        dispute.lastDisputedStep = stepCount;
        dispute.lastDisputedStateRoot = claimedFinalRoot;
        dispute.maxResponseDelay = maxResponseDelay;
        dispute.maxResponseStates = maxResponseStates;
        dispute.memoryStateSize = step.getMemoryWordsLog2();
        
        dispute.state = DisputeState.AWAIT_STEP_ROOTS;
        dispute.lastResponseTime = now;
        dispute.antiReplayTag = sha3(disputeId, block.blockhash(0));
        
        return disputeId;
    }
    
    function isResolvedForComplainant(uint disputeId) constant external noether returns (bool) {
        return disputes[disputeId].state == DisputeState.RESOLVED_FOR_COMPLAINANT;
    }
    
    function isResolvedForDefendant(uint disputeId) constant external noether returns (bool) {
        return disputes[disputeId].state == DisputeState.RESOLVED_FOR_DEFENDANT;
    }
    
    function doTimeoutForComplainant(uint disputeId)
        external noether
        is_complainant(disputeId) {
        Dispute storage dispute = disputes[disputeId];

        if (dispute.lastResponseTime + dispute.maxResponseDelay < now) {
            if (dispute.state == DisputeState.AWAIT_STEP_ROOTS ||
                dispute.state == DisputeState.AWAIT_MEMORY_ACCESSES ||
                dispute.state == DisputeState.DISPUTED_READ ||
                dispute.state == DisputeState.DISPUTED_WRITE ) {
                transition(disputeId, DisputeState.RESOLVED_FOR_COMPLAINANT);
            }
        }
    }
    
    function doTimeoutForDefendant(uint disputeId)
        external noether
        is_complainant(disputeId) {
        Dispute storage dispute = disputes[disputeId];

        if (dispute.lastResponseTime + dispute.maxResponseDelay < now) {
            if (dispute.state == DisputeState.AWAIT_DISPUTED_ROOT ||
                dispute.state == DisputeState.AWAIT_COMPLAINANT_CHOICE ) {
                transition(disputeId, DisputeState.RESOLVED_FOR_DEFENDANT);
            }
        }
    }
    
    /*
        Method for defendant to provide state roots at fixed intervals, of which
        the complainant must identify the first that they believe is incorrect.
    */
    function doProvideStateRoots(uint disputeId, bytes32 antiReplayTag, bytes32[] stateRoots)
        external noether
        in_state(disputeId, DisputeState.AWAIT_STEP_ROOTS)
        is_defendant(disputeId)
        check_replay_tag(disputeId, antiReplayTag) {
        Dispute storage dispute = disputes[disputeId];

        uint expectedStateRootCount;
        uint stepsInQuestion = dispute.lastDisputedStep - dispute.firstAcceptedStep - 1;
        if (stepsInQuestion <= dispute.maxResponseStates) {
            expectedStateRootCount = stepsInQuestion;
        } else {
            expectedStateRootCount = dispute.maxResponseStates;
        }
        
        if (stateRoots.length == expectedStateRootCount) {
            // Store submitted state roots
            for (uint i = 0; i < expectedStateRootCount; i++) {
                dispute.buffer[i] = stateRoots[i];
            }
            transition(disputeId, DisputeState.AWAIT_DISPUTED_ROOT);
        }
    }
    
    function doSelectDisputedStateRoot(uint disputeId, bytes32 antiReplayTag, uint disputedRoot)
        external noether
        in_state(disputeId, DisputeState.AWAIT_DISPUTED_ROOT)
        is_complainant(disputeId)
        check_replay_tag(disputeId, antiReplayTag) {
        Dispute storage dispute = disputes[disputeId];

        uint expectedStateRootCount;
        uint stepsInQuestion = dispute.lastDisputedStep - dispute.firstAcceptedStep - 1;
        uint stride;
        if (stepsInQuestion <= dispute.maxResponseStates) {
            expectedStateRootCount = stepsInQuestion;
            stride = 1;
        } else {
            expectedStateRootCount = dispute.maxResponseStates;
            stride = (stepsInQuestion + 1) / (dispute.maxResponseStates + 1);
        }
        uint acceptedStepNumber = dispute.firstAcceptedStep +  (stride * disputedRoot);
        uint disputedStepNumber = dispute.firstAcceptedStep + (stride * (disputedRoot + 1));
        
        if (disputedRoot <= expectedStateRootCount) {
            // Valid selection from the submitted roots
            if (disputedRoot == 0) {
                // Disputing the first state provided
                dispute.lastDisputedStep = disputedStepNumber;
                dispute.lastDisputedStateRoot = dispute.buffer[disputedRoot];
            } else if (disputedRoot == expectedStateRootCount) {
                // Accepting all submitted states - current last disputed step stands
                dispute.firstAcceptedStep = acceptedStepNumber;
                dispute.firstAcceptedStateRoot = dispute.buffer[disputedRoot - 1];
            } else {
                // Disputing an intermediate state - change both first and last
                dispute.firstAcceptedStep = acceptedStepNumber;
                dispute.firstAcceptedStateRoot = dispute.buffer[disputedRoot - 1];
                dispute.lastDisputedStep = disputedStepNumber;
                dispute.lastDisputedStateRoot = dispute.buffer[disputedRoot];
            }
            
            if (dispute.lastDisputedStep - dispute.firstAcceptedStep == 1) {
                transition(disputeId, DisputeState.AWAIT_MEMORY_ACCESSES);
            } else {
                transition(disputeId, DisputeState.AWAIT_STEP_ROOTS);
            }
        }
    }
    
    function doProvideMemoryAccesses(uint disputeId, bytes32 antiReplayTag, uint256[] reads, uint256[] writes)
        external noether
        in_state(disputeId, DisputeState.AWAIT_MEMORY_ACCESSES)
        is_defendant(disputeId)
        check_replay_tag(disputeId, antiReplayTag) {
        Dispute storage dispute = disputes[disputeId];
        
        // Format of a read is address, value
        // Format of a write is address, original value, changed value, result state root
        if (reads.length % 2 == 0
            && writes.length % 4 == 0
            && (reads.length / 2) <= dispute.step.getMaximumReadsPerStep()
            && (writes.length / 4) <= dispute.step.getMaximumWritesPerStep()) {
            // Store reads and writes
            dispute.numReads = reads.length / 2;
            dispute.numWrites = writes.length / 4;
            uint i;
            for (i = 0; i < reads.length; i++) {
                dispute.buffer[i] = (bytes32) (reads[i]);
            }
            for (i = 0; i < writes.length; i++) {
                dispute.buffer[reads.length + i] = (bytes32) (writes[i]);
            }
            
            // Check whether the last write in sequence results in the
            // state root following this step
            if (writes.length == 0) {
                // State root must not change without any writes
                if (dispute.firstAcceptedStateRoot != dispute.lastDisputedStateRoot) {
                    transition(disputeId, DisputeState.RESOLVED_FOR_COMPLAINANT);
                    return;
                }
            } else {
                // Final write must result in the declared end state
                if ((bytes32) (writes[writes.length - 1]) != dispute.lastDisputedStateRoot) {
                    transition(disputeId, DisputeState.RESOLVED_FOR_COMPLAINANT);
                    return;
                }
            }
            transition(disputeId, DisputeState.AWAIT_COMPLAINANT_CHOICE);
        }
    }
    
    function doDisputeMemoryRead(uint disputeId, bytes32 antiReplayTag, uint readId)
        external noether
        in_state(disputeId, DisputeState.AWAIT_COMPLAINANT_CHOICE)
        is_complainant(disputeId)
        check_replay_tag(disputeId, antiReplayTag) {
        Dispute storage dispute = disputes[disputeId];
        
        if (readId < dispute.numReads) {
            dispute.selectedAccess = readId;
            transition(disputeId, DisputeState.DISPUTED_READ);
        }
    }
    
    function doDisputeMemoryWrite(uint disputeId, bytes32 antiReplayTag, uint writeId)
        external noether
        in_state(disputeId, DisputeState.AWAIT_COMPLAINANT_CHOICE)
        is_complainant(disputeId)
        check_replay_tag(disputeId, antiReplayTag) {
        Dispute storage dispute = disputes[disputeId];
        
        if (writeId < dispute.numWrites) {
            dispute.selectedAccess = writeId;
            transition(disputeId, DisputeState.DISPUTED_WRITE);
        }
    }
    
    function doDisputeMemoryAccessSequence(uint disputeId, bytes32 antiReplayTag)
        external noether
        in_state(disputeId, DisputeState.AWAIT_COMPLAINANT_CHOICE)
        is_complainant(disputeId)
        check_replay_tag(disputeId, antiReplayTag) {
        Dispute storage dispute = disputes[disputeId];
        
        uint256[] memory reads = new uint256[](dispute.numReads * 2); 
        uint256[] memory writes = new uint256[](dispute.numWrites * 3);
        
        for (uint i = 0; i < dispute.numReads; i++) {
            reads[2*i] = (uint256) (dispute.buffer[2*i]);
            reads[2*i+1] = (uint256) (dispute.buffer[(2*i)+1]);
        }
        
        uint offset = 2 * dispute.numReads;
        for (i = 0; i < dispute.numWrites; i++) {
            writes[3*i] = (uint256) (dispute.buffer[offset + (4*i)]);
            writes[3*i+1] = (uint256) (dispute.buffer[offset + (4*i) + 1]);
            writes[3*i+2] = (uint256) (dispute.buffer[offset + (4*i) + 2]);
        }
        
        // Note: whereas send is expected to return false in the event of
        // stack exhaustion, the Solidity documentation states that we throw
        // an exception if a call expecting a result fails. We rely on this,
        // but should validate. Likewise for recursive calls in the step.
        if (dispute.step.validateStep(reads, writes)) {
            transition(disputeId, DisputeState.RESOLVED_FOR_DEFENDANT);
        } else {
            transition(disputeId, DisputeState.RESOLVED_FOR_COMPLAINANT);
        }
    }
   
    function doProveMemoryRead(uint disputeId, bytes32 antiReplayTag, bytes32[] merkleProof)
        external noether
        in_state(disputeId, DisputeState.DISPUTED_READ)
        is_defendant(disputeId)
        check_replay_tag(disputeId, antiReplayTag) {
        Dispute storage dispute = disputes[disputeId];
        
        uint readAddress = (uint) (dispute.buffer[dispute.selectedAccess * 2]);
        uint readValue = (uint) (dispute.buffer[dispute.selectedAccess * 2 + 1]);
        uint i;
        bytes32 resultState;
        
        // Validate that the provided proof is of the correct length
        if (merkleProof.length != dispute.memoryStateSize) {
            // Invalid proof length
            transition(disputeId, DisputeState.RESOLVED_FOR_COMPLAINANT);
            return;
        }
        
        // Validate the Merkle proof that this value lies at the stated
        // address within the starting state root hash.
        resultState = sha3(dispute.buffer[dispute.selectedAccess * 2 + 1]);
        for (i = 0; i < dispute.memoryStateSize; i++) {
            if ((readAddress & 1) != 0) {
                resultState = sha3(merkleProof[i], resultState);
            } else {
                resultState = sha3(resultState, merkleProof[i]);
            }
            readAddress /= 2;
        }
        
        if (resultState == dispute.firstAcceptedStateRoot) {
            // Proven
            transition(disputeId, DisputeState.RESOLVED_FOR_DEFENDANT);
            return;
        } else {
            // Invalid proof
            transition(disputeId, DisputeState.RESOLVED_FOR_COMPLAINANT);
            return;
        }
    }
    
    function doProveMemoryWrite(uint disputeId, bytes32 antiReplayTag, bytes32[] merkleProof)
        external noether
        in_state(disputeId, DisputeState.DISPUTED_WRITE)
        is_defendant(disputeId)
        check_replay_tag(disputeId, antiReplayTag) {
        Dispute storage dispute = disputes[disputeId];
        
        uint writeAddress = (uint) (dispute.buffer[dispute.numReads * 2 + dispute.selectedAccess * 4]);

        bytes32 declaredStartState = dispute.firstAcceptedStateRoot;
        if (dispute.selectedAccess > 0) {
            declaredStartState = dispute.buffer[dispute.numReads * 2 + (dispute.selectedAccess - 1) * 4 + 3];
        }
        
        bytes32 resultState;
        uint i;
        
        // Validate that the provided proof is of the correct length
        if (merkleProof.length != dispute.memoryStateSize) {
            // Invalid proof length
            trace("Invalid proof length");
            transition(disputeId, DisputeState.RESOLVED_FOR_COMPLAINANT);
            return;
        }
        
        // Validate that using the proof with the original value stated
        // results in the original state root hash. This ensures that we
        // can change only the affected memory location within the memory.
        resultState = sha3(dispute.buffer[dispute.numReads * 2 + dispute.selectedAccess * 4 + 1]);
        for (i = 0; i < dispute.memoryStateSize; i++) {
            if ((writeAddress & 1) != 0) {
                resultState = sha3(merkleProof[i], resultState);
            } else {
                resultState = sha3(resultState, merkleProof[i]);
            }
            writeAddress /= 2;
        }
        
        if (resultState != declaredStartState) {
            // Invalid proof
            trace("Invalid original state proof");
            transition(disputeId, DisputeState.RESOLVED_FOR_COMPLAINANT);
            return;
        }
        
        // Validate that with the value written, the state root hash becomes
        // the declared result state root. This validates that the new state root
        // has not been otherwise changed.
        writeAddress = (uint) (dispute.buffer[dispute.numReads * 2 + dispute.selectedAccess * 4]);
        resultState = sha3(dispute.buffer[dispute.numReads * 2 + dispute.selectedAccess * 4 + 2]);
        for (i = 0; i < dispute.memoryStateSize; i++) {
            if ((writeAddress & 1) != 0) {
                resultState = sha3(merkleProof[i], resultState);
            } else {
                resultState = sha3(resultState, merkleProof[i]);
            }
            writeAddress /= 2;
        }
        
        if (resultState != dispute.buffer[dispute.numReads * 2 + dispute.selectedAccess * 4 + 3]) {
            // Invalid proof
            trace("Invalid final state proof");
            transition(disputeId, DisputeState.RESOLVED_FOR_COMPLAINANT);
            return;
        }
        
        // Successfully proven
        trace("Write proven");
        transition(disputeId, DisputeState.RESOLVED_FOR_DEFENDANT);
        return;
    }
    
    function() external noether {
        // Do not accept payments
    }
}
