import 'common/Owned.sol';
import 'token/Token.sol';

contract Streaming is Owned {
    event Stream(bytes32 indexed ident, bool indexed alive);

    bytes32 public streamIdent;
    bool    public streamAlive;
    Token   public streamToken;

    /**
     * @dev Init streaming with token
     * @param _stream is a token for payout
     */
    function initStreaming(Token _stream) internal
    { streamToken = _stream; }

    /**
     * @dev Start streaming
     * @param _ident is a 256 bit identifier of stream (maybe SHA256)
     */
    function stream(bytes32 _ident) {
        if (!streamToken.transferFrom(msg.sender, this, 1)
            || streamAlive) throw;

        Stream(_ident, true);
        streamIdent = _ident;
        streamAlive = true;
    }

    /**
     * @dev Terminate streaming
     */
    function streamEnd() onlyOwner {
        Stream(streamIdent, false);
        streamAlive = false;
        tradeStream();
    }

    /**
     * @dev Place stream token on market
     */
    function tradeStream() internal {}
}
