// Solidity does not allow a contract to call its own constructor which 
// makes writing a self-cloning contract tricky. The following contract can
// clone itself by resorting to the use of EVM assembly. You can rename this
// contract or add any functionality you might want, but there are some
// limitations:
// The constructor of the contract must be empty. Instead, I  suggest you use 
// an initialize() function and call that after contract creation. Be aware 
// that anyone may call this function and use appropriate safe-guards.

contract SelfcloningContract {
    event Cloned(bool success, address clone_address);
    
    function clone() returns (address clone_address) {
        assembly {
            // 0x40 contains first free memory address
            let free_ptr := mload(0x40)
            // copy code of current contract
            codecopy(add(free_ptr, 32), 0, codesize())
            // prefix by 12-byte initcode header for create:
            // ;; top [] bottom
            // PC
            // ;; [0]
            // PUSH1 12
            // ;; [header size, 0]
            // DUP1
            // ;; [header size, header size, 0]
            // CODESIZE
            // ;; [code size, header size, header size, 0]
            // SUB
            // ;; [payload size, header size, 0]
            // DUP1
            // ;; [payload size, payload size, header size, 0]
            // DUP3
            // ;; [header size, payload size, payload size, header size, 0]
            // DUP5
            // ;; [0, header size, payload size, payload size, header size, 0]
            // CODECOPY
            // ;; [payload size, header size, 0]
            // DUP3
            // ;; [0, payload size, header size, 0]
            // RETURN
            // ;; [header size, 0]
            //
            // Bytecode representation:
            // 58600c8038038082843982f3
            mstore(free_ptr, 0x58600c8038038082843982f3)
            // create clone
            clone_address := create(0, add(free_ptr, 20), add(12, codesize()))
        }
        
        Cloned(clone_address != 0, clone_address);
    }
}
