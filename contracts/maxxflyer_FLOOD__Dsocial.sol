pragma solidity ^0.4.2;
contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract Companion{
address owner;
mapping(address => bool)public TOS; 
function Companion(){owner=msg.sender;}
function acceptTOS(address a,bool b){if(msg.sender==owner)TOS[a]=b;}
}

//controller manager - contiene gli hypercoin accettati senza coinvolgere la privacy
contract ControllerManager{
address[] controllers;
mapping(address => bool)public controllersCheck;
function ControllerManager(){}
function getController(uint contr)constant returns(address){address temp=0x0;if(controllersCheck[controllers[contr]])temp=controllers[contr];return temp;}
function addController(address a,bool b){if(b)controllers.push(a);controllersCheck[a]=b;}
}

contract Dapp{address public owner;}

//10 social disclaimer
contract etherscapeCommunity{
address public owner;
string name;
DSocial dSocial;
bool addAddressListItemSet;
function etherscapeCommunity(DSocial ds){
dSocial=DSocial(ds);
addAddressListItemSet=false;
}

function subscribeIndividual(bool b){
if(b)if(!dSocial.addInfo("0x6fa7f18EBB2ed2F0DF5e6d921B4D4F6aB8276726",msg.sender,0,"wallet"))throw;
if(!dSocial.addCheck("0x6fa7f18EBB2ed2F0DF5e6d921B4D4F6aB8276726",msg.sender,0,b))throw;
}


}

contract miniDapp{
address public owner;
string name;
DSocial dSocial;
bool addAddressListItemSet;
function miniDapp(DSocial ds){
dSocial=DSocial(ds);
addAddressListItemSet=false;
}

function addAddressListItem(uint index,address addr2){
if(!addAddressListItemSet)throw;
if(!dSocial.addAddressListItem(this,this,uint index,address addr2))throw;
}

function setaddAddressListItemSet(bool b){
if(msg.sender!owner)throw;
addAddressListItemSet=b;
}
}

contract Dapp{address public owner;}

