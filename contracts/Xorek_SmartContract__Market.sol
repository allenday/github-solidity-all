pragma solidity ^0.4.5;
 
import "./User.sol";
import "./ID.sol";
 
contract  Market
{
    struct MarketData
    {
        uint        date_;      //挂牌日期
        uint        id_;        //挂牌编号
        uint        sheet_id_;    //仓单编号
        string      class_id_;      //品种代码
        string      make_date_;     //产期
        string      lev_id_;        //等级
        string      wh_id_;         //仓库代码
        string      place_id_;      //产地代码
        string      type_;      //报价类型
        uint        price_;         //价格（代替浮点型）
        uint        qty_;       //挂牌量
        uint        deal_qty_;      //成交量
        uint        rem_qty_;       //剩余量
        string      deadline_;  //挂牌截止日
        uint        dlv_unit_;      //交割单位
        string      user_id_;       //用户id
        address     seller_addr_;   //卖方地址
        bool        state;          //是否存在
    }
    
    //uint                        quo_id_ = 0; //挂牌编号从 1 开始
    CreateID                     id;
    uint                        market_id;
    mapping(uint => MarketData)    data_map;   //挂牌编号 => 挂牌数据
    
    //输出行情 
    event   print_1( uint,uint,uint,string,string,string,string,string);
    event   print_2(string, uint,uint,uint,uint,string,uint, string );
    
    //打印错误信息
    event   error(string,string,string);
    
    //插入行情           
    function insertList1(uint sheet_id,
                        string  class_id, string  make_date,   
                        string  lev_id, string  wh_id, string  place_id)
    {
        market_id = id.getMarketID();
         
        data_map[market_id].date_ = now;
        data_map[market_id].id_ = market_id;
        data_map[market_id].sheet_id_ = sheet_id;
        data_map[market_id].class_id_ = class_id;
        data_map[market_id].make_date_ = make_date;
        data_map[market_id].lev_id_ = lev_id;
        data_map[market_id].wh_id_ = wh_id;
        data_map[market_id].place_id_ = place_id;
        data_map[market_id].type_ = "一口价";
    }
    function insertList2(uint price, uint quo_qty, uint deal_qty,
                            uint rem_qty, string  quo_deadline, 
                            uint dlv_unit, string user_id ) returns(uint)
    {
        data_map[market_id].price_ = price;
        data_map[market_id].qty_ = quo_qty;
        data_map[market_id].deal_qty_ = deal_qty;
        data_map[market_id].rem_qty_ = rem_qty;
        data_map[market_id].deadline_ = quo_deadline;
        data_map[market_id].dlv_unit_ = dlv_unit;
        data_map[market_id].user_id_ = user_id;
        data_map[market_id].seller_addr_ = msg.sender;
        data_map[market_id].state = true;  
                  
        printMarket();      
        
        return market_id;        
    }
    
    //打印行情
    function printMarket()
    {
        print_1(
                data_map[market_id].id_,
                data_map[market_id].date_,
                data_map[market_id].sheet_id_, 
                //data_map[market_id].ref_contract_,
                data_map[market_id].class_id_,
                data_map[market_id].make_date_,
                data_map[market_id].lev_id_,
                data_map[market_id].wh_id_,
                data_map[market_id].place_id_
            );
            
        print_2(
                data_map[market_id].type_,
                data_map[market_id].price_,
                data_map[market_id].qty_ ,
                data_map[market_id].deal_qty_,
                data_map[market_id].rem_qty_ ,
                data_map[market_id].deadline_,
                data_map[market_id].dlv_unit_,
                data_map[market_id].user_id_
                );
    }
  
  
    //摘牌
    function delList(string user_id, uint market_id, uint deal_qty) returns(uint)
    {
        if(deal_qty > data_map[market_id].rem_qty_ )
        {
            error("delist():仓单剩余量不足，摘牌出错","错误代码：","-1");
            return uint(-1);
        }
        
        //更新成交量，剩余量
        data_map[market_id].deal_qty_  =   deal_qty ;
        data_map[market_id].rem_qty_   -=  deal_qty ;
        
        //更新卖方挂牌请求
        User user_sell = User(data_map[market_id].seller_addr_);
        user_sell.updateListReq(market_id, deal_qty);
        
        //创建卖方合同
        uint con_id_tmp = user_sell.dealSellContract(data_map[market_id].sheet_id_, "卖",  data_map[market_id].price_, deal_qty, user_id);
        //创建买方合同
        User user_buy = User(msg.sender);
        user_buy.dealBuyContract(con_id_tmp,data_map[market_id].sheet_id_, "买",  data_map[market_id].price_, deal_qty, data_map[market_id].user_id_);
        
        //仓单全部成交，删除该条行情
        if(data_map[market_id].rem_qty_ == 0 )
            delete data_map[market_id];
            
        //打印行情
        printMarket();
        
        return 0;
        
        
    }
    
}
