contract SydEth {
		address owner;
		struct Certificate {
			uint timestamp;
			bytes issuerName;
			bytes courseName;
			bytes beneficiaryName;
			address beneficiaryAddress;
		}
		Certificate[] certificates;

		event Certification(bytes courseName, bytes beneficiaryName);

		function addCertificate(bytes _issuerName, bytes _courseName,
			bytes _beneficiaryName, address _beneficiaryAddress) public {
			certificates.push(Certificate(block.timestamp, _issuerName, _courseName, _beneficiaryName, _beneficiaryAddress));
			Certification(_courseName, _beneficiaryName);
		}

		function getLength() constant returns (uint length) {
			return certificates.length;
		}
		function findCertificate(bytes _beneficiaryName) constant returns (uint index) {
			for (uint i = 0; i < certificates.length; i++)
				if (stringsEqual(certificates[i].beneficiaryName, _beneficiaryName))
					return i+1;
			// can't return -1 because of uint
			// if I return int there are a lot of type casts to be made afterwards
			// e.g. when accessing an array, comparison, for loop
			return 0;
		}

		function getCertificate(uint index) constant returns (uint _timestamp, bytes _courseName, bytes _beneficiaryName, address _beneficiaryAddress, bytes _issuerName) {
			return (certificates[index-1].timestamp, certificates[index-1].courseName, certificates[index-1].beneficiaryName, certificates[index-1].beneficiaryAddress, certificates[index-1].issuerName);
		}

		function changeName(bytes _beneficiaryName, bytes _newName) public {
			uint index = findCertificate(_beneficiaryName) - 1;
			if (index > 0)
				if (certificates[index].beneficiaryAddress == msg.sender)
					certificates[index].beneficiaryName = _newName;
		}

		function stringsEqual(bytes storage _a, bytes memory _b) internal returns (bool) {
			bytes storage a = bytes(_a);
			bytes memory b = bytes(_b);
			if (a.length != b.length)
				return false;
			for (uint i = 0; i < a.length; i ++)
				if (a[i] != b[i])
					return false;
			return true;
		}
}
