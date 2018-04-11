contract Payout {
     address Victor;
     address Jim;
     address Kieren;

     mapping (address => uint) ownershipDistribution; 

     function Setup() {
       Victor = 0xaabb;
       Jim    = 0xccdd;
       Kieren = 0xeeff;

       ownershipDistribution[Victor] = 35;
       ownershipDistribution[Jim]  = 35;
       ownershipDistribution[Kieren] = 30;
     }

     function Dividend() {
       uint bal= this.balance;
       Victor.send(bal * ownershipDistribution[Victor] / 100); 
       Jim.send(bal * ownershipDistribution[Jim] / 100);
       Kieren.send(bal * ownershipDistribution[Kieren] / 100);
     }
}
