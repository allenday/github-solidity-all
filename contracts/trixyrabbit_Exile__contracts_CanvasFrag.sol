/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  Thomas Veale 2017            --- The Unlicense ---
 *  Purpose: This file defines a ``canvas fragment,'' which is a 
 *      cluster (most likely square) of pixles pointed to by the
 *      Exile contract (see Exile.sol). The primary motivataion 
 *      is to storage costs and gas.
 *  TODO: 
 *    -improve the space complexity, possibly via assebler or an 
 *      encoding scheme.
 *    -Implement the ability to update entire slots in memory. 
 *      In other wards, if there are two pixles to be updated in
 *      [3][0] and [3][1], do them at the same time.
 *    -Security Assesement. Access control on sets, poison-pill? 
 *    +Look at using an oracle to store the actual image data.
 *      (see oracle branch).
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


pragma solidity ^0.4.0;

contract CanvasFrag {
    
    address public owner;
    
    modifier restricted() {
        if (msg.sender == owner) _;
    }
    /* pixles struct 32bits
        exactly the read size
        red :  00 to FF
        blue:  00 to FF
        green: 00 to FF
        alpha: 00 to FF
    */
    struct rbg {
        uint8 r;
        uint8 b; 
        uint8 g;
        uint8 a;
    }
    
    
    /* Event emmited for web client to catch the updates */
    event Update(bytes4 color, uint8 x, uint8 y);
    
    
    /* canvas, 2D array of rbg 32bits values */
    /* warn: the x and y coordinates are reverse compared to MOST other languages */
    rbg[4][4] public canvas;

    function CanvasFrag(){
        wipe();
    }
    
    /*
        the function wipe iterates through the canvas
        and writes 0s to the canvas. This is very expensive.
    */
    function wipe() restricted {
        uint8 r = 0x00;
        uint8 b = 0x00;
        uint8 g = 0x00;
        uint8 a = 0x00;
        for (uint j = 0; j < 4; j++) {
            for (uint i = 0; i < 4; i++) {
                canvas[j][i] = rbg(r, b, g, a);
                r++; b++; g++; a++;
            }
        }
    }
    
    /* the function set takes 3 arguments,
        color, a bytes32 fixed sized array of rbga info
        uint8, the x coordinate
        uint8, the y cooridnate
    */
    function set(bytes4 color, uint8 x, uint8 y) restricted {
        uint8 r = uint8(color[0]); //color[0], color[1], color[2], color[3]
        uint8 b = uint8(color[1]);
        uint8 g = uint8(color[2]);
        uint8 a = uint8(color[3]);
        canvas[y][x] = rbg(r,b,g,a);
        Update(color, x, y);
    }
    

    
    
}