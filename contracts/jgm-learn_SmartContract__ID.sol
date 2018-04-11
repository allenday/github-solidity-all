pragma solidity ^0.4.5;



contract CreateID
{
    string      user_id_;       //客户id
    uint        receipt_id_;    //仓单id
    uint        con_id_;        //合同id
    uint        neg_id_;        //协商id
    
    //创建合同id
    function getConID() returns(uint )
    {
        return ++con_id_;
    }
    
    //创建协商交易编号
    function getNegID() returns(uint )
    {
        return  ++neg_id_;
    }
}
