
pragma solidity ^0.4.4;

contract IdentityManager{
   
    function comprueba(address a, bytes32 rol) returns (bool isRegistered){
     a = 0x00;
     rol = "a";
    return true;
    }
    function controla(address user, bytes32 hash,bytes32 rol){
     user = 0x0;
     hash = "";
     rol="";
 }

}


contract Votaciones{
    //nombre del usuario del gestor
    bytes32 public name;
    
    
   
    bytes32[] Allencuestas;
    address[] a;

    
    struct Votacion{
        bytes32 nombre;
        address[] yahanvotado;
        bytes32[] aspirantes;
        uint256[] puntuaciones;
        
      
    }
    mapping(bytes32 => Votacion) public votaciones;
    mapping(address => bytes32) public tokens;
    
    
    function Votaciones(bytes32 _name){
        name = _name;
       
    }
    event DevuelveBytes(bytes32);
    event DevuelveUint(uint256);
    event DevuelveAddr(address);
    event DevuelveArrayAddress(address[]);
 

    address addr = 0x950a13dc7a79187e519e6d7d5d5e1065fe9d35a2;
    IdentityManager identitymanager= IdentityManager(addr);
    
    
    /*function vota(bytes32 nombre,bytes32 aspirante){
    if(votaciones[nombre].yahanvotado.length == 0){
    votaciones[nombre].yahanvotado.push("0x0000000000000000000000000000000000000000");
    }    
    for(uint256 r = 0; r< votaciones[nombre].yahanvotado.length;r++){
    if(votaciones[nombre].yahanvotado[r] == msg.sender){
    throw;
    }else{

     for(uint256 i = 0; i< votaciones[nombre].aspirantes.length;i++){
         if(votaciones[nombre].aspirantes[i] == aspirante){
             uint256 aux = votaciones[nombre].puntuaciones[i];
             aux++;
             votaciones[nombre].puntuaciones[i] = aux;
             DevuelveUint(votaciones[nombre].puntuaciones[i]);
             address[] aux1 = votaciones[nombre].yahanvotado;
             aux1.push(msg.sender);
             votaciones[nombre].yahanvotado = aux1;
             //DevuelveAddr(votaciones[nombre].yahanvotado[votaciones[nombre].yahanvotado.length]);
             
         }
     }

    }

     }
    }*/

    function vota(bytes32 nombre,bytes32 aspirante){
   
    if(votaciones[nombre].yahanvotado.length == 0){
        votaciones[nombre].yahanvotado.push(0x0000);
        DevuelveUint(votaciones[nombre].yahanvotado.length);
        DevuelveAddr(votaciones[nombre].yahanvotado[0]);
    }
   
    for(uint256 r = 0; r< votaciones[nombre].yahanvotado.length;r++){
        if(votaciones[nombre].yahanvotado[r] == msg.sender){
            DevuelveUint(3000);
            return;
        }
    }  
     for(uint256 i = 0; i< votaciones[nombre].aspirantes.length;i++){
         if(votaciones[nombre].aspirantes[i] == aspirante){
             uint256 aux = votaciones[nombre].puntuaciones[i];
             aux++;
             votaciones[nombre].puntuaciones[i] = aux;
             DevuelveUint(votaciones[nombre].puntuaciones[i]);
             address[] aux1 = votaciones[nombre].yahanvotado;
             aux1.push(msg.sender);
             votaciones[nombre].yahanvotado = aux1;
             DevuelveArrayAddress(votaciones[nombre].yahanvotado);
             //DevuelveAddr(votaciones[nombre].yahanvotado[votaciones[nombre].yahanvotado.length]);
    
    }

     }
    }
    function createVotacion(bytes32 nombre, bytes32[] aspirantes, uint256[] puntuaciones){
        if(identitymanager.comprueba(msg.sender,"gerente")){
        
        
        votaciones[nombre] = Votacion({nombre:nombre,yahanvotado:a,aspirantes:aspirantes,puntuaciones:puntuaciones});
        Allencuestas.push(nombre);
        DevuelveBytes(votaciones[nombre].aspirantes[0]);
        DevuelveUint(votaciones[nombre].puntuaciones[0]);
        
        }
    }
    function eliminarVotacion(bytes32 nombre){
    	if(identitymanager.comprueba(msg.sender,"staff")){
        delete votaciones[nombre];
        }
    }

    function registraToken(bytes32 rol) returns (bytes32 a){
  
    a = sha3(block.timestamp,msg.sender);
    tokens[msg.sender] = a;
    DevuelveBytes(a);
    identitymanager.controla(msg.sender,a,rol);
    return a;
    }
  
    function  devuelveTodasEncuestas() returns(bytes32[]){
        return Allencuestas;
    }

    function devuelveToken() returns (bytes32 t ){
    t = tokens[msg.sender];
    tokens[msg.sender] = "0x0";
    return t;

    }
    
    function devuelveEncuestados(bytes32 encuesta) returns(bytes32[] encuestados){
        encuestados = votaciones[encuesta].aspirantes;
        return encuestados;

    }

    function devuelvePuntuaciones(bytes32 encuesta) returns(uint256[] values){
        values = votaciones[encuesta].puntuaciones;
        return values;

    }
   
}
 