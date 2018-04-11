import 'interface/AirTrafficControllerInterface.sol';
import 'creator/CreatorToken.sol';
import 'market/Market.sol';

contract AirTrafficController is AirTrafficControllerInterface {
    /* Route controller token price */
    uint public routePrice = 100;

    function setRoutePrice(uint _price) onlyOwner
    { routePrice = _price; }

    uint constant routeCount = 10;

    Market public market;
    Token  public credits;

    function AirTrafficController(string  _name,
                                  address[] _area,
                                  address _market,
                                  address _credits) {
        name    = _name;
        // Copy area polygon
        for (uint32 ix = 0; ix < _area.length; ix +=1)
            area.push(SatFix(_area[ix]));

        market  = Market(_market);
        credits = Token(_credits);
        token   = CreatorToken.create("ATC Ticket", "ATC", 0, routeCount);
        for (uint32 i = 0; i < routeCount; i += 1)
            placeToken();
    }

    function placeToken() internal {
        var lot = market.append(this, token, credits, 1, routePrice);
        token.approve(lot, 1);
    }

    function pay(address _drone) returns (bool) {
        /* Check payer balance */
        if (!token.transferFrom(_drone, this, 1)) throw;
        
        /* Register address as payed for ROS interface */
        isPaid[_drone] = true;
        return true;
    }
    
    function release(address _drone) {
        /* ROS interface signal about released route */
        if (msg.sender != address(getROSInterface)) throw;

        /* Unregister released address from payed */
        isPaid[_drone] = false;

        /* Place lot on market */
        placeToken();
    }
}
