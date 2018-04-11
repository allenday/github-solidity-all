contract MultiplyContract{
    address public fixed_side;
    address public floated_side;
    uint public price;
    uint public expired_date;
    uint public fixed_rate;
    uint public spread;
    function MultiplyContract(
      address _fixed_side,
      address _floated_side,
      uint _price,
      uint _expired_date,
      uint _fixed_rate,
      uint _spread
      ){
      fixed_side = _fixed_side;
      floated_side = _floated_side;
      price = _price;
      expired_date = _expired_date;
      fixed_rate = _fixed_rate;
      spread = _spread;
    }
    function () {
      throw;
    }
}
