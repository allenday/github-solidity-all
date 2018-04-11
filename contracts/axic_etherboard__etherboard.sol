//
// A contract inspired by Etherboard.io, combining a Ponzi-scheme with the MillionDollarHomepage.com
//
// This is of educational purpose, to think about how such a "scheme" can be written.
// It is based on the public ABI the Etherboard author has published and doesn't account for other internal features.
//
// The price rules are set out as follows:
// - You can buy any unowned pixel for 5 finney or more.
// - You can buy an already owned pixel for 110% or more than the price the current owner paid.
// - If someone buys your pixel, you get sent 99% of the price they paid for it.
// - You can change a pixel you own for 1% of its value.
//
// NOTE: I didn't actually run this on the real network, but it compiles and looks kind of OK
//
contract Etherboard {
  struct Line {
    address[1000] owners;
    uint[1000] colors;
    // Prices are stored with two extra decimal places to imitate floating point
    uint[1000] prices;
  }

  Line[1000] lines;

  function setPixelBlock(uint[] x, uint[] y, uint[] color, uint[] price) {
    // Supplied arrays must be of matching length
    uint length = x.length;
    if ((length != y.length) ||
        (length != color.length) ||
        (length != price.length))
      throw;

    // Validate requirements first
    uint totalCost = 0;
    for (uint i = 0; i < length; i++) {
      uint _x = x[i];
      uint _y = y[i];
      uint _c = color[i];
      uint _p = price[i];

      // Sanity check
      if ((_y >= 1000) || (_x >= 1000))
        throw;

      // Check if the values add up and are within the requirements
      Line line = lines[_y];
      address owner = line.owners[_x];
      uint minimum;
      if (owner == 0)
        minimum = 5 finney * 100;
      else if (owner == msg.sender)
        minimum = line.prices[_x] / 100; // 1% if you own it
      else
        minimum = line.prices[_x] + (line.prices[_x] / 10); // 110% if you don't

      if ((_p * 100) < minimum)
        throw;

      totalCost += minimum;
    }

    // Didn't send enough Ether
    if ((totalCost / 100) < msg.value)
      throw;

    // Process the changes and refunds
    for (i = 0; i < length; i++) {
      // FIXME: Solidity is a bit strange and says these variables were declared before (in the above for-scope)
      _x = x[i];
      _y = y[i];
      _c = color[i];
      _p = price[i] * 100;

      line = lines[_y];

      // Process refund (99% of new price)
      owner = line.owners[_x];
      if ((owner != 0) && (owner != msg.sender))
        owner.send(_p - (_p / 100));

      // Apply the actual changes
      line.owners[_x] = msg.sender;
      line.colors[_x] = _c;

      // Only update price if it's not already an owner
      if (owner != msg.sender)
        line.prices[_x] = _p;
    }
  }

  function getPixel(uint x, uint y) returns (address, uint, uint) {
    if ((x >= 1000) || (y >= 1000))
      throw;
    Line tmp = lines[y];
    return (tmp.owners[x], tmp.colors[x], tmp.prices[x]);
  }

  function getRow(uint y) returns (address[1000], uint[1000], uint[1000]) {
    if (y >= 1000)
      throw;
    Line tmp = lines[y];
    return (tmp.owners, tmp.colors, tmp.prices);
  }
}
