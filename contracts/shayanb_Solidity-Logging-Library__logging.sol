
contract logging {

  struct Log {
    uint time;
    string msg;
  }

  Log public lastLog;
//  string[] public logStack;

  event logEvent(uint time, string msg);//, address sender, uint value);

  function logging()  {
    lastLog.time = now;
    lastLog.msg = "Logging v0.2 initated";
    logStack.push(lastLog.msg);

  }

  function log(string message) public {
    logEvent(now, message); //, msg.sender, msg.value);
    logStack.push(lastLog.msg);
    lastLog.time = now;
    lastLog.msg = message;
  }

}

