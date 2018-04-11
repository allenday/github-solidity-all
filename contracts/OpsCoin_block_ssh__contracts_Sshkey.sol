pragma solidity ^0.4.7;

contract SshKey {
	string[] public sshPublicKeys;

	function SshKey() {
		owner = msg.sender;
	}

	function addSshKey(string sshkey) returns (bool) {
    sshPublicKeys.push(sshkey);
    return true;
  }
  // Its quite expensive to do the string compares and deletes, if we have a lot of concurrency we can reenable it
/*
  function removeSshKey(string sshkey) {
    var idx = indexOf(sshkey);
    remove(idx);
  }
*/
  function remove(uint index) {
      if (index >= sshPublicKeys.length || index < 0) return;

      for (uint i = index; i<sshPublicKeys.length-1; i++){
          sshPublicKeys[i] = sshPublicKeys[i+1];
      }
      delete sshPublicKeys[sshPublicKeys.length-1];
      sshPublicKeys.length--;
      return;
  }

  /* Define variable owner of the type address*/
  address owner;

  /* this function is executed at initialization and sets the owner of the contract */
  function mortal() { owner = msg.sender; }

  /* Function to recover the funds on the contract */
  function kill() { if (msg.sender == owner) selfdestruct(owner); }
}
