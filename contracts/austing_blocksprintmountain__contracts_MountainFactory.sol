import 'Mountain.sol';

contract MountainFactory {

    struct MountainContract {
        bytes32  contractName;
        address contractAddress;
    }

    mapping(address => MountainContract[]) public contractsByFounder;
    mapping(address => uint) public contractsByFounderLength;
    mapping(address => MountainContract[]) public contractsByMember;
    mapping(address => uint) public contractsByMemberLength;

    event MountainCreated (address mountain);

    function createContract (bytes32 contractName, uint multiplier, uint waitingWeeks, uint maxLoan) public {
        address founder = msg.sender;
        var mountain = new Mountain(contractName, multiplier, waitingWeeks, maxLoan, founder);
        contractsByFounder[msg.sender].push(MountainContract(
            contractName,
            mountain
        ));
        contractsByFounderLength[msg.sender] = contractsByFounderLength[msg.sender] + 1;
        mountain.addMember(msg.sender, 'Founder');
        addContractMember(msg.sender, contractName, mountain);
        MountainCreated(mountain);
    }

    function addContractMember (address who, bytes32 contractName, address contractAddress) public {
        contractsByMember[who].push(MountainContract(
            contractName,
            contractAddress
        ));
        contractsByMemberLength[msg.sender] = contractsByMemberLength[msg.sender] + 1;
    }

    function joinMountain(bytes32 name, address mountain) public {
        var m = Mountain(mountain);
        // Member who has been invited accepts invitation and
        // Becomes a member
        if(m.isAddressInvited(msg.sender) == true){
            m.addMember(msg.sender, name);
            var contractName = m.contractName();
            addContractMember(msg.sender, contractName, m);
        }
    }

}
