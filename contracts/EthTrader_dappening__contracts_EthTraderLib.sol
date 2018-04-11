pragma solidity ^0.4.17;

library EthTraderLib {

    function checkProof(bytes32[] proof, bytes32 root, bytes32 hash) public pure returns (bool) {

        for (uint i = 0; i < proof.length; i++) {
            if (hash < proof[i]) {
                hash = keccak256(hash, proof[i]);
            } else {
                hash = keccak256(proof[i], hash);
            }
        }

        return hash == root;
    }

    function split32_20_12(bytes32 data) public pure returns (bytes20 twenty, bytes12 twelve) {
        twenty=extract20(data);
        for (uint i=20; i<32; i++)
            twelve^=(bytes12(0xff0000000000000000000000)&data[i])>>((i-20)*8);
    }

    function extract20(bytes32 data) public pure returns (bytes20 result) {
        for (uint i=0; i<20; i++)
            result^=(bytes20(0xff00000000000000000000000000000000000000)&data[i])>>(i*8);
    }

    function ethereumSHA3(bytes20 _username, uint24 _endowment,  uint32 _firstContent) public view returns (bytes32 result) {
        bytes32 hash = keccak256(msg.sender, _username, _endowment, _firstContent);
        return hash;
    }

}
