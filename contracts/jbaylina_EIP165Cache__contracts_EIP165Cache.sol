pragma solidity ^0.4.11;

contract IEIP165 {
    bytes4 constant IEIP165ID =
        bytes4(sha3('supportsInterface(bytes4)'));

    mapping(bytes4 => bool) public supportsInterface;
    function IEIP165() {
        supportsInterface[IEIP165ID] = true;
    }
}

contract EIP165Cache is IEIP165 {

    bytes4 constant public IInvalidID = 0xFFFFFFFF;

    enum ImplStatus { Unknown, NoEIP165, No, Yes }
    struct ContractCache {
        mapping (bytes4 => ImplStatus) interfaces;
    }
    mapping (address => ContractCache) cache;

    function interfaceSupported(address _contract, bytes4 _interfaceId) constant returns (bool) {
        ImplStatus status = getInterfaceImplementationStatus(_contract, _interfaceId);
        return status == ImplStatus.Yes;
    }

    function eip165Supported(address _contract) constant returns (bool) {
        ImplStatus status = getInterfaceImplementationStatus(_contract, IEIP165ID);
        return status == ImplStatus.Yes;
    }

    function interfacesSupported(address _contract, bytes4[] _interfaceIDs) constant returns (bytes32 r) {
        ImplStatus status;
        if (_interfaceIDs.length > 256) throw;
        for (uint i = 0; i < _interfaceIDs.length; i++) {
            status = getInterfaceImplementationStatus(_contract, _interfaceIDs[i]);
            if (status == ImplStatus.Yes) {
              r |= bytes32(2**i);
            }
        }

        return r;
    }

    function getInterfaceImplementationStatus(address _contract, bytes4 _interfaceId) internal returns (ImplStatus) {
        if (!isContract(_contract)) return ImplStatus.NoEIP165;
        ImplStatus status = cache[_contract].interfaces[_interfaceId];
        if (status == ImplStatus.Unknown) {
            status = determineInterfaceImplementationStatus(_contract, _interfaceId);
            cache[_contract].interfaces[_interfaceId] = status;
        }
        return status;
    }

    function determineInterfaceImplementationStatus(address _contract, bytes4 _interfaceId) constant internal returns (ImplStatus) {
        bool success;
        bool result;

        (success, result) = noThrowCall(_contract, IEIP165ID);
        if ((!success)||(!result)) {
            return ImplStatus.NoEIP165;
        }

        (success, result) = noThrowCall(_contract, IInvalidID);
        if ((!success)||(result)) {
            return ImplStatus.NoEIP165;
        }

        (success, result) = noThrowCall(_contract, _interfaceId);
        if (!success) {
            return ImplStatus.NoEIP165;
        } else if (result) {
            return ImplStatus.Yes;
        } else {
            return ImplStatus.No;
        }
    }

    function noThrowCall(address _contract, bytes4 _interfaceId) constant internal returns (bool success, bool result) {
        bytes4 sig = bytes4(sha3("supportsInterface(bytes4)")); //Function signature

        assembly {
                let x := mload(0x40)   //Find empty storage location using "free memory pointer"
                mstore(x,sig) //Place signature at begining of empty storage
                mstore(add(x,0x04),_interfaceId) //Place first argument directly next to signature

                success := call(      //This is the critical change (Pop the top stack value)
                                    30000, //5k gas
                                    _contract, //To addr
                                    0,    //No value
                                    x,    //Inputs are stored at location x
                                    0x8, //Inputs are 8 byes long
                                    x,    //Store output over input (saves space)
                                    0x20) //Outputs are 32 bytes long

                result := mload(x)   // Load the result
        }
    }

    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        assembly {
            size := extcodesize(_addr)
        }
        return size>1;
    }

    function contractSize(address _addr) constant internal returns(uint) {
        uint size;
        assembly {
            size := extcodesize(_addr)
        }
        return size;
    }
}
