pragma solidity ^0.4.6;

import "./mortal.sol";

contract WeSource is mortal
{
    enum Status {Requested, Claimed, Completed}

    struct Request {
        address requester;
        uint8 amounts;
        string lat;
        string lon;
        uint status;
        uint creation;
        string IPFSMeta;
    }

    Request[] public requests;

    bytes32 public label;
    uint public nrequests; // Current demand of resource

    event NewRequest(bytes32 _label ,string lat,string lon);

    function WeSource(bytes32 _label)
    {
        nrequests = 0;
        label = _label;
    }

    function request(string lat, string lon)
    {
        var order = Request (msg.sender, 1 , lat, lon, 0 , now);
        nrequests += 1;
        requests.push(order);
        //Notify listeners
        NewRequest(label,lat,lon);
    }

    function bookrequest(uint id)
    {
      //Add escrow here!

      //Remove request from the active list
      requests[id] = requests[nrequests]; //Copy last item to position

      //WARNING: whatif someone sends a tender result for the same item at the same time is replaced?
      delete requests[nrequests]; //delete last item
      nrequests -= 1;
    }

    function getRequestInfo(uint id ) public constant returns (
      address requester,
      uint8 amounts,
      string lat,
      string lon,
      uint status,
      uint creation
    ){
      Request order = requests[ id ];
      requester = order.requester;
      amounts = order.amounts;
      lat = order.lat;
      lon = order.lon;
      status = order.status;
      creation = order.creation;

    }

    function getStatus(uint id)  constant returns (uint status) {
      Request order = requests[id];
      status = order.status;
      return;
    }

    function confirm(uint id)
    {
        Request order = requests[id];
        order.status = 2; //Status.completed;
        //Transfer agreed amount from requester to supplier
        //time.balanceOf[msg.sender] += order.amounts;
        //time.balanceOf[order.requester] -= order.amounts;
        //we.balanceOf[msg.sender ] += nrequest; //ADD current demand as tokens
        //ewe.balanceOf[order.requester] -= nrequests;
        //remove request from active list

    }
}
