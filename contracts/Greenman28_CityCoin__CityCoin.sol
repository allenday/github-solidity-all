pragma solidity ^0.4.12;
contract CCProject {
    
    uint8 constant UNDENTIFIED = 0;
    uint8 constant LIGHTWEIGHT = 1;
    uint8 constant TRUCK = 2;
    uint8 constant SPECIAL = 3;
    address owner;
    
    function CCProject() {
        owner = msg.sender;
    }

    struct Car {
        address adres;  //адрес счёта
        uint8 carType;  //тип машины
        uint16 number;  //номер машины
        int balance;    //баланс счёта
        uint sum;       //общая сумма счёта за все время
        bool wasFine;   //был ли штраф
        uint time;
    }
    
    mapping(uint16 => Car) cars;
    mapping(address => uint16) carsNum;
    
    function setFine(uint16 num) private {
        cars[num].wasFine = true;
        cars[num].time = now;
    }
    
    function resetFine(uint16 num) private {
        cars[num].wasFine = false;
    }
    
    function main(uint16 num, uint8 point){ //главная функция
        cars[num].balance -= checkPoint(point,num);
    }
    
    function() payable{ //функция для получения денег
        var sender = carsNum[msg.sender];
        if(cars[sender].balance>0 && cars[sender].wasFine){
            resetFine(sender);
        }
        cars[sender].balance  += int(msg.value);
        cars[sender].sum+=msg.value;
    }
    
    //получение баланса
    function getBalance(uint16 num) constant public returns (int){
        return cars[num].balance;
    } 
    
    //получение адреса
    function getAdres(uint16 num) constant public returns (address){
        return cars[num].adres;
    }
    
    //получение типа
    function getType(uint16 num) constant public returns (uint8){
        return cars[num].carType;
    } 
    
    //получение суммы
    function getSum(uint16 num) constant public returns (uint){
        return cars[num].sum;
    } 
    
    
    function addCar(address adr, uint8 carType, uint16 num) constant public{
        cars[num] = Car(adr, carType, num, 0, 0, false, 0);
    }
    
    function checkPoint(uint8 point, uint16 num )constant public returns (uint8){ 
        if(cars[num].carType == SPECIAL && point!=6){
            return 0;
        }
        else if ( point == 8){
            return 0;
        }
        else if(point == 6){
            return 3;
        }
        else if(cars[num].carType != SPECIAL)
        {
            if(cars[num].carType == LIGHTWEIGHT){
                if(point == 0 || point == 1 || point == 2 || point == 4 || point == 5){
                    return 1;
                }
                if(point == 3){
                    return 2;
                }
                if(point == 6){
                    return 3;
                }
                if(point == 7){
                    return 4;
                }
            }
            if(cars[num].carType == TRUCK){
                if(point == 0 || point == 1 || point == 2 || point == 3){
                    return 2;
                }
                else if(point == 4 || point == 5 && !cars[num].wasFine){
                    return 5;
                    if(cars[num].time >= cars[num].time + 1 days|| cars[num].time==0){
                        setFine(num);
                    }
                }
                else if(point == 7 && !cars[num].wasFine){
                    return 4;
                }
            }
        }
    }
    
    function die() public{
        selfdestruct(address(owner));
    }
}
