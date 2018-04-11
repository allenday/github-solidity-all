pragma solidity ^0.4.15;
//
// https://ethereum.github.io/browser-solidity/
// https://github.com/ethereum/ens/blob/master/contracts/ENS.sol
// 
import "./ENS.sol";
import "./FIFSRegistrar.sol";

contract TestRegistrar {
    bytes32 ensRootNode = 0x0;
    bytes32 public ethLabel = sha3('eth'); 
    bytes32 public ethNode = sha3(ensRootNode, ethLabel);
    bytes32 public swarmLabel = sha3('swarm');
    bytes32 public swarmNode = sha3(ethNode, swarmLabel);
    ENS public ens;
    FIFSRegistrar public registrar;
    
    function testEns(){
         ens = new ENS();
         // eth.root
         ens.setSubnodeOwner(ensRootNode, ethLabel, 0xdeed01);
         require(0xdeed01 == ens.owner(ethNode));
         // foo.root
         ens.setSubnodeOwner(ensRootNode, sha3('foo'), 0xdeed02);
         bytes32 fooNode = sha3(ensRootNode, sha3('foo'));
         require(0xdeed02 == ens.owner(fooNode));
    }
    
    function testEnsFail(){
         ens = new ENS();
         // eth.root
         ens.setSubnodeOwner(ensRootNode, ethLabel, 0xdeed01);
         require(0xdeed01 == ens.owner(ethNode));
         // foo.eth.root
         ens.setSubnodeOwner(ethNode,sha3('foo'), 0xdeed02);
         // ethNode's owner is 0xdeed01
         // contract.at.0xdeed01 invoke setSubnodeOwner() is ok
    }
    
    function initEnsRigistrar(){
        ens = new ENS();
        registrar = new FIFSRegistrar(ens, ethNode);
        ens.setSubnodeOwner(ensRootNode, ethLabel,registrar);
        require(registrar == ens.owner(ethNode));
    }
    
    function testRegisterSwarmEth(){
        initEnsRigistrar();
        registrar.register(swarmLabel,0xdeed);
        require(0xdeed == ens.owner(swarmNode));
    }
    
    function testRegisterNickWalletEth(){
        // wallet.eth
        initEnsRigistrar();
        bytes32 walletLabel = sha3('wallet');
        bytes32 walletNode = sha3(ethNode, walletLabel);
        FIFSRegistrar registrarWallet = new FIFSRegistrar(ens, walletNode);
        registrar.register(walletLabel, registrarWallet);
        require(registrarWallet == ens.owner(walletNode));
        
        // nick.wallet.eth
        bytes32 nickLabel = sha3('nick');
        registrarWallet.register(nickLabel,0xdeed);
        bytes32 nickWalletNode = sha3(walletNode, nickLabel);
        require(0xdeed == ens.owner(nickWalletNode));

    }
}