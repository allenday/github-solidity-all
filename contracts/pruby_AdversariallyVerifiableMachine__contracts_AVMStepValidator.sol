contract AVMStepValidator {
    /*
        Validate the correctness of a step, given the result of its memory accesses.
        
        Read accesses are provided as two entries for each value read - the address followed
        by the value that resides at this address (accepted as correct when this is run).
        
        If a read would access a different address than provided, return false.
        
        Write accesses are provided as three entries for each address written - the address
        written and the value that we expect to be written there. The same address may be
        written more than once in a step.
        
        If a write would write to a different address, or write a different value to that
        address, return false.
        
        If the memory accesses constitute a valid sequence, return true.
    */
    function validateStep(uint256[] readAccesses, uint256[] writeAccesses) external returns (bool);
    
    /*
        Return the memory state size used by this machine, as the power of two
        number of words.
        
        If the size is 16, then the memory space is implicitly 2**16 words, each word
        being 256 bits.
    */
    function getMemoryWordsLog2() returns (uint);
    
    /*
        Sanity check limits to prevent defendants engineering
        memory traces that cannot be validated.
        Any memory trace with more than this number of
        reads, or more than this number of writes cannot be provided.
    */
    function getMaximumReadsPerStep() returns (uint);
    function getMaximumWritesPerStep() returns (uint);
}