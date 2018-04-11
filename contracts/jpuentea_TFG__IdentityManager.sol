pragma solidity ^0.4.4;


contract IdentityManager{

    //nombre pasado al constructor.
    bytes32 public name;

    //direccion del creador del contrato.
    address public direction;

    //Arrays donde se guardan todos los usuarios y aplicaciones registrados.
    bytes32[] Allusers;
    bytes32[] Allapps;
   
    //Struct que identifica a un usuario.
    struct User{
        bytes32 nombre;
        address direccion;
        bytes32[] roles;
        address[] aplicacionesaddr;
    }

    //Struct que identifica a una aplicación.
    struct App{
        bytes32 nombre;
        address direccion;
        bytes32[] roles;
    }
    
    //Struct que almacena el rol, el token (hash) y la aplicación en la que se podrá registrar un usuario
    struct Controlador{
        address direccionApp;
        bytes32 hash;
        bytes32 rol;
    }
      
    //almacén donde se encuentran todos los usuarios registrados.
    mapping(address => User) public users;
    
    //almacén donde se encuentran las app registradas.
    mapping(bytes32 => App) public apps;
    
    //almacén donde se relacionan los nombres de usuario con sus direcciones.
    mapping(bytes32 => address) public relacionUsuarios;

    //almacén donde se relacionan las direcciones de las aps con los nombres.
    mapping(address => bytes32) public relacionApps;
    
    //almacén donde se guarda cada usuario con la información que tiene que usar para registrarse.
    mapping(address => Controlador) public controlador;
    
    
    //Constructor
    function IdentityManager(bytes32 _name){
        name = _name;
        direction = msg.sender;
    }
    

    //eventos
    event NewUser(address key);   
    event WrongRole(string mensaje);
    event Result(bytes32 result);
    event Resultado ( bool a);
    event Array(bytes32[] array);
    event ArrayAddr(address[] array);
    event Resultstring(string);
    event MalNombreApp(string);

   
     //funcion a la que se llama cuando se registra un usuario, se indica el nombre de usuario, la aplicación en la que se registra y el token.
    function registrarUsuario(bytes32 rol1, bytes32 nickname, bytes32 aplicacion, bytes32 token) {
        if(users[msg.sender].nombre != ""){
            if(users[msg.sender].nombre != nickname ){
            Resultstring("su nombre de usuario no es correcto");
            return;
            }
        }
        address vbladdr = devuelveAppaddr(aplicacion);
        if((controlador[msg.sender].hash == token)&&(vbladdr == controlador[msg.sender].direccionApp)&&(rol1 == controlador[msg.sender].rol)){
             //address vbladdr = apps[aplicacion].direccion;

        if( apps[aplicacion].nombre != ""){
            bool noRegistrado = true;
            for(uint a = 0; a < users[msg.sender].aplicacionesaddr.length; a++){
                if(users[msg.sender].aplicacionesaddr[a] == vbladdr){
                    noRegistrado = false;
                }
                
            }
            if(noRegistrado){
                relacionUsuarios[nickname] = msg.sender;
            for(uint i = 0; i< apps[aplicacion].roles.length; i++){

                if(apps[aplicacion].roles[i] == rol1){
                    
                    bytes32[] rolesAux = users[msg.sender].roles;
                    rolesAux.push(rol1);
                    address[] aplicacionesAux = users[msg.sender].aplicacionesaddr;
                    aplicacionesAux.push(vbladdr);
                    users[msg.sender] = User({nombre:nickname, direccion:msg.sender, roles:rolesAux, aplicacionesaddr : aplicacionesAux});
                   
                    Result(users[msg.sender].roles[users[msg.sender].roles.length - 1]);
                     NewUser(users[msg.sender].aplicacionesaddr[users[msg.sender].aplicacionesaddr.length - 1]);
                     bool esta = false;
                     for(uint p = 0; p< Allusers.length; p++){
                        if(Allusers[p]==nickname){
                            esta = true;
                        }
                     
                     }
                     if(!esta){
                        Allusers.push(nickname);


                     }
                     
                }else if (i == (apps[aplicacion].roles.length - 1) ){  
                    WrongRole("El rol introducido no es valido");
                }

            }
            }else{
                Result("Ya está registrado en esa app");
            }
           
         }else{throw;}
    
            
        }else{
            Result("Token malo");
        }
    }


    //variables necesarias eliminar un registro de un usuario en una aplicación.
    address[] almacenApps;
    address[] almacenApps1;
    bytes32[] almacenRoles;
    bytes32[] almacenRoles1;

    //función que permite eliminar un registro de un usuario en una aplicación.
    function borrarRegistro(bytes32 nickname,bytes32 aplicacion){
        
        address vbladdr = devuelveAppaddr(aplicacion);
        for(uint a = 0; a < users[msg.sender].aplicacionesaddr.length; a++){
                if(users[msg.sender].aplicacionesaddr[a] != vbladdr){
                    almacenApps.push(users[msg.sender].aplicacionesaddr[a]);
                    almacenRoles.push(users[msg.sender].roles[a]);
                }
            }
        users[msg.sender].aplicacionesaddr = almacenApps;
        users[msg.sender].roles = almacenRoles;
        almacenApps = almacenApps1;
        almacenRoles = almacenRoles1;
        
       
      }

    //función que permite registrar una aplicación en el gestor.  
    function registrarApp(bytes32 aplicacion,address a, bytes32[] b) {
        if(apps[aplicacion].nombre ==""){
        apps[aplicacion] = App({nombre:aplicacion, direccion:a, roles:b});
        relacionApps[a] = aplicacion;
        Result("App registrada correctamente");
        Allapps.push(aplicacion);
                
        }else{
            MalNombreApp("debe registrar su aplicación con otro nombre");
        }
     
    }

    //función que devuelve todos los usuarios registrados
    function  devuelveUsers() returns(bytes32[]){
        return Allusers;
    }

    //función que devuelve todas las apps registradas
    function  devuelveTodasApps() returns(bytes32[]){
        return Allapps;
    }

    //función que devuelve una dirección de una aplicación de la que se conoce su nombre.
    function devuelveAppaddr(bytes32 aplicacion) returns (address){
       return apps[aplicacion].direccion;
    }

    //función que devuelve los roles posibles de una aplicación.
    function devuelveApproles(bytes32 aplicacion) returns (bytes32[]){
       return apps[aplicacion].roles;
    }

    //función que permite comprobar si un usuario tiene un rol determinado.
    function comprueba(address a, bytes32 rol) returns (bool isRegistered){

        for(uint i = 0; i< users[a].aplicacionesaddr.length; i++){
            if(users[a].aplicacionesaddr[i] == msg.sender){
                if(users[a].roles[i] == rol){
                    isRegistered = true;
                    Resultado(isRegistered);
                    return isRegistered;
                  
                }else{
                    isRegistered = false;
                    Resultado(isRegistered);
                    return isRegistered;
                    
                }
                
            }else{
                isRegistered == false;
            }
            
       }
       Resultado(isRegistered);
            return isRegistered;
    }

    //función que usan las aplicaciones para indicar el token de un usuario y el rol en el que se pueden registrar.
     function controla(address user, bytes32 hash, bytes32 rol){
     controlador[user].hash = hash;
     controlador[user].direccionApp = msg.sender;
     controlador[user].rol = rol;
     Result("Token de Usuario registrado");
    }
    
    //función que devuelve los roles de un usuario
    function devuelveRoles(bytes32 user) returns (bytes32[] rolesuser){
        address usuario = relacionUsuarios[user];
        if(msg.sender != usuario){
        Resultstring("Info privada");
        return;
        }
        rolesuser = users[usuario].roles;
        Array(rolesuser);
        return rolesuser;
    }

    //función que devuelve las aplicaciones donde se ha registrado un usuario.
    function devuelveApps(bytes32 user) returns (address[] appsuser){
        address usuario = relacionUsuarios[user];
        if(msg.sender != usuario){
        Resultstring("Info privada");
        return;
        }
        appsuser = users[usuario].aplicacionesaddr;
        ArrayAddr(appsuser);
        return appsuser;
     }

     //función que devuelve la dirección de un usuario del que se conoce el nombre.
    function devuelveAddressUsuario(bytes32 user) returns (address){
     return relacionUsuarios[user];
    }

    //función que devuelve el nombre de una aplicación de la que se conoce su dirección.
    function devuelveNombreApp(address app) returns (bytes32){
     return relacionApps[app];
    }
 
   
  
    
   
    
    
}
