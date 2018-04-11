/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *  Thomas Veale 2017            --- The Unlicense ---
 *  Purpose: This file is the public facing `Exile' project. It 
 *      defines a set of functions that create and manipulate a
 *      bitmap that is intended to be rendered in html as a  
 *      canvas element via jimp or some other image lib.
 *  TODO: 
 *    - Add in bidding mechanism, profit?
 *    -Implement the ability to update entire slots in memory. 
 *      In other wards, if there are two pixles to be updated in
 *      [3][0] and [3][1], do them at the same time.
 *    -Security Assesement. Access control, poison-pill? 
 *    +Look at using an oracle to store the actual image data.
 *      (see oracle branch).
 *    -rename appropriatley.
 *    -Is there a better way to store the addresses of CanvasFrag
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


pragma solidity ^0.4.0;

import "./CanvasFrag.sol";

contract Exile {
    
    address public owner;
    
    modifier restricted() {
        if (msg.sender == owner) _;
    }
    
    address[] canvasFragments;

    event Update(bytes4 color, uint8 x, uint8 y);
        
    function Exile() {
        Fragment();
        owner = msg.sender;
    }
    
    function Fragment() restricted {
        address newFragment = new CanvasFrag(); //create a new instance
        canvasFragments.push(newFragment);         //push the address in
    } 
    
    function getCanvSize () returns (uint) {
        return canvasFragments.length;
    }

    function getAddr (uint i) returns (address) {
        return canvasFragments[i];
    }
    
    /* 
        TODO: Compute which fragment it should be in based on input x and y to
        make it easier on end user
        TODO: restricted should be restricted to some kind of registering... 
        maybe deploy my own exileToken.
    */
    function exile(uint8 f, uint8 x, uint8 y, bytes4 color) 
    {
        CanvasFrag frag = CanvasFrag(canvasFragments[f]);
        frag.set(color, x, y);
        Update(color, x, y);
    }
}

