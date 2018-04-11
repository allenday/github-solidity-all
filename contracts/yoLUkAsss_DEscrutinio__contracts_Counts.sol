pragma solidity ^0.4.11;

contract Counts {


    bytes32[] candidates;
    bool created;
    
    struct TotalPorDistritoData {
        uint8[] total;
        mapping (uint => TotalPorEscuelaData) totalPorEscuela;
    }
    
    struct TotalPorEscuelaData {
        uint8[] total;
        mapping (uint => TotalPorMesaData) totalPorMesa;
    }
    
    struct TotalPorMesaData {
        uint8[] total;
    }

    uint8[] total;
    mapping (uint => TotalPorDistritoData) totalPorDistrito;

    function init(bytes32[] newCandidates) public {
        require(!created);
        candidates = newCandidates;
        created = true;
        for (uint8 i=0 ; i<candidates.length ; i++) {
            total.push(0);
        }
    }

    function getTotal() public constant returns(bytes32[], uint8[]) {
      return (candidates, total);
    }
    
    function setData(uint did, uint eid, uint mid, uint8[] co) public {

        // SE INDICA EL TOTAL DE UNA MESA
        totalPorDistrito[did].totalPorEscuela[eid].totalPorMesa[mid].total = co;
        uint8 i;
        uint8[] totalD = totalPorDistrito[did].total;
        if (totalD.length == 0) {
            for (i=0 ; i<candidates.length ; i++) {
                totalD.push(0);
            }
        }
        uint8[] totalE = totalPorDistrito[did].totalPorEscuela[eid].total;
        if (totalE.length == 0) {
            for (i=0 ; i<candidates.length ; i++) {
                totalE.push(0);
            }
        }

        for (i=0 ; i<candidates.length ; i++) {

            // ACTUALIZO TOTAL DE LA ESCUELA
            totalD[i] += co[i];

            // ACTUALIZO EL TOTAL DEL DISTRITO
            totalE[i] += co[i];

            // ACTUALIZO EL TOTAL DE LA ELECCION
            total[i] += co[i];
        }

        totalPorDistrito[did].total = totalD;
        totalPorDistrito[did].totalPorEscuela[eid].total = totalE;
    }
    
    function getByDistrict(uint did) public constant returns (bytes32[], uint8[]) {
        return (candidates, totalPorDistrito[did].total);
    }
    
    function getBySchool(uint did, uint eid) public constant returns (bytes32[], uint8[]) {
        return (candidates, totalPorDistrito[did].totalPorEscuela[eid].total);
    }
    
    function getByMesa(uint did, uint eid, uint mid) public constant returns (bytes32[], uint8[]) {
        return (candidates, totalPorDistrito[did].totalPorEscuela[eid].totalPorMesa[mid].total);
    }
}
