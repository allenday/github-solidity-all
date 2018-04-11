pragma solidity ^0.4.0;

contract VendingMachine {
    uint balance;
    mapping (uint => string) public numberToFood;
    mapping (uint => uint) public numberToAmount;
    mapping (uint => uint) public numberToPrice;


    //event boughtSomething(address from, uint testimonyID, bytes32 hash);

    function VendingMachine() {
      balance = 0;
    }

    function addBalance(uint money) {
      balance += money;
    }

    function subBalance(uint money) private {
      if(money > balance) {
        throw;
      } else
      balance -= money;
    }

    function private isUsed(uint number) {
      return(numberToAmount[number]>0);
    }

    function public addFood(uint number,uint amount, string food) {
      if(isUsed(number) && numberToFood[number] != food) {
        throw;
      }
      numberToFood[number] = food;
      numberToAmount[number] += amount;
    }

    function public orderFood(uint number) returns (string food) {

      numberToAmount[number] -= 1;
      return "Here is your " + numberToFood[number];
    }




    function order(uint number, uint money) returns (string food, uint change) {
      if(money < numberToPrice[number]) {
        throw;
      } else {
        return(numberToFood[number], money - numberToPrice[number])
      }
    }
}
