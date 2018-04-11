pragma solidity ^0.4.11;

/* Auteur : Jimmy Paris

   Versions pré GitHub :
        		10.09.2017 (Ajout d'une limite du total des demandes en cours fixée à 1/3 du totalSupply)
				PB6 : garantir que les demandes peuvent circulée et ne ce bloquent pas,
				      il ne faut que le total des demandes puisse demander une trop grande partie des tokens
			04.09.2017 (Ajout d'une durée minimum entre les augmentations du maxEmpruntable)
				P5 : [corrigé]
				Il risque d'emprunter dans le but de re-prêter directement et cela afin de très vite augmenter son maximum empruntable
			30.08.2017 (Prêter dans l'ordre des demandes FIFO)
			problèmes historiques :
					-P4 : [corrigé]
					  doit gérer la possibilité de prêter une partie seulement de la plus vieille demande en cours
					  actuelement, le prêt doit au moins être égale à la demande la plus vieille,
					  ce qui discrimine les petits prêteurs, mais aussi risque de retarder les gros prêteurs et voir même de bloquer le système,
					  dans le cas ou aucun prêteur ne peut prêter une telle somme!
					  pose aussi problème si l'on prête par exemple 6$ à A demandant 4$ et B demandant 3$
					  -> [solution possible mais abandonnée] :
					     faire le prêt que si on a au moins de quoi traiter la première demande
					     exemple : require(_value >= demandesEnCours.copyPopRequest().valeur); // Risque de bloquer le système
					  -> [solution retenue] :
					     permettre les prêts partiels et de répondre à un gros emprunt même si un seul participant ne possède pas à lui seul la somme nécessaire.
					-P3 : [corrigé]
					  doit gérer le fait qu'il y ait assez dans la pile (fait par une simple vérification dans peutPreter)
			29.08.2017 (Preter à qui on veut, sans la pile)
				problèmes historiques :

					-P2 : [corrigé]
					  si on laisse les membres choisir à qui ils veulent prêter, certains prêts seront peut être oubliés, igniorés ou jamais traités.
					  -> dans le cas ou les membres ne sont pas controlées et n'importe qui peut participer, ceci n'est pas un problème mais plutôt une solution d'auto-régulation et de marché de la confiance
					  -> mais dans le cas ou on a fait un vote pour admettre nos membres (comme ici) et qu'on ne veut pas de favoritisme dans la vitesse à laquelle on peut profiter d'un prêt, sachant que chacun possède déjà un maximum empruntable
					-P1 : [corrigé]
					  doit auditer les emprunts et les remboursements pour définir un maximum empruntable
*/

import './MintableToken.sol';
import './QueueDemande.sol';

