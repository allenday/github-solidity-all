/// @title What happens when things go wrong?
/// @author hugooconnor

contract Errors {

    uint[10] public numbersFixed;
    uint[] public numbersDynamic;
    mapping(address => uint) tokens;

    // struct Error {
    //     uint time;
    //     string reason;
    // }

    function Errors(){
        numbersFixed[0] = 100;
    }

    function divideByZero(uint number) returns (uint result){
        return number/0;
    }

    function arrayIndexOutOfBounds(uint index) returns (uint result){
        return numbersFixed[index];
    }

    function arrayIndexOutOfBoundsDynamic(uint index) returns (uint result){
        return numbersDynamic[index];
    }

    function bigLoop(uint loopSize) returns (uint result){
        for(uint i=0; i < loopSize; i++){
            numbersFixed[0] = i; // see http://ether.fund/tool/gas-fees
        }
        return numbersFixed[0];
    }

    //Internal type is not allowed for public or external functions.
    // ie this won't work;
    // function returnError() returns (Error error){
    //     return Error(now, "test");
    // }

}