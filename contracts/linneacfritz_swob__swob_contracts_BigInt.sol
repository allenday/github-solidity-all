pragma solidity ^0.4.7;
//
// Big number library in Solidity for the purpose of implementing modexp.
//
// Should have a similar API to https://github.com/ethereum/EIPs/issues/101
//
// Internally bignumbers are represented as an uint array of 128 bit values.
//
// NOTE: it assumes usage with "small" (<256bit) exponents (such as in RSA)
//

library BigInt {
    // Interface with "bytes"
    function modexp(bytes b, uint e, bytes m) returns (bytes r) {
        return __save128(modexp(__load128(b), e, __load128(m)));
    }

    // Interface with "uint[]"
    function modexp(uint[] b, uint e, uint[] m) returns (uint[] r) {
        // FIXME: implement this, perhaps using Montgomery multiplication

        return m; // only here to be able to test __load128/__save128
    }

    // A naive approach is the below.
    function modexp_naive(bytes b, uint e, bytes m) returns (bytes r) {
        r = new bytes(1);
        r[0] = 1;

        for (; e != 0;) {
            if ((e & 1) == 1)
                r = __mulmod(r, b, m);
            e /= 2;
            b = __mulmod(b, b, m);
        }

        return r;
    }

    // NOTE: these are `private` in order to use internal Solidity calling convention (cheaper)
    function __mulmod(bytes a, bytes b, bytes m) private returns (bytes r) {
        return __mod(__mul(a, b), m);
    }

    function __mod(bytes a, bytes m) private returns (bytes r) {
        // FIXME
    }

    function __mul(bytes a, bytes b) private returns (bytes r) {
        // FIXME
    }

    // Parse an arbitrary long number as 128-bit chunks into b[]
    function __load128(bytes a) private returns (uint[] b) {
        uint s = a.length / 16;
        if (a.length % 16 > 0)
            s++;

        b = new uint[](s);

        if (s == 0) return b;

        // the first 128 bits, as it is left-aligned, we need to take the top
        uint tmp;
        assembly {
            tmp := mload(add(a, 32))
            tmp := and(tmp, 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000)
            tmp := div(tmp, 0xffffffffffffffffffffffffffffffff)
        }
        b[0] = tmp;

        // any subsequent 128 bits means masking the bottom 128 bits
        uint j = 2 * 16;
        for (uint i = 1; i < s; i++) {
            assembly {
                tmp := mload(add(a, j))
                tmp := and(tmp, 0xffffffffffffffffffffffffffffffff)
            }
            b[i] = tmp;
            j += 16;
        }
    }

    function __save128(uint[] a) private returns (bytes b) {
        b = new bytes(a.length * 16);

        if (a.length == 0) return b;

        for (uint i = 0; i < a.length; i++) {
            uint tmp = a[i];
            assembly {
                // shift left 128 bits
                tmp := mul(tmp, 0x100000000000000000000000000000000)
                // store each 128 bit section left aligned
                mstore(add(b, add(32, mul(16, i))), tmp)
            }
        }
    }
}