//10 social disclaimer
contract Dsocial{
address public owner;
Dapp dapp;
address public controller;
uint public records;

mapping(address => mapping(uint => string))public socialInfo;
mapping(uint => string)public infoLabels;

mapping(address => mapping(uint => uint))public socialQuantity; 
mapping(uint => string)public quantityLabels;

mapping(address => mapping(uint => bool))public socialCheck;
mapping(uint => string)public boolLabels;

mapping(address => mapping(uint => address))public socialAddress;
mapping(uint => string)public addressLabels;

mapping(address => mapping(uint => string[]))public socialInfoList;
mapping(uint => string[])public infoListLabels;

mapping(address => mapping(uint => uint[]))public socialQuantityList; 
mapping(uint => string[])public quantityListLabels;

mapping(address => mapping(uint => bool[]))public socialCheckList;
mapping(uint => string[])public boolListLabels;

mapping(address => mapping(uint => address[]))public socialAddressList;
mapping(uint => string[])public addressListLabels;

mapping(address => mapping(uint => string[]))public privateInfoList;
mapping(uint => string[])public privateinfoListLabels;

mapping(address => mapping(uint => uint[]))public privateQuantityList; 
mapping(uint => string[])public privatequantityListLabels;

mapping(address => mapping(uint => bool[]))public privateCheckList;
mapping(uint => string[])public privateboolListLabels;

mapping(address => mapping(uint => address[]))public privateAddressList;
mapping(uint => string[])public privateaddressListLabels;

mapping(address => address[])public permissions;
mapping(address => mapping(address => bool))public allowed;

function Dsocial(){
owner=msg.sender;
records=0;

}

function init(){
setLabel(101,0,0,"type");
setLabel(101,1,0,"name");
setLabel(101,2,0,"address");
setLabel(101,3,0,"manager");
setLabel(101,4,0,"manager");
setLabel(101,5,0,"manager");
setLabel(101,6,0,"manager");
setLabel(101,7,0,"manager");
setLabel(101,8,0,"manager");



setLabel(102,0,0,"etherscape community");
}

function addInfo(address d,address addr,uint index,string info){
dapp=Dapp(d);
if((msg.sender!=addr)&&(msg.sender!=dapp.owner())&&(msg.sender!=controller)&&(!allowed[addr][msg.sender]))throw;
socialInfo[addr][index]=info;
records++;
}

function addQuantity(address d,address addr,uint index,uint quant){
dapp=Dapp(d);
if((msg.sender!=addr)&&(msg.sender!=dapp.owner())&&(msg.sender!=controller)&&(!allowed[addr][msg.sender]))throw;
socialQuantity[addr][index]=quant;
records++;
}

function addCheck(address d,address addr,uint index,bool check){
dapp=Dapp(d);
if((msg.sender!=addr)&&(msg.sender!=dapp.owner())&&(msg.sender!=controller)&&(!allowed[addr][msg.sender]))throw;
socialCheck[addr][index]=check;
records++;
}

function addAddress(address d,address addr,uint index,address addr2){
dapp=Dapp(d);
if((msg.sender!=addr)&&(msg.sender!=dapp.owner())&&(msg.sender!=controller)&&(!allowed[addr][msg.sender]))throw;
socialAddress[addr][index]=addr2;
records++;
}

function addInfoListItem(bool social,address d,address addr,uint index,string info){
dapp=Dapp(d);
if((msg.sender!=addr)&&(msg.sender!=dapp.owner())&&(msg.sender!=controller)&&(!allowed[addr][msg.sender]))throw;
if(social){socialInfoList[addr][index].push(info);
}else{
privateInfoList[addr][index].push(info);}
records++;
}

function addBoolListItem(bool social,address d,address addr,uint index,bool check){
dapp=Dapp(d);
if((msg.sender!=addr)&&(msg.sender!=dapp.owner())&&(msg.sender!=controller)&&(!allowed[addr][msg.sender]))throw;
if(social){socialCheckList[addr][index].push(check);
}else{
privateCheckList[addr][index].push(check);}
records++;
}

function addAddressListItem(bool social,address d,address addr,uint index,address addr2){
dapp=Dapp(d);
if((msg.sender!=addr)&&(msg.sender!=dapp.owner())&&(msg.sender!=controller)&&(!allowed[addr][msg.sender]))throw;
if(social){socialAddressList[addr][index].push(addr2);
}else{
privateAddressList[addr][index].push(addr2);}
records++;
}

function addQuantityListItem(bool social,address d,address addr,uint index,uint u){
dapp=Dapp(d);
if((msg.sender!=addr)&&(msg.sender!=dapp.owner())&&(msg.sender!=controller)&&(!allowed[addr][msg.sender]))throw;
if(social){socialQuantityList[addr][index].push(u);
}else{
privateQuantityList[addr][index].push(u);}
records++;
}

function readInfo(address addr,uint index)constant returns (string,string){
return (socialInfo[addr][index],infoLabels[index]);
}

function readQuantity(address addr,uint index)constant returns (uint,string){
return (socialQuantity[addr][index],quantityLabels[index]);
}

function readCheck(address addr,uint index)constant returns (bool,string){
return (socialCheck[addr][index],boolLabels[index]);
}

function readAddress(address addr,uint index)constant returns (bool,string){
return (socialAddress[addr][index],addressLabels[index]);
}

function readInfoList(address addr,uint index,uint item)constant returns (string,string,uint){
return (socialInfoList[addr][index][item],infoListLabels[index][item],socialInfoList[addr][index].length);
}

function readQuantityList(address addr,uint index,uint item)constant returns (uint,string,uint){
return (socialQuantityList[addr][index][item],quantityListLabels[index][item],socialQuantityList[addr][index].length);
}

function readCheckList(address addr,uint index,uint item)constant returns (bool,string,uint){
return (socialCheckList[addr][index][item],boolListLabels[index][item],socialCheckList[addr][index].length);
}

function readAddressList(address addr,uint index,uint item)constant returns (bool,string,uint){
return (socialAddressList[addr][index][item],addressListLabels[index][item],socialAddressList[addr][index].length);
}


function allow(address a,bool b)returns (bool){
if(b){
permissions[msg.sender].push(a);
allowed[msg.sender][a]=true;
}else{
for uint i=0;i<permissions[msg.sender].length;i++){
//find and remove address
if(permissions[msg.sender][i]==a){if(i<permissions[msg.sender].length-1){
permissions[msg.sender][i]=permissions[msg.sender][permissions[msg.sender].length-1];
permissions[msg.sender][permissions[msg.sender].length-1]="0x00000000000000000000000000000000000";
}else{permissions[msg.sender][i]="0x00000000000000000000000000000000000";}
permissions[a].length--;
}
}
allowed[msg.sender][a]=false;
}
return bool;
}

function readPermissions(address a,uint u)constant returns (address,uint){
return (permissions[a][u],permissions[a].length);
}