contract ChabToken is MintableToken {


  event Demander(address indexed addr, uint value);
	event Preter(address indexed _to, uint256 _value);
	event PreterUnePartie(address indexed _to, uint256 _value);

  //Trois constantes pour les info. du token (standard ERC20)
  string public constant symbol = "CHT";
  string public constant name = "ChabToken";
  uint8 public constant decimals = 18;

  uint256 public constant initialEmpruntable = 500;   //  Utiliser comme maxEmpruntable lors de la première demande de prêt
  uint256 public constant facteurChangeMax = 2;   // Utiliser pour multiplier le max actuel et définir le nouveau max
  uint256 public constant tempsMinChangeMax = 30 days; //temps obligatoire entre les changements du maxEpruntable
  uint256 public constant minRatioCirculent = 3; // Fixe le maximum total des demandes en cours à 1 / ratio


  QueueDemandesEnCours demandesEnCours = new QueueDemandesEnCours();

  mapping (address => uint256) public demandes;   // Demandes d'emprunts (total)
  mapping (address => uint256) public emprunts;   // Emprunts passés (total)
  mapping (address => uint256) public remboursements;   // Remboursements ou prêts passés (total)
  mapping (address => uint256) private maxEmpruntable;   // Maximum empruntable
  mapping (address => uint256) public dateChangementMax; // Date du dernier changement du Max empruntable

    function getMaxEmpruntable(address addr) constant returns (uint){
	if (memberId[addr] == 0) // si ce n'est pas un membre
					return 0;
        return initialEmpruntable >= maxEmpruntable[addr] ? initialEmpruntable : maxEmpruntable[addr];
    }

		function getDemande(uint256 pos) constant returns (address, uint256){
				var (demandeur,valeur) = demandesEnCours.get(pos);
				return (demandeur,valeur);
    }

		function getNbDemandes() constant returns (uint256){
			return demandesEnCours.queueLength();
    }

    modifier peutDemander(uint256 _value) {

	require(_value >= 1); // La valeur demandée est au moins 1 token

	uint monMaxEmpruntable = getMaxEmpruntable(msg.sender);   // Définir le maximum empruntable ou sa valeur initiale

        require(_value <= monMaxEmpruntable);   // N'emprunte pas plus de tokens que le max

        require(demandes[msg.sender].add(_value) <= remboursements[msg.sender].add(monMaxEmpruntable));   // Le total des demandes + la demande ne dépasse pas le total des remboursements + le max

        require( (_value + demandesEnCours.getTotalValue()) * minRatioCirculent < totalSupply); // Le total demandé est inférieur à 1/ratio du nombre de tokens total

	_; // Indique où insérer le code de la fonction appelante
    }

    function demander(uint256 _value) public onlyAfterQ1 onlyMembers(msg.sender) peutDemander(_value) {

        demandes[msg.sender] = demandes[msg.sender].add(_value); // Augmente le total demandé

	demandesEnCours.addRequest(msg.sender, _value); // Ajoute la demande à la file d'attente

        Demander(msg.sender, _value);
    }


    modifier peutPreter(uint256 _value) {

        require(_value > 0); // La valeur prêtée est supérieure à 0 token

	require(balances[msg.sender] >= _value); // Le prêteur possède suffisamment

        // La valeur du prêt ne dépasse pas le total des demandes en cours, et les demandes complétées n'appartiennent pas au prêteur
	require(demandesEnCours.containMinValueFromOther(_value, msg.sender));

        _;
    }

    // La fonction suivante est utilisée pour faire un prêt à la communauté,
    // cela sera comptabilisé comme un remboursement de n'importe lequel de vos prêt et augmentera votre maxEmpruntable.

    function preter(uint256 _value) public onlyAfterQ1 onlyMembers(msg.sender) peutPreter(_value){

			balances[msg.sender] = balances[msg.sender].sub(_value); // Déduit en amont la balance du prêteur

	    uint256 pretRestant = _value; // Initialise le montant qu'il reste à prêter

			while (demandesEnCours.queueLength() > 0 && pretRestant > 0){

				var (demandeur,valeur) = (demandesEnCours.copyPopRequest()); // Récupère la demande la plus vielle sans la désempiler (demandeur, valeur)

				if (pretRestant >= valeur){ // Si le prêt restant peut recouvrir cette demande intégralement

					  demandesEnCours.popRequest();

						emprunts[demandeur] = emprunts[demandeur].add(valeur);	//Augmente le total des emprunts du demandeur

						balances[demandeur] = balances[demandeur].add(valeur);	//Augmente la balance du demandeur

						remboursements[msg.sender] = remboursements[msg.sender].add(valeur); //Augmente le total des remboursements du prêteur

						pretRestant = pretRestant.sub(valeur); // Réduire la somme encore prêtable

						Preter(demandeur,valeur);
				}

				else { // Sinon, répondre partiellement à cette demande

	    			emprunts[demandeur] = emprunts[demandeur].add(pretRestant);

	    			balances[demandeur] = balances[demandeur].add(pretRestant);

	    			remboursements[msg.sender] = remboursements[msg.sender].add(pretRestant);

	    			demandesEnCours.replaceInFrontRequest(demandeur,valeur.sub(pretRestant)); // Réduit la valeur de cette demande mais la laisse dans la file d'attente

	    			PreterUnePartie(demandeur, pretRestant);

	    			pretRestant = 0; // Arrête la boucle car tout prêté
				}
			}

			if (remboursements[msg.sender] >= emprunts[msg.sender] //Si le prêteur a remboursé ses emprunts
			&& remboursements[msg.sender] >= getMaxEmpruntable(msg.sender) // Et est arrivé à son maximum
			&& now >= dateChangementMax[msg.sender].add(tempsMinChangeMax)) { // Et que sa dernière augmentation date de au moins 30 jours
			    dateChangementMax[msg.sender] = now;
					maxEmpruntable[msg.sender] = getMaxEmpruntable(msg.sender).mul(facteurChangeMax);	// Double le max empruntable lors du prochain emprunt
					// A noter que dans ce cas il peut aussi faire un nouvel emprunt (voir la première ligne du modifier peutDemander)
			}
    }

		//Seuls les membres peuvent envoyer ou recevoir ce token
		function transfer(address _to, uint256 _value) onlyAfterQ1 onlyMembers(msg.sender) onlyMembers(_to)  returns (bool) {
			return super.transfer(_to, _value);
		}

		function approve(address _spender, uint256 _value) onlyAfterQ1 onlyMembers(msg.sender) onlyMembers(_spender) returns (bool) {
			return super.approve(_spender,_value);
		}

		function transferFrom(address _from, address _to, uint256 _value) onlyAfterQ1 onlyMembers(_from) onlyMembers(_to)  returns (bool) {
			return super.transferFrom(_from,_to,_value);
		}

		function increaseApproval(address _spender, uint _addedValue) onlyAfterQ1 onlyMembers(msg.sender) onlyMembers(_spender)
		returns (bool success) {
			return super.increaseApproval(_spender,_addedValue);
		}
		function decreaseApproval (address _spender, uint _subtractedValue) onlyAfterQ1 onlyMembers(msg.sender) onlyMembers(_spender)
	  returns (bool success) {
			return super.decreaseApproval(_spender,_subtractedValue);
		}
}
