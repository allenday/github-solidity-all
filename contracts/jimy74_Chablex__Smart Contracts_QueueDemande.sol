pragma solidity ^0.4.2;

/*
   Initially from : https://github.com/chriseth/solidity-examples/blob/master/queue.sol
   Changed by: Jimmy Paris
   Changed to be a queue of Demande (as a record of the asker's address and the asked value)
*/


contract QueueDemande
{
    struct Demande{
      address demandeur;
      uint256 valeur;
    }

    struct Queue {
        Demande[] data;
        uint256 front;
        uint256 back;
    }


    /// @dev the number of elements stored in the queue
    function length(Queue storage q) constant internal returns (uint256) {
        return q.back - q.front;
    }

    /// @dev the number of elements this queue can hold
    function capacity(Queue storage q) constant internal returns (uint256) {
        return q.data.length - 1;
    }
    /// @dev push a new element to the back of the queue
    function push(Queue storage q,  Demande dem) internal
    {
        if ((q.back + 1) % q.data.length == q.front)
            return; // throw;
        q.data[q.back] = dem;
        q.back = (q.back + 1) % q.data.length;
    }

    /// @dev put a new element to the front of the queue
    function replaceInFront(Queue storage q,  Demande dem) internal
    {
        if (q.back == q.front)
            return; // throw;
        q.data[q.front] = dem;
    }

    /// @dev remove and return the element at the front of the queue
    function pop(Queue storage q) internal returns (Demande dem)
    {
        if (q.back == q.front)
            return; // throw;
        dem = q.data[q.front];
        delete q.data[q.front];
        q.front = (q.front + 1) % q.data.length;
    }

	/// @dev copy and return the element at the front of the queue
    function copyPop(Queue storage q) internal returns (Demande dem)
    {
        if (q.back == q.front)
            return; // throw;
        dem = q.data[q.front];
    }

    function containMinValueFromOther(Queue storage q, uint256 _minValue, address exceptAddr) internal returns (bool){
        uint256 valeurComptee = 0;
        uint256 i = q.front;
    		while(i < q.front + length(q) && valeurComptee < _minValue){
          if (exceptAddr == q.data[i].demandeur) return false;
    			valeurComptee += q.data[i].valeur;
    			i++;
    		}
  		  return valeurComptee >= _minValue;
    }

    function getTotalValue(Queue storage q) internal returns (uint256){
        uint256 valeurComptee = 0;
        uint256 i = q.front;
    		while(i < q.front + length(q)){
    			valeurComptee += q.data[i].valeur;
    			i++;
    		}
		return valeurComptee;
    }

    /// @dev remove and return the element at the front of the queue
    function get(Queue storage q, uint pos) internal returns (Demande dem)
    {
        if (pos >= length(q))
            return; // throw;
        dem = q.data[q.front + pos];
    }

}

contract QueueDemandesEnCours is QueueDemande {

    Queue requests;

    function QueueDemandesEnCours() {
        requests.data.length = 200;
    }
    function addRequest(address demandeur, uint256 valeur) {
        push(requests, Demande(demandeur,valeur));
    }
    function replaceInFrontRequest(address demandeur, uint256 valeur) {
        replaceInFront(requests, Demande(demandeur,valeur));
    }
    function popRequest() returns (address, uint256) {
        var d = pop(requests);
        return (d.demandeur,d.valeur);
    }
    function copyPopRequest() returns (address, uint256) {
        var d = copyPop(requests);
        return (d.demandeur,d.valeur);
    }
    function queueLength() returns (uint256) {
        return length(requests);
    }
    function get(uint256 pos) returns (address, uint256) {
        var d = get(requests, pos);
        return (d.demandeur,d.valeur);
    }

	  /// @dev check if a minimum value is asked in the queue, return false if it's asked by a specific address
    function containMinValueFromOther(uint256 _minValue, address exceptAddr) returns (bool)
    {
        return containMinValueFromOther(requests, _minValue, exceptAddr);

    }

    //Get the total of the asked value in the queue
   function getTotalValue() returns (uint256)
   {
       return getTotalValue(requests);

   }
}
