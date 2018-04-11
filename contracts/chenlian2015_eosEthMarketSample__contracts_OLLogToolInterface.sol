pragma solidity ^0.4.15;


contract OLLogToolInterface {

    function addLog(string log, string logContent);

    function length()  returns (uint);

    function getTagAt(uint nIndex) returns (string);

    function getContentAt(uint nIndex) returns (string);

    function clear();
}