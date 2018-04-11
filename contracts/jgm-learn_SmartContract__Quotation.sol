pragma solidity ^0.4.5;
 
import "./User.sol";
 
contract Quotation
{
    struct data_st
    {
        uint        quo_date_;      //挂牌日期
        uint        quo_id_;        //挂牌编号
        uint        receipt_id_;    //仓单编号
        string      class_id_;      //品种代码
        string      make_date_;     //产期
        string      lev_id_;        //等级
        string      wh_id_;         //仓库代码
        string      place_id_;      //产地代码
        string      quo_type_;      //报价类型
        uint        price_;         //价格（代替浮点型）
        uint        quo_qty_;       //挂牌量
        uint        deal_qty_;      //成交量
        uint        rem_qty_;       //剩余量
        string      quo_deadline_;  //挂牌截止日
        uint        dlv_unit_;      //交割单位
        string      user_id_;       //用户id
        address     seller_addr_;   //卖方地址
        bool        state;          //是否存在
    }
    
    uint                        quo_id_ = 0; //挂牌编号从 1 开始
    mapping(uint => data_st)    data_map;   //挂牌编号 => 挂牌数据
    
    //输出行情 
    event   print_1( uint,uint,uint,string,string,string,string,string);
    event   print_2(string, uint,uint,uint,uint,string,uint, string );
    
    //打印错误信息
    event   error(string,string,string);
    
    //插入行情           
    function insertList1(uint receipt_id,
                        string  class_id, string  make_date,   
                        string  lev_id, string  wh_id, string  place_id)
    {
         quo_id_++;//挂牌编号
         
        data_map[quo_id_].quo_date_ = now;
        data_map[quo_id_].quo_id_ = quo_id_;
        data_map[quo_id_].receipt_id_ = receipt_id;
        data_map[quo_id_].class_id_ = class_id;
        data_map[quo_id_].make_date_ = make_date;
        data_map[quo_id_].lev_id_ = lev_id;
        data_map[quo_id_].wh_id_ = wh_id;
        data_map[quo_id_].place_id_ = place_id;
        data_map[quo_id_].quo_type_ = "一口价";
    }
    function insertList2(uint price, uint quo_qty, uint deal_qty,
                            uint rem_qty, string  quo_deadline, 
                            uint dlv_unit, string user_id ) returns(uint)
    {
        data_map[quo_id_].price_ = price;
        data_map[quo_id_].quo_qty_ = quo_qty;
        data_map[quo_id_].deal_qty_ = deal_qty;
        data_map[quo_id_].rem_qty_ = rem_qty;
        data_map[quo_id_].quo_deadline_ = quo_deadline;
        data_map[quo_id_].dlv_unit_ = dlv_unit;
        data_map[quo_id_].user_id_ = user_id;
        data_map[quo_id_].seller_addr_ = msg.sender;
        data_map[quo_id_].state = true;  
                  
        printQuotation();      
        
        return quo_id_;        
    }
    
    //打印行情
    function printQuotation()
    {
        print_1(
                data_map[quo_id_].quo_id_,
                data_map[quo_id_].quo_date_,
                data_map[quo_id_].receipt_id_, 
                data_map[quo_id_].ref_contract_,
                data_map[quo_id_].class_id_,
                data_map[quo_id_].make_date_,
                data_map[quo_id_].lev_id_,
                data_map[quo_id_].wh_id_,
                data_map[quo_id_].place_id_
            );
            
        print_2(
                data_map[quo_id_].quo_type_,
                data_map[quo_id_].price_,
                data_map[quo_id_].quo_qty_ ,
                data_map[quo_id_].deal_qty_,
                data_map[quo_id_].rem_qty_ ,
                data_map[quo_id_].quo_deadline_,
                data_map[quo_id_].dlv_unit_,
                data_map[quo_id_].user_id_
                );
    }
  
  
    //摘牌
    function delList(string user_id, uint quo_id, uint deal_qty) returns(uint)
    {
        if(deal_qty > data_map[quo_id].rem_qty_ )
        {
            error("delist():仓单剩余量不足，摘牌出错","错误代码：","-1");
            return uint(-1);
        }
        
        //更新成交量，剩余量
        data_map[quo_id].deal_qty_  =   deal_qty ;
        data_map[quo_id].rem_qty_   -=  deal_qty ;
        
        //更新卖方挂牌请求
        User user_sell = User(data_map[quo_id].seller_addr_);
        user_sell.updateListReq(quo_id, deal_qty);
        
        //创建卖方合同
        uint con_id_tmp = user_sell.dealSellContract(data_map[quo_id].receipt_id_, "卖",  data_map[quo_id].price_, deal_qty, user_id);
        //创建买方合同
        User user_buy = User(msg.sender);
        user_buy.dealBuyContract(con_id_tmp,data_map[quo_id].receipt_id_, "买",  data_map[quo_id].price_, deal_qty, data_map[quo_id].user_id_);
        
        //仓单全部成交，删除该条行情
        if(data_map[quo_id].rem_qty_ == 0 )
            delete data_map[quo_id];
            
        //打印行情
        printQuotation();
        
        return 0;
        
        
    }
    
}
