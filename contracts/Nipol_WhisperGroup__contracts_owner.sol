contract owner {
  // 그룹 개설자
  address public owner;

  // constructor. 
  // Contract 생성자를 그룹 관리자로 한다.
  function owner() {
    owner = msg.sender;
  }

  // 상속받을 Contract들에 사용되는 접근자(?)
  // 오직 그룹 개설자만 사용하능한 Contract 명령어를 지정해 줄 수 있다.
  modifier onlyOwner {
    if (msg.sender != owner) throw;
    _
  }

  // 그룹을 다른 지갑 주소를 가진 사람에게 위임한다.
  function transferOwnership(address newOwner) onlyOwner {
    owner = newOwner;
  }
}
