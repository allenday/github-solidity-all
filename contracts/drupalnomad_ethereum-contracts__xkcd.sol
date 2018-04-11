contract Xkcd {

  struct Strip {
    uint16 year;
    uint8 month;
    uint8 day;
    string title;
    string safeTitle;
    string img;
    string alt;
    string transcript;
    string news;
  }

  address public owner;
  Strip[] public strips;

  event NewStrip(uint num);

  modifier isOwner {
    if (msg.sender == owner) _
  }

  function Xkcd() {
    owner = msg.sender;
  }

  function setOwner(address newOwner) isOwner {
    owner = newOwner;
  }

  function addStrip(uint num, uint16 year, uint8 month, uint8 day, string title, string safeTitle, string img, string alt, string transcript, string news) isOwner {
    if (strips.length <= num) {
      strips.length = num + 1;
    }
    strips[num] = Strip(year, month, day, title, safeTitle, img, alt, transcript, news);
    NewStrip(num);
  }

  function removeStrip(uint num) isOwner {
    delete strips[num];
  }

}
