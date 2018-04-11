import "owner.sol";

contract Group is owner {
  // 사용자 지갑주소에 따른 맴버아이디
  mapping (address => uint) memberId;
  // 사용자들
  Member[] public members;
  // 채널들
  Channel[] public channels;
  // 채널 속 사람들
  mapping (Channel => Member[]) memberInChannel;

  // 사용자 객체
  struct Member {
    // 사용자의 지갑주소
    address memberaddr;
    // 사용자의 Whisper identity
    string whisperid;
    // 사용 닉네임
    string nickname;
    // 가입일
    uint since;
    // 차단설정
    bool isActive;
  }

  // 사용자 대화 채널
  struct Channel {
    // id
    string id;
    // # + name
    string name;
    // 숨겨진 채널인지 아닌지.
    bool ishide;
    // 그룹의 기본 채널인지 아닌지
    bool groupbasic;
  }

  // constructor
  // 그룹이 생길 때 관리자 계정을 미리 할당
  // TODO: 그룹이 생길 때 기본 채널을 미리 할당
  // TODO: 그룹이 생길 때 관리자 계정을 일반 채널에 추가한다.
  // 
  function Group(string adwhisperid) {
    members.length++;
    members[0] = Member({memberaddr: 0, whisperid: adwhisperid, nickname: 'Admin', since: now, isActive: false});
  }

  // 사용자를 생성
  // 그룹 관리자만 생성이 가능
  function makeUser(address memberaddr, string whisperid, string nickname) onlyOwner {
    uint temid;
    if(memberId[memberaddr] == 0) {
      memberId[memberaddr] = members.length;
      temid = members.length++;
      members[temid] = Member({memberaddr: memberaddr, whisperid: whisperid, nickname: nickname, since: now, isActive: false});
    }
  }
}
