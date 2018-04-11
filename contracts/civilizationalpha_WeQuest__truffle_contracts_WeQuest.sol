pragma solidity ^0.4.2;

import "./mortal.sol";
import "./WeSource.sol";

contract WeQuest is mortal
{
    mapping (bytes32 => int256) public toId ;
    mapping (int256 => address) public toAddress;

    int256 public nresources;

    function WeQuest()
    {
      nresources = 0;
    }

    event NewWeSource(bytes32 _label);

    // check if resource exists. If so, send order to resource, otherwise it should first create the resource and then send an order to it.
    function request(bytes32 label, string lat, string lon) returns (bool success)
    {
        //bytes32 label = sha3(_label);
        int256 id = toId[label];
        if (id > 0x0)
        {
           WeSource res = WeSource(toAddress[id]);
           res.request(lat,lon);
        }
        else
        {
            nresources += 1;
            WeSource newres = new WeSource(label);
            newres.request(lat,lon);
            toAddress[nresources] = newres;
            toId[label] = nresources;
            NewWeSource(label);
        }
        return true;
    }

    // function listResources() returns (uint256[10] )
    // {
    //   uint256[10] ret ;
    //   for(uint256 i=0; i < 10; i++)
    //     {
    //         Resource res = Resource(toAddress[int256(i)]);
    //         ret[i]= res.norders;
    //     }
    //     return ret;
    // }


}
