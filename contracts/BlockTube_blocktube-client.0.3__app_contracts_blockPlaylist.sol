/// @title Blocktu.be playlist contract.

contract blockPlaylist {
    
	// Here we create an array named 'clips'. 
	// We will store ipfs hashes here.
    string[] public clips;
    address owner;
    string public playlistname;

    function blockPlaylist(string playlist) { 
    	owner = msg.sender; 
    	playlistname = playlist;
    }

    // Fire the event clipUploaded(clipobject)
    // so our bot/gui can listen to it
    event clipAdded(string ipfshash);

    // Add the ipfshash to the clipcollection
    function addClip(string ipfshash){
    	// If the upload is the owner of this playlist
    	if (msg.sender != owner)
    		throw;	
    	// push into clips array
    	clips.push(ipfshash);
    	// fire an event we can listen to
    	clipAdded(ipfshash);
    }
}