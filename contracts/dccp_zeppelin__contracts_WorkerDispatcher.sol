contract WorkerDispatcher {
    struct Worker {
        bytes32 name;
        bytes32 ip;
        uint maxLength;
        uint price;
        bool activeAgreement;
        uint dtport;
        uint port;
    }
    mapping (address => Worker) public workersInfo;
    uint public numWorkers;
    mapping (uint => address) public workerList;

    function buyContract(address worker, uint length)
                returns (address addr) {
        if (workersInfo[worker].name == "" &&
            workersInfo[worker].maxLength < length) return msg.sender;
        workersInfo[worker].activeAgreement = true;
        return worker;
    }

    function registerWorker(uint maxLength, uint price,
                            bytes32 name, bytes32 ip) {
        if (workersInfo[msg.sender].name == "") {
            workerList[numWorkers++] = msg.sender;
        }
        Worker w = workersInfo[msg.sender];
        w.name = name;
        w.ip = ip;
        w.maxLength = maxLength;
        w.price = price;
        w.activeAgreement = false;
        w.dtport = 0;
        w.port = 0;
    }

    function changeWorkerPrice(uint newPrice) {
        workersInfo[msg.sender].price = newPrice;
    }

    function setWorkerDtPort(uint _dtport) {
        if (workersInfo[msg.sender].activeAgreement) {
            workersInfo[msg.sender].dtport = _dtport;
        }
    }

    function setWorkerPort(uint _port) {
        if (workersInfo[msg.sender].activeAgreement) {
            workersInfo[msg.sender].port = _port;
        }
    }
}

