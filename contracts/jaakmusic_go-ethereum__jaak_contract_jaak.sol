/// @title jaak
/// @author zelig
import "mortal";

contract Jaak is mortal {

  function Jaak() {
    balances[owner] = msg.value;
  }

  uint constant JAAK_FRACTION = 84; // cut JAAK takes per listen in wei
  uint constant JAAKER_FRACTION = 336; // cut JAAK takes per listen in wei
  uint constant PLAY_PRICE = 4200; /// price per play in wei

  struct Track {
    uint playbackCount;
    address artistID;
    uint index;
    uint time;
  }


  // basic data structure - trackstore
  // index by artist (extendible, songs the artist ever was part of even unregistered ones)
  mapping (address => bytes32[]) artists;
  address[] public artistlist;

  mapping (bytes32 => Track) public tracks;
  bytes32[] public tracklist;


  // user balances
  mapping (address => uint) public balances;

  /// @notice accessor for track listing
  function getTracks(uint offset, uint count) constant returns (bytes32[]) {
    uint trackCount = tracklist.length;
    bytes32[] memory t = new bytes32[](trackCount);
    if (count > trackCount) {
      count = trackCount;
    }
    for(uint i = 0 ; i<count; i++) {
      t[i] = tracklist[offset+i];
    }
    return t;
  }

  function trackCount() constant returns (uint) {
    return tracklist.length;
  }

  // by artist listing
  function getTracksByArtist(address id, uint offset, uint count) constant returns (bytes32[]) {

    bytes32[] tl = artists[id];
    uint trackCount = tl.length;
    bytes32[] memory t = new bytes32[](trackCount);
    if (count > trackCount) {
      count = trackCount;
    }
    for(uint i = 0 ; i<count; i++) {
      t[i] = tl[offset+i];
    }
    return t;
  }

  function artistTrackCount(address id) constant returns (uint) {
    return artists[id].length;
  }

  function getTrackByArtist(address id, uint index) constant returns (bytes32) {
    return artists[id][index];
  }

  // @notice the default send is a refill, make sure register sender's balance
  function() {
    balances[msg.sender] += msg.value;
  }

  /// @notice play triggers a payment from streamer's balance to
  ///         the artists forwarding address as well as a tiny fraction
  ///         to the owner's balance
  ///
  /// @param id track ID (swarm hash of jaak manifest)
  /// @param streamer eth address of streamer
  function play(bytes32 id, address streamer, address jaaker) {
    uint balance = balances[streamer];
    if (balance < PLAY_PRICE) {
      throw ;
    }
    Track track = tracks[id];
    track.playbackCount++;
    tracks[id] = track;
    balances[streamer] -= PLAY_PRICE;
    balances[track.artistID] += PLAY_PRICE - JAAK_FRACTION;
    balances[owner] += JAAK_FRACTION ;
    if (jaaker != 0x0) {
      balances[track.artistID] -= JAAKER_FRACTION;
      balances[jaaker] += JAAKER_FRACTION ;
    }
  }

  /// @notice register registers a new track
  ///
  /// @param id track ID (swarm hash of jaak manifest)
  /// @param artist ID (eth address) of track owner (should be taken from msg.sender)
  ///        now this is managed via the jaak proxy
  function register(bytes32 id, address artist) {
    if (msg.sender != owner) {
      throw;
    }
    if (tracks[id].artistID == 0x0) {
      tracks[id] = Track(0, artist, tracklist.length, block.timestamp);
      tracklist.push(id);
    } else {
      tracks[id].artistID = artist;
    }
    // we never dissociate an artist from a song!
    if (artists[artist].length == 0) {
      artistlist.push(artist);
    }
    artists[artist].push(id);
  }

  function clearTracks() {
    if (msg.sender != owner) {
      throw;
    }
    for(uint i = 0 ; i<tracklist.length; i++) {
      delete tracks[tracklist[i]];
      delete tracklist[i];
    }
    delete tracklist;
    for(i = 0 ; i<artistlist.length; i++) {
      delete artists[artistlist[i]];
      delete artistlist[i];
    }
    delete artistlist;
  }

  // currently does not delete from artist index
  function unregister(bytes32 id) {
    if (msg.sender != owner) {
      throw;
    }
    Track track = tracks[id];
    if (track.artistID == 0x0) {
      return;
    }

    uint count = tracklist.length;
    if ( count!= track.index + 1) {
      bytes32 last = tracklist[count - 1];
      tracklist[track.index] = last;
      tracks[last].index = track.index;
    }
    tracklist.length = count - 1;
    delete tracks[id];
  }

  function transfer(address from, address to, uint256 amount) {
    if (from == 0x0) {
      from = owner;
    }
    if (balances[from] < amount) {
      amount = balances[from];
    }
    balances[from] -= amount;
    balances[to] += amount;
  }


  function withdraw(address from, address to, uint amount) {
    if (from == 0x0) {
      from = owner;
    }
    if (balances[from] < amount) {
      amount = balances[from];
    }
    to.send(amount);
    balances[from] -= amount;
  }


}
