contract MicropaymentNetwork
{

    enum ChannelStage
    {
        Empty,
        PartiallyConfirmed,
        Confirmed,
        Closing,
        Closed
    }

    struct MicropaymentChannel
    {
        ChannelStage stage;

        address from;
        uint fromBalance;

        address to;
        uint toBalance;

        uint balanceTimestamp;
        uint closingBlockNumber;

        mapping(bytes32 => bytes32) hashesUsed;
    }

    uint public constant closingDelay = 10;
    uint public constant htlcTimeoutClosingDelay = 10 minutes;

    mapping(uint => MicropaymentChannel) channels;
    mapping(uint => bool) reserved;
    
    function MicropaymentsNetwork()
    {
    }

    function isAvailable(uint _cid)
        constant
        returns (bool)
    {
        return !reserved[_cid];
    }

    function assertAvailable(uint _cid)
        internal
    {
        if (!isAvailable(_cid))
        {
            throw;
        }
    }

    function assertOnlyFrom(uint _cid)
        internal
    {
        if (msg.sender != channels[_cid].from)
        {
            throw;
        }
    }

    function assertOnlyTo(uint _cid)
        internal
    {
        if (msg.sender != channels[_cid].to)
        {
            throw;
        }
    }

    function assertOnlyParticipants(uint _cid)
        internal
    {
        if ((msg.sender != channels[_cid].from) && (msg.sender != channels[_cid].to))
        {
            throw;
        }
    }

    function assertAtStage(uint _cid, ChannelStage _stage)
        internal
    {
        if (channels[_cid].stage != _stage)
        {
            throw;
        }
    }

    function assertAtOneOfStages(uint _cid, ChannelStage _stage1, ChannelStage _stage2)
    {
        if ((channels[_cid].stage != _stage1) && (channels[_cid].stage != _stage2))
        {
            throw;
        }
    }

    function assertReadyToClose(uint _cid)
    {
        if (block.number < channels[_cid].closingBlockNumber)
        {
            throw;
        }
    }

    function assertYoungerBalance(uint _cid, uint _balanceTimestamp)
        internal
    {
        if (_balanceTimestamp <= channels[_cid].balanceTimestamp)
        {
            throw;
        }
    }

    function assertMatchingBalance(uint _cid, uint _balanceTimestamp)
        internal
    {
        if (channels[_cid].balanceTimestamp < _balanceTimestamp)
        {
            throw;
        }
    }

    function assertSaneBalance(uint _cid, uint _fromBalance, uint _toBalance)
        internal
    {
        if (channels[_cid].fromBalance + channels[_cid].toBalance < _fromBalance + _toBalance)
        {
            throw;
        }
    }

    function assertStillValid(uint _timeout)
        internal
    {
        if (_timeout < now)
        {
            throw;
        }
    }

    function assertSaneHTLC(uint _cid, int _fromToDelta)
        internal
    {
        if ((int(channels[_cid].fromBalance) - _fromToDelta < 0) ||
            (int(channels[_cid].toBalance) + _fromToDelta < 0))
        {
            throw;
        }
    }

    function assertHash(bytes32 _data, bytes32 _hash)
        internal
    {
        if (getHash(_data) != _hash)
        {
            throw;
        }
    }

    function assertSignedByBoth(
        uint _cid,
        bytes32 _sigHash,
        uint8 _sigV,
        bytes32 _sigR,
        bytes32 _sigS)
        internal
    {
        address signer = getSigner(_sigHash, _sigV, _sigR, _sigS);
        if (!(((channels[_cid].from == msg.sender) && (channels[_cid].to == signer)) || 
              ((channels[_cid].from == signer) && (channels[_cid].to == msg.sender))))
        {
            throw;
        }
    }


    function assertNotSpent(uint _cid, int _fromToDelta, bytes32 _data, bytes32 _hash)
        internal
    {
        if (getHTLCSpendingData(_cid, _fromToDelta, _hash) == _data)
        {
            throw;
        }
    }

    function getHTLCInvalidationTimeoutExtension(uint _cid, int _fromToDelta, bytes32 _data, bytes32 _hash)
        constant
        returns (uint)
    {
        if (getHTLCSpendingData(_cid, -1 * _fromToDelta, _hash) == _data)
        {
            return htlcTimeoutClosingDelay;
        }
        return 0;
    }

    function getHTLCSpendingData(uint _cid, int _fromToDelta, bytes32 _hash)
        constant
        returns (bytes32)
    {
        return channels[_cid].hashesUsed[getHTLCSpendingHash(_fromToDelta, _hash)];
    }

    function getHTLCSpendingHash(int _fromToDelta, bytes32 _hash)
        constant
        returns (bytes32)
    {
        return sha3(_fromToDelta, _hash);
    }

    function getHash(bytes32 _data)
        constant
        returns (bytes32)
    {
        return sha3(_data);
    }

    function getUpdateHash(
        uint _cid,
        uint _balanceTimestamp,
        uint _fromBalance,
        uint _toBalance)
        constant
        returns(bytes32)
    {
        return sha3(_cid, _balanceTimestamp, _fromBalance, _toBalance);
    }

    function getHTLCHash(
        uint _cid,
        uint _balanceTimestamp,
        uint _timeout,
        bytes32 _hash,
        int _fromToDelta)
        constant
        returns(bytes32)
    {
        return sha3(_cid, _timeout, _hash, _fromToDelta);
    }

    function getSigner(
        bytes32 _sigHash,
        uint8 _sigV,
        bytes32 _sigR,
        bytes32 _sigS)
        constant
        returns(address)
    {
        return ecrecover(_sigHash, _sigV, _sigR, _sigS);
    }

    function getTimestampInSeconds()
        constant
        returns(uint)
    {
        return now;
    }
    
    function createChannel(uint _cid, address _from, address _to)
    {
        assertAvailable(_cid);

        reserved[_cid] = true;
        channels[_cid] = MicropaymentChannel(ChannelStage.Empty, _from, 0, _to, 0, 0, 0);
    }

    function getStage(uint _cid)
        constant
        returns (uint8)
    {
        return uint8(channels[_cid].stage);
    }

    function getFrom(uint _cid)
        constant
        returns (address)
    {
        return channels[_cid].from;
    }

    function getFromBalance(uint _cid)
        constant
        returns (uint)
    {
        return channels[_cid].fromBalance;
    }

    function getTo(uint _cid)
        constant
        returns (address)
    {
        return channels[_cid].to;
    }

    function getToBalance(uint _cid)
        constant
        returns (uint)
    {
        return channels[_cid].toBalance;
    }

    function getBalanceTimestamp(uint _cid)
        constant
        returns (uint)
    {
        return channels[_cid].balanceTimestamp;
    }

    function getClosingBlockNumber(uint _cid)
        constant
        returns (uint)
    {
        return channels[_cid].closingBlockNumber;
    }

    function openChannel(uint _cid)
    {
        assertOnlyFrom(_cid);
        assertAtStage(_cid, ChannelStage.Empty);

        channels[_cid].stage = ChannelStage.PartiallyConfirmed;
        channels[_cid].fromBalance = msg.value;
    }
    
    function confirmChannel(uint _cid)
    {
        assertOnlyTo(_cid);
        assertAtStage(_cid, ChannelStage.PartiallyConfirmed);

        channels[_cid].stage = ChannelStage.Confirmed;
        channels[_cid].toBalance = msg.value;
    }

    function requestClosingChannel(uint _cid)
    {
        assertOnlyParticipants(_cid);
        assertAtOneOfStages(_cid, ChannelStage.PartiallyConfirmed, ChannelStage.Confirmed);

        if (channels[_cid].stage == ChannelStage.PartiallyConfirmed)
        {
            channels[_cid].stage = ChannelStage.Closed;
        }
        else
        {
            channels[_cid].stage = ChannelStage.Closing;
            channels[_cid].closingBlockNumber = block.number + closingDelay;
        }
    }
    
    function closeChannel(uint _cid)
    {
        assertOnlyParticipants(_cid);
        assertAtStage(_cid, ChannelStage.Closing);
        assertReadyToClose(_cid);

        channels[_cid].stage = ChannelStage.Closed;
    }

    function withdrawFrom(uint _cid)
    {
        assertOnlyFrom(_cid);
        assertAtStage(_cid, ChannelStage.Closed);

        uint balance = channels[_cid].fromBalance;
        channels[_cid].fromBalance = 0;
        channels[_cid].from.send(balance);
    }

    function withdrawTo(uint _cid)
    {
        assertOnlyTo(_cid);
        assertAtStage(_cid, ChannelStage.Closed);

        uint balance = channels[_cid].toBalance;
        channels[_cid].toBalance = 0;
        channels[_cid].to.send(balance);
    }

    function updateChannelState(
        uint _cid,
        uint _balanceTimestamp,
        uint _fromBalance,
        uint _toBalance,
        uint8 _sigV,
        bytes32 _sigR,
        bytes32 _sigS)
    {
        assertOnlyParticipants(_cid);
        assertAtOneOfStages(_cid, ChannelStage.Confirmed, ChannelStage.Closing);
        assertYoungerBalance(_cid, _balanceTimestamp);
        assertSaneBalance(_cid, _fromBalance, _toBalance);
        assertSignedByBoth(_cid, getUpdateHash(_cid, _balanceTimestamp, _fromBalance, _toBalance), _sigV, _sigR, _sigS);

        channels[_cid].balanceTimestamp = _balanceTimestamp;
        channels[_cid].fromBalance = _fromBalance;
        channels[_cid].toBalance = _toBalance;
    }

    function resolveHTLC(
        uint _cid,
        uint _balanceTimestamp,
        uint _timeout,
        bytes32 _hash,
        int _fromToDelta,
        bytes32 _data,
        uint8 _sigV,
        bytes32 _sigR,
        bytes32 _sigS)
    {
        assertOnlyParticipants(_cid);
        assertAtOneOfStages(_cid, ChannelStage.Confirmed, ChannelStage.Closing);
        assertMatchingBalance(_cid, _balanceTimestamp);
        assertStillValid(_timeout);
        assertSaneHTLC(_cid, _fromToDelta);
        assertHash(_data, _hash);
        assertNotSpent(_cid, _fromToDelta, _data, _hash);
        assertSignedByBoth(_cid, getHTLCHash(_cid, _balanceTimestamp, _timeout, _hash, _fromToDelta), _sigV, _sigR, _sigS);

        _timeout = _timeout + getHTLCInvalidationTimeoutExtension(_cid, _fromToDelta, _data, _hash);

        channels[_cid].fromBalance = uint(int(channels[_cid].fromBalance) - _fromToDelta);
        channels[_cid].toBalance = uint(int(channels[_cid].toBalance) + _fromToDelta);
        channels[_cid].hashesUsed[getHTLCSpendingHash(_fromToDelta, _hash)] = _data;
    }
}