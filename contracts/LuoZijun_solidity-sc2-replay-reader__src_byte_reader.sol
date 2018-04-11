pragma solidity ^0.4.8;

// library BitReader {

// }

/**

// JavaScript Number To Bits

function number_to_binary(n, b){
    var s = [], m;
    while (n !== 0){
        m = n % b;
        n = Math.floor(n / b);
        s.push(m.toString());
    }
    s.push("0b");
    s.reverse();
    return s.join("");
}
**/

library ByteReader {
    // Uint
    function read_u8(){

    }
    function read_u16(){

    }
    function read_u32(){

    }
    function read_u64(){

    }
    // Int
    function read_i8(){

    }
    function read_i16(){

    }
    function read_i32(){

    }
    function read_i64(){

    }

    // Array
    function read_u8_array(){

    }
    function read_u16_array(){

    }
    function read_u32_array(){

    }
    function read_u64_array(){

    }

    function read_i8_array(){

    }
    function read_i16_array(){

    }
    function read_i32_array(){

    }
    function read_i64_array(){

    }


    // storage memory
    function byte_to_bits(uint n) returns (uint[] s) {
        uint b = 2;
        uint idx = 0;
        uint[] s;
        while ( n != 0 ) {
            uint m = n % b;
            n = n/b;
            s.push(m);
        }
    }
}